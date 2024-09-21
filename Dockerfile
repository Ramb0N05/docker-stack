FROM mariadb:10

ARG LDAP_URI=ldap://ldap.example.com
ARG LDAP_BASE=dc=example,dc=com
ARG LDAP_BIND_DN=cn=admin,dc=example,dc=com
ARG LDAP_BIND_PASS=secret
ARG LDAP_PAM_FILTER=objectClass=inetOrgPerson
ARG LDAP_PAM_LOGIN_ATTR=uid
ARG LDAP_PAM_MEMBER_ATTR=uniqueMember

RUN apt-get update -y --fix-missing && apt-get upgrade -y
RUN export DEBIAN_FRONTEND=noninteractive && apt-get install -y curl ldap-utils libpam-ldapd libmariadbclient18 --no-install-recommends
RUN apt-get autoremove -y && apt-get autoclean -y
RUN rm -rf /var/lib/apt/lists/*

RUN curl https://raw.githubusercontent.com/windKanal/docker-stack/refs/heads/mariadb/nslcd.conf --output /etc/nslcd.conf
RUN sed -i "s@%LDAP_URI%@${LDAP_URI}@g" /etc/nslcd.conf
RUN sed -i "s@%LDAP_BASE%@${LDAP_BASE}@g" /etc/nslcd.conf
RUN sed -i "s@%LDAP_BIND_DN%@${LDAP_BIND_DN}@g" /etc/nslcd.conf
RUN sed -i "s@%LDAP_BIND_PASS%@${LDAP_BIND_PASS}@g" /etc/nslcd.conf

RUN printf "auth required pam_ldap.so\nauth required pam_warn.so\nauth required pam_user_map.so\naccount required pam_ldap.so\naccount required pam_warn.so\n" > /etc/pam.d/mariadb

EXPOSE 3306
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["mariadbd"]
