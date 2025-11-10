FROM debian:bullseye

RUN apt-get update && \
    apt-get install -y apt-utils nginx vim curl telnet netcat openssl && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /etc/nginx/ssl

RUN openssl req -x509 -nodes \
    -out /etc/nginx/ssl/inception.crt \
    -keyout /etc/nginx/ssl/inception.key \
    -subj "/C=AE/ST=AbuDhabi/L=AbuDhabi/O=42/OU=42/CN=sabdulki.42.fr/UID=sabdulki"

RUN mkdir -p /var/run/nginx 

COPY conf/default.conf /etc/nginx/conf.d/default.conf

RUN chmod 755 /var/www/html
RUN chown -R www-data:www-data /var/www/html

EXPOSE 443

CMD [ "nginx", "-g", "daemon off;" ]