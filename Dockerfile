FROM nextcloud:29-apache

ARG DOMAIN=www.example.com
ARG ADMIN_MAIL=webmaster@localhost
ARG OPCACHE_ENABLE=1
ARG OPCACHE_SAVE_COMMENTS=1
ARG OPCACHE_REVALIDATE_FREQ=60
ARG OPCACHE_MEMORY_CONSUMPTION=256M
ARG OPCACHE_JIT=1225
ARG OPCACHE_JIT_BUFFER_SIZE=128M

RUN apt-get update
RUN apt-get install -y ffmpeg libmagickwand-dev --no-install-recommends
RUN rm -rf /var/lib/apt/lists/*

RUN printf "opcache.enable = ${OPCACHE_ENABLE}\n opcache.save_comments = ${OPCACHE_SAVE_COMMENTS}\n opcache.revalidate_freq = ${OPCACHE_REVALIDATE_FREQ}\n opcache.memory_consumption = ${OPCACHE_MEMORY_CONSUMPTION}\n opcache.jit = ${OPCACHE_JIT}\n opcache.jit_buffer_size = ${OPCACHE_JIT_BUFFER_SIZE}" > /usr/local/etc/php/conf.d/w3-opcache.ini

RUN printf "ServerName ${DOMAIN}" > /etc/apache2/conf-available/server-name.conf
RUN sed -i "s/#ServerName www.example.com/ServerName ${DOMAIN}/g" /etc/apache2/sites-available/000-default.conf
RUN sed -i "s/webmaster@localhost/${ADMIN_MAIL}/g" /etc/apache2/sites-available/000-default.conf
RUN a2enconf server-name

EXPOSE 80
WORKDIR /var/www/html
ENTRYPOINT ["/entrypoint.sh"]
CMD ["apache2-foreground"]
