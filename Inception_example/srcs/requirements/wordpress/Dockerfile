FROM debian:bullseye

ARG DB_NAME DB_USER DB_USER_PASS \
    DOMAIN_NAME BRAND \
    WORDPRESS_ADMIN WORDPRESS_ADMIN_PASS WORDPRESS_ADMIN_EMAIL \
    WORDPRESS_USER WORDPRESS_USER_PASS WORDPRESS_USER_EMAIL

RUN apt-get update && \
    apt-get install -y apt-utils wget php php-fpm php-phar \
    php-mysql mariadb-client php-zip unzip curl openssl vim && \
    rm -rf /var/lib/apt/lists/* && \
    sed -i -e 's/listen =.*/listen = 0.0.0.0:9000/g' /etc/php/7.4/fpm/pool.d/www.conf

WORKDIR /var/www/html
RUN chown -R www-data:www-data /var/www/html
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

RUN wp core download --allow-root
RUN mkdir -p /etc/tools
COPY tools/setup.sh /etc/tools/setup.sh
RUN chmod +x /etc/tools/setup.sh

EXPOSE 9000

ENTRYPOINT ["/bin/sh", "/etc/tools/setup.sh"]