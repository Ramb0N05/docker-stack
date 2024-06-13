FROM wordpress:php8.0-apache

ARG DOMAIN=www.example.com
ARG ADMIN_MAIL=webmaster@localhost
ARG MEMCACHED_ALLOW_FAILOVER=1
ARG MEMCACHED_MAX_FAILOVER_ATTEMPTS=20
ARG MEMCACHED_CHUNK_SIZE=32768
ARG MEMCACHED_DEFAULT_PORT=11211
ARG MEMCACHED_HASH_STRATEGY=standard
ARG MEMCACHED_HASH_FUNCTION=crc32
ARG MEMCACHED_SAVE_HANDLER=memcache
ARG MEMCACHED_SAVE_PATH=tcp://memcached:11211?persistent=1&weight=1&timeout=1&retry_interval=15
ARG OPCACHE_ENABLE=1
ARG OPCACHE_FAST_SHUTDOWN=1
ARG OPCACHE_ENABLE_FILE_OVERRIDE=1
ARG OPCACHE_VALIDATE_TIMESTAMPS=0
ARG OPCACHE_MAX_FILE_SIZE=10000000
ARG SMTP_ENABLE_TLS=on
ARG SMTP_ACCOUNT=default
ARG SMTP_HOST=mail.example.com
ARG SMTP_PORT=587
ARG SMTP_FROM=localhost@example.com
ARG SMTP_USER=localhost@example.com
ARG SMTP_PASS

RUN a2enmod ext_filter
RUN a2enmod headers
RUN set -eux

RUN apt-get update
RUN apt-get install -y --no-install-recommends zip unzip libmemcached-dev zlib1g-dev msmtp mailutils
RUN rm -rf /var/lib/apt/lists/*
RUN pecl install memcached
RUN pecl install memcache
RUN pecl install redis

RUN printf "extension=memcached.so" > /usr/local/etc/php/conf.d/docker-php-ext-memcached.ini
RUN printf "extension=memcache.so\n\n memcache.allow_failover = ${MEMCACHED_ALLOW_FAILOVER}\n memcache.max_failover_attempts = ${MEMCACHED_MAX_FAILOVER_ATTEMPTS}\n memcache.chunk_size = ${MEMCACHED_CHUNK_SIZE}\n memcache.default_port = ${MEMCACHED_DEFAULT_PORT}\n memcache.hash_strategy = ${MEMCACHED_HASH_STRATEGY}\n memcache.hash_function = ${MEMCACHED_HASH_FUNCTION}" > /usr/local/etc/php/conf.d/docker-php-ext-memcache.ini
RUN printf 'session.save_handler = ${MEMCACHED_SAVE_HANDLER}\n session.save_path = "${MEMCACHED_SAVE_PATH}"' > /usr/local/etc/php/conf.d/w3-memcache.ini
RUN printf "opcache.enable = ${OPCACHE_ENABLE}\n opcache.fast_shutdown = ${OPCACHE_FAST_SHUTDOWN}\n opcache.enable_file_override = ${OPCACHE_ENABLE_FILE_OVERRIDE}\n opcache.validate_timestamps = ${OPCACHE_VALIDATE_TIMESTAMPS}\n opcache.max_file_size = ${OPCACHE_MAX_FILE_SIZE}" > /usr/local/etc/php/conf.d/w3-opcache.ini
RUN printf "extension=redis.so" > /usr/local/etc/php/conf.d/redis.ini

RUN ln -sf /usr/bin/msmtp /usr/sbin/sendmail
RUN chown -R www-data: /var/mail
RUN touch /etc/msmtprc
RUN touch /etc/aliases
RUN chown www-data: /etc/msmtprc
RUN chown www-data: /etc/aliases
RUN chmod 600 /etc/msmtprc
RUN chmod 600 /etc/aliases
RUN printf 'sendmail_path = "/usr/bin/msmtp -t"' > /usr/local/etc/php/conf.d/msmtp.ini
RUN printf "defaults\n auth on\n tls ${SMTP_ENABLE_TLS}\n tls_trust_file /etc/ssl/certs/ca-certificates.crt\n syslog on\n account ${SMTP_ACCOUNT}\n host ${SMTP_HOST}\n port ${SMTP_PORT}\n from ${SMTP_FROM}\n user ${SMTP_USER}\n password ${SMTP_PASS}" > /etc/msmtprc
RUN printf "root: ${SMTP_FROM}\n default: ${SMTP_FROM}" > /etc/aliases

RUN printf "\n\n <IfModule mod_php.c>\n php_admin_value open_basedir /var/www/\n </IfModule> " >> /etc/apache2/conf-available/docker-php.conf
RUN curl https://raw.githubusercontent.com/W3EDGE/w3-total-cache/2.2.7/ini/apache_conf/mod_deflate.conf --output /etc/apache2/conf-available/w3-deflate.conf
RUN curl -s https://raw.githubusercontent.com/W3EDGE/w3-total-cache/2.2.7/ini/apache_conf/mod_expires.conf | sed -e 's/<filesmatch>/<filesmatch ~>/g' > /etc/apache2/conf-available/w3-expires.conf
RUN curl https://raw.githubusercontent.com/W3EDGE/w3-total-cache/2.2.7/ini/apache_conf/mod_mime.conf --output /etc/apache2/conf-available/w3-mime.conf
RUN curl https://raw.githubusercontent.com/W3EDGE/w3-total-cache/2.2.7/ini/apache_conf/mod_rewrite.conf --output /etc/apache2/conf-available/w3-rewrite.conf
RUN a2enconf docker-php w3-*

RUN printf "ServerName ${DOMAIN}" > /etc/apache2/conf-available/server-name.conf
RUN sed -i "s/#ServerName www.example.com/ServerName ${DOMAIN}/g" /etc/apache2/sites-available/000-default.conf
RUN sed -i "s/webmaster@localhost/${ADMIN_MAIL}/g" /etc/apache2/sites-available/000-default.conf
RUN a2enconf server-name

EXPOSE 80
WORKDIR /var/www/html
ENTRYPOINT ["docker-php-entrypoint"]
CMD ["apache2-foreground"]
