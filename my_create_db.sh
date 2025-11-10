#!/bin/sh
# create_db.sh — MariaDB init & run (Inception)
# - Инициализирует БД один раз при пустом DATADIR
# - Настраивает root-пароль/пользователя/базу из ENV
# - Запускает mariadbd/mysqld как PID 1 без фоновых «хаков»

set -eu

# Конфигурируемые пути (совпадают с conf/50-server.cnf и docker-compose volume)
DATADIR="${DATADIR:-/var/lib/mysql}"
SOCKET="${SOCKET:-/run/mysqld/mysqld.sock}"
PIDFILE="${PIDFILE:-/run/mysqld/mysqld.pid}"

# Параметры из .env (docker-compose env_file)
DB_NAME="${DB_NAME:-}"
DB_USER="${DB_USER:-}"
DB_USER_PASS="${DB_USER_PASS:-}"
DB_ROOT_PASS="${DB_ROOT_PASS:-}"

# Выбираем доступные бинарники (совместимо с Debian Buster / MariaDB)
MDB_BIN="$(command -v mariadbd 2>/dev/null || true)"
[ -n "${MDB_BIN}" ] || MDB_BIN="$(command -v mysqld 2>/dev/null || true)"
[ -n "${MDB_BIN}" ] || { echo "MariaDB server binary not found (mariadbd/mysqld)"; exit 1; }

INSTALL_BIN="$(command -v mariadb-install-db 2>/dev/null || true)"
[ -n "${INSTALL_BIN}" ] || INSTALL_BIN="$(command -v mysql_install_db 2>/dev/null || true)"
[ -n "${INSTALL_BIN}" ] || { echo "Init binary not found (mariadb-install-db/mysql_install_db)"; exit 1; }

mkdir -p "$(dirname "$SOCKET")" "$DATADIR"
chown -R mysql:mysql "$(dirname "$SOCKET")" "$DATADIR"

# Инициализация данных (только при первом запуске, когда системные таблицы отсутствуют)
if [ ! -d "$DATADIR/mysql" ]; then
  echo "[MariaDB] Initializing data directory at $DATADIR ..."

  if [ "$(basename "$INSTALL_BIN")" = "mariadb-install-db" ]; then
    "$INSTALL_BIN" \
      --user=mysql \
      --datadir="$DATADIR" \
      --skip-test-db \
      --auth-root-authentication-method=normal
  else
    # mysql_install_db не знает --auth-root-authentication-method
    "$INSTALL_BIN" \
      --user=mysql \
      --datadir="$DATADIR" \
      --skip-test-db
  fi

  # Стартуем временный сервер для применения SQL
  "$MDB_BIN" \
    --user=mysql \
    --datadir="$DATADIR" \
    --socket="$SOCKET" \
    --pid-file="$PIDFILE" \
    --skip-networking=0 \
    --bind-address=127.0.0.1 &
  BOOT_PID=$!

  # Ждём готовности
  ATTEMPTS=60
  while ! mysqladmin --socket="$SOCKET" -uroot ping >/dev/null 2>&1; do
    ATTEMPTS=$((ATTEMPTS-1)) || true
    [ "$ATTEMPTS" -gt 0 ] || { echo "MariaDB bootstrap failed to become ready"; kill "$BOOT_PID" 2>/dev/null || true; exit 1; }
    sleep 1
  done

  # Устанавливаем пароль root (если задан)
  if [ -n "$DB_ROOT_PASS" ]; then
    mysql --socket="$SOCKET" -uroot <<-SQL
      ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASS}';
      FLUSH PRIVILEGES;
SQL
  fi

  # Создаём БД и пользователя (если заданы все переменные)
  if [ -n "$DB_NAME" ] && [ -n "$DB_USER" ] && [ -n "$DB_USER_PASS" ]; then
    if [ -n "$DB_ROOT_PASS" ]; then
      AUTH_ROOT="-p${DB_ROOT_PASS}"
    else
      AUTH_ROOT=""
    fi
    mysql --socket="$SOCKET" -uroot ${AUTH_ROOT} <<-SQL
      CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
      CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_USER_PASS}';
      GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'%';
      FLUSH PRIVILEGES;
SQL
  fi

  # Останавливаем bootstrap-сервер аккуратно
  if [ -n "$DB_ROOT_PASS" ]; then
    mysqladmin --socket="$SOCKET" -uroot -p"${DB_ROOT_PASS}" shutdown
  else
    mysqladmin --socket="$SOCKET" -uroot shutdown
  fi
  wait "$BOOT_PID" || true
fi

# Основной запуск (PID 1). Никаких фоновых процессов/бесконечных циклов.
exec "$MDB_BIN" \
  --user=mysql \
  --datadir="$DATADIR" \
  --socket="$SOCKET" \
  --pid-file="$PIDFILE"