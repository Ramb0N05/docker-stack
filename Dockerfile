FROM nextcloud:28-apache

ARG DOMAIN=www.example.com
ARG ADMIN_MAIL=webmaster@localhost

RUN apt-get update
RUN apt-get install -y libmagickwand-dev --no-install-recommends
RUN rm -rf /var/lib/apt/lists/*

RUN printf "ServerName ${DOMAIN}" > /etc/apache2/conf-available/server-name.conf
RUN sed -i "s/#ServerName www.example.com/ServerName ${DOMAIN}/g" /etc/apache2/sites-available/000-default.conf
RUN sed -i "s/webmaster@localhost/${ADMIN_MAIL}/g" /etc/apache2/sites-available/000-default.conf
RUN a2enconf server-name

EXPOSE 80
WORKDIR /var/www/html
ENTRYPOINT ["/entrypoint.sh"]
CMD ["apache2-foreground"]
