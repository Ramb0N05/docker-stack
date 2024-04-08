FROM php:8-apache
ARG DOMAIN=www.example.com
ARG MAIL_ADMIN=webmaster@localhost
ARG MAIL_DOMAIN
ARG MAIL_FROM
ARG SMTP_AUTH_USER
ARG SMTP_AUTH_PASS
ARG SMTP_SERVER
ARG SMTP_PORT=25
ARG SMTP_USE_TLS=NO
ARG SMTP_USE_STARTTLS=NO

RUN apt-get update
RUN apt-get install -y zlib1g-dev libbz2-dev libzip-dev ssmtp mailutils
RUN printf "error_reporting E_NONE" > /usr/local/etc/php/conf.d/disable-warnings.ini
RUN printf "sendmail_path=/usr/sbin/ssmtp -t" > /usr/local/etc/php/conf.d/sendmail.ini
RUN docker-php-ext-install bcmath bz2 mysqli pdo pdo_mysql zip
RUN rm -rf /var/lib/apt/lists/*

RUN printf "ServerName ${DOMAIN}" > /etc/apache2/conf-available/server-name.conf
RUN sed -i "s/#ServerName www.example.com/ServerName ${DOMAIN}/g" /etc/apache2/sites-available/000-default.conf
RUN sed -i "s/webmaster@localhost/${MAIL_ADMIN}/g" /etc/apache2/sites-available/000-default.conf
RUN sed -i "s/webmaster@localhost/${MAIL_ADMIN}/g" /etc/apache2/sites-available/default-ssl.conf
RUN a2enconf server-name

RUN sed -i "s/root=postmaster/root=${MAIL_FROM}/g" /etc/ssmtp/ssmtp.conf
RUN sed -i "s/mailhub=mail/mailhub=${SMTP_SERVER}:${SMTP_PORT}/g" /etc/ssmtp/ssmtp.conf
RUN sed -i "s/#rewriteDomain=/rewriteDomain=${MAIL_DOMAIN}/g" /etc/ssmtp/ssmtp.conf
RUN sed -i "s/hostname=localhost/hostname=${MAIL_FROM}/g"
RUN sed -i "s/#FromLineOverride=YES/FromLineOverride=YES/g" /etc/ssmtp/ssmtp.conf

RUN printf "\nTLS_CA_FILE=/etc/ssl/certs/ca-certificates.crt\n" >> /etc/ssmtp/ssmtp.conf
RUN printf "\nUseTLS=${SMTP_USE_TLS}\nUseSTARTTLS=${SMTP_USE_STARTTLS}\n" >> /etc/ssmtp/ssmtp.conf
RUN printf "\nAuthUser=${SMTP_AUTH_USER}\nAuthPass=${SMTP_AUTH_PASS}\nAuthMethod=LOGIN\n" >> /etc/ssmtp/ssmtp.conf

RUN printf "root:${MAIL_FROM}:${SMTP_SERVER}:${SMTP_PORT}" >> /etc/ssmtp/revaliases
RUN printf "www-data:${MAIL_FROM}:${SMTP_SERVER}:${SMTP_PORT}" >> /etc/ssmtp/revaliases

EXPOSE 80
WORKDIR /var/www/html
ENTRYPOINT ["docker-php-entrypoint"]
CMD ["apache2-foreground"]
