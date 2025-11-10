FROM debian:bullseye

ARG DB_NAME DB_USER DB_USER_PASS DB_ROOT_PASS

RUN apt-get update -y && \
    apt upgrade -y && \
    apt-get install mariadb-server -y && \
    apt-get clean && rm -rf /var/cache/apk/*

COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf

COPY tools/create_db.sh /usr/local/bin/create_db.sh
RUN chmod +x /usr/local/bin/create_db.sh

EXPOSE 3306

ENTRYPOINT ["/bin/sh", "/usr/local/bin/create_db.sh"]