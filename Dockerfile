FROM nextcloud:24-apache
RUN apt-get update
RUN apt-get install -y libmagickwand-dev --no-install-recommends
RUN rm -rf /var/lib/apt/lists/*

EXPOSE 80
WORKDIR /var/www/html
ENTRYPOINT ["/entrypoint.sh"]
CMD ["apache2-foreground"]
