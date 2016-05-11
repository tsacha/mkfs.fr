# Reset openldap :
# systemctl stop slapd; rm -Rf /etc/openldap/slapd.d/*; rm -Rf /var/lib/openldap-data/*; rm -Rf /var/run/openldap/*; rm -Rf
# /run/openldap/* ; salt-call state.highstate whitelist=ldap,ldap.users 

openldap-servers:
  pkg.installed

openldap-clients:
  pkg.installed

openssl:
  pkg.installed
  
openldap-sha2:
  pkg.installed:
    - sources:
      - openldap-sha2: 'salt://ldap/sha2/RPMS/openldap-sha2-2.4.43-4.fc24.x86_64.rpm'

/etc/openldap/ldap.conf:
  file.managed:
    - user: ldap
    - group: ldap
    - mode: 644
    - require:
      - pkg: openldap-servers
    - template: jinja
    - source: 'salt://ldap/config/ldap.conf.template'

/etc/openldap/ssl:
  file.directory:
    - user: ldap
    - group: ldap
    - mode: 750
    - require:
      - pkg: openldap-servers

generate cert:
  cmd.wait:
    - name: openssl req -x509 -subj '/CN={{ pillar['ldap']['uri'] }}/O=ldap/C=fr' -newkey rsa:4096 -keyout key.pem -out cert.pem -nodes -days 3650
    - cwd: /etc/openldap/ssl
    - user: ldap
    - group: ldap
    - watch:
      - pkg: openldap-servers
    - require:
      - file: /etc/openldap/ssl
      - pkg: openssl

/etc/openldap/ssl/cert.pem:
  file.managed:
    - user: ldap
    - group: ldap
    - mode: 440
    - require:
      - cmd: generate cert

/etc/openldap/ssl/key.pem:
  file.managed:
    - user: ldap
    - group: ldap
    - mode: 440
    - require:
      - cmd: generate cert

/etc/openldap/root.ldif:
  file.managed:
    - user: ldap
    - group: ldap
    - mode: 644
    - require:
      - pkg: openldap-servers
    - template: jinja
    - source: 'salt://ldap/config/root.ldif'

/etc/openldap/replace.ldif:
  file.managed:
    - user: ldap
    - group: ldap
    - mode: 644
    - template: jinja
    - source: 'salt://ldap/config/replace.ldif'
    - require:
      - pkg: openldap-servers

/etc/openldap/module.ldif:
  file.managed:
    - user: ldap
    - group: ldap
    - mode: 644
    - template: jinja
    - source: 'salt://ldap/config/module.ldif'
    - require:
      - pkg: openldap-servers

replace config:
  cmd.run:
    - name: ldapmodify -a -Q -Y EXTERNAL -H ldapi:/// -f /etc/openldap/replace.ldif
    - unless: "ldapsearch -Y EXTERNAL -H ldapi:/// -b cn=config '(&(olcSuffix={{ pillar['ldap']['dn'] }}))' | grep 'numEntries: 1'"
    - require:
      - service: slapd
      - cmd: add module

add cosine schema:
  cmd.run:
    - name: ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/cosine.ldif
    - unless: "ldapsearch -Y EXTERNAL -H ldapi:/// -b cn={1}cosine,cn=schema,cn=config"
    - require:
      - service: slapd


add nis schema:
  cmd.run:
    - name: ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/nis.ldif
    - unless: "ldapsearch -Y EXTERNAL -H ldapi:/// -b cn={2}nis,cn=schema,cn=config"
    - require:
      - cmd: add cosine schema
      - service: slapd

add inetorgperson schema:
  cmd.run:
    - name: ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/inetorgperson.ldif
    - unless: "ldapsearch -Y EXTERNAL -H ldapi:/// -b cn={3}inetorgperson,cn=schema,cn=config"
    - require:
      - cmd: add nis schema
      - service: slapd

add module:
  cmd.run:
    - name: ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/module.ldif
    - unless: "ldapsearch -Y EXTERNAL -H ldapi:/// -b cn=module{0},cn=config"
    - require:
      - service: slapd
      - file: /etc/openldap/module.ldif

slapd:
  service.running:
    - enable: true
    - require:
      - cmd: generate cert

create root:
  cmd.run:
    - name: ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/root.ldif
    - require:
      - service: slapd
      - file: /etc/openldap/root.ldif
      - cmd: replace config
      - cmd: add inetorgperson schema
    - unless: ldapsearch -Y EXTERNAL -H ldapi:/// -b ou=virtual,dc=ldap,dc=local
