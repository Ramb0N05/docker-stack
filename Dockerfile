FROM php:8-apache
ARG DOMAIN=www.example.com
ARG MAIL=webmaster@localhost

RUN apt-get update
RUN apt-get install -y zlib1g-dev libbz2-dev libzip-dev sendmail
RUN printf "sendmail_path=/usr/sbin/sendmail -t -i" > /usr/local/etc/php/conf.d/sendmail.ini
RUN docker-php-ext-install bcmath bz2 mysqli pdo pdo_mysql zip
RUN rm -rf /var/lib/apt/lists/*

RUN printf "ServerName $DOMAIN" > /etc/apache2/conf-available/server-name.conf
RUN sed -i "s/#ServerName www.example.com/ServerName $DOMAIN/g" /etc/apache2/sites-available/000-default.conf
RUN sed -i "s/webmaster@localhost/$MAIL/g" /etc/apache2/sites-available/000-default.conf
RUN sed -i "s/webmaster@localhost/$MAIL/g" /etc/apache2/sites-available/default-ssl.conf
RUN a2enconf server-name

EXPOSE 80
WORKDIR /var/www/html
ENTRYPOINT ["docker-php-entrypoint"]
CMD ["apache2-foreground"]
