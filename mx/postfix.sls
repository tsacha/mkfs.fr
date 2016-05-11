/etc/postfix/main.cf:
  file.managed:
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: postfix
    - require_in:
      - service: start postfix
    - watch_in:
      - service: start postfix      
    - template: jinja
    - source: 'salt://mx/postfix/main.cf'

/etc/postfix/master.cf:
  file.managed:
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: postfix
    - require_in:
      - service: start postfix
    - watch_in:
      - service: start postfix
    - template: jinja
    - source: 'salt://mx/postfix/master.cf'

/etc/postfix/ldap-domains.cf:
  file.managed:
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: postfix
    - require_in:
      - service: start postfix
    - watch_in:
      - service: start postfix      
    - template: jinja
    - source: 'salt://mx/postfix/ldap-domains.cf'

/etc/postfix/ldap-accounts.cf:
  file.managed:
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: postfix
    - require_in:
      - service: start postfix
    - watch_in:
      - service: start postfix
    - template: jinja
    - source: 'salt://mx/postfix/ldap-accounts.cf'

/etc/postfix/ldap-aliases.cf:
  file.managed:
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: postfix
    - require_in:
      - service: start postfix
    - watch_in:
      - service: start postfix
    - template: jinja
    - source: 'salt://mx/postfix/ldap-aliases.cf'

start postfix:
  service.running:
    - name: postfix
    - enable: true
    - provider: systemd
