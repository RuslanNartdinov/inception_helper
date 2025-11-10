
until mysqladmin ping -h"mariadb" --silent; do
  sleep 1
done

rm -f /var/www/html/wp-config.php

if [ ! -f /var/www/html/wp-config.php ]; then
    wp config create --dbname=$DB_NAME --dbuser=$DB_USER \
        --dbpass=$DB_USER_PASS --dbhost=mariadb --allow-root

    wp core install --url=$DOMAIN_NAME --title=$BRAND --admin_user=$WORDPRESS_ADMIN \
        --admin_password=$WORDPRESS_ADMIN_PASS --admin_email=$WORDPRESS_ADMIN_EMAIL \
        --allow-root

    wp user create $WORDPRESS_USER $WORDPRESS_USER_EMAIL --role=author --user_pass=$WORDPRESS_USER_PASS --allow-root

    wp config set FORCE_SSL_ADMIN 'false' --allow-root

    wp config  set WP_CACHE 'true' --allow-root

    wp option update moderation_notify 0 --allow-root
    wp option update comments_notify 0 --allow-root

    chmod 755 /var/www/html/wp-content

    wp theme install twentyfifteen

    wp theme activate twentyfifteen

    wp theme update twentyfifteen
fi

echo "✅ WordPress initialized. Starting PHP-FPM..."

mkdir -p /run/php
chown www-data:www-data /run/php

exec /usr/sbin/php-fpm7.4 -F