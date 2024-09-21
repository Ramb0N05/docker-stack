FROM nextcloud:29-apache

ARG DOMAIN=www.example.com
ARG ADMIN_MAIL=webmaster@localhost
ARG OPCACHE_ENABLE=1
ARG OPCACHE_SAVE_COMMENTS=1
ARG OPCACHE_REVALIDATE_FREQ=60
ARG OPCACHE_MEMORY_CONSUMPTION=256M
ARG OPCACHE_JIT=1225
ARG OPCACHE_JIT_BUFFER_SIZE=128M
ARG PHP_MEMORY_LIMIT=512M
ARG PHP_UPLOAD_LIMIT=512M

RUN apt-get update
RUN apt-get install -y sudo ffmpeg libmagickwand-dev libreoffice --no-install-recommends
RUN rm -rf /var/lib/apt/lists/*

RUN printf "opcache.enable = ${OPCACHE_ENABLE}\nopcache.save_comments = ${OPCACHE_SAVE_COMMENTS}\nopcache.revalidate_freq = ${OPCACHE_REVALIDATE_FREQ}\nopcache.memory_consumption = ${OPCACHE_MEMORY_CONSUMPTION}\nopcache.jit = ${OPCACHE_JIT}\nopcache.jit_buffer_size = ${OPCACHE_JIT_BUFFER_SIZE}" > /usr/local/etc/php/conf.d/w3-opcache.ini
RUN printf "memory_limit=${PHP_MEMORY_LIMIT}\nupload_max_filesize=${PHP_UPLOAD_LIMIT}\npost_max_size=${PHP_UPLOAD_LIMIT}" > /usr/local/etc/php/conf.d/nextcloud.ini

RUN printf "ServerName ${DOMAIN}" > /etc/apache2/conf-available/server-name.conf
RUN sed -i "s/#ServerName www.example.com/ServerName ${DOMAIN}/g" /etc/apache2/sites-available/000-default.conf
RUN sed -i "s/webmaster@localhost/${ADMIN_MAIL}/g" /etc/apache2/sites-available/000-default.conf
RUN a2enconf server-name

EXPOSE 80
WORKDIR /var/www/html
ENTRYPOINT ["/entrypoint.sh"]
CMD ["apache2-foreground"]
