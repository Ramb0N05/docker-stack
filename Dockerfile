FROM mariadb:10

RUN apt-get update -y --fix-missing && apt-get upgrade -y
RUN apt-get autoremove -y && apt-get autoclean -y
RUN rm -rf /var/lib/apt/lists/*

EXPOSE 3306
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["mariadbd"]
