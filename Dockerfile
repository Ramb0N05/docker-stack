FROM osixia/openldap:stable

RUN apt-get update
RUN apt-get install -y --no-install-recommends git

RUN cd /tmp && git clone https://github.com/debops/debops.git
RUN apt purge -y git

RUN mkdir /etc/ldap/schema/debops
RUN cp -R /tmp/debops/ansible/roles/slapd/files/etc/ldap/schema/debops/* /etc/ldap/schema/debops/

RUN rm -rf /tmp/*
RUN rm -rf /var/lib/apt/lists/*

EXPOSE 389 636
ENTRYPOINT ["/container/tool/run"]
CMD ["bash"]
