FROM mariadb:10

ARG LDAP_HOST=localhost
ARG LDAP_PORT=389
ARG LDAP_BASE=dc=example,dc=com
ARG LDAP_BIND_DN=cn=admin,dc=example,dc=com
ARG LDAP_BIND_PASS=secret
ARG LDAP_PAM_FILTER=objectClass=inetOrgPerson
ARG LDAP_PAM_LOGIN_ATTR=uid
ARG LDAP_PAM_MEMBER_ATTR=uniqueMember

RUN apt-get update -y --fix-missing
RUN apt-get install -y ldap-utils libpam-ldapd --no-install-recommends
RUN apt-get autoremove -y
RUN apt-get autoclean -y
RUN rm -rf /var/lib/apt/lists/*

RUN printf "HOST ${LDAP_HOST}\nPORT ${LDAP_PORT}\nBASE ${LDAP_BASE}\nBINDDN ${LDAP_BIND_DN}\nBINDPW ${LDAP_BIND_PASS}\nPAM_FILTER ${LDAP_PAM_FILTER}\nPAM_LOGIN_ATTRIBUTE ${LDAP_PAM_LOGIN_ATTR}\nPAM_MEMBER_ATTRIBUTE ${LDAP_PAM_MEMBER_ATTR}\n" >> /etc/ldap/ldap.conf
RUN printf "auth required pam_ldap.so\nauth required pam_user_map.so\naccount required pam_ldap.so\n" > /etc/pam.d/mariadb

EXPOSE 3306
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["mariadbd"]
