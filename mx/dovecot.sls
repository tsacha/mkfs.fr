{% set dovecot_conf = [
  '10-auth.conf',
  '10-director.conf',
  '10-logging.conf',
  '10-mail.conf',
  '10-master.conf',
  '10-ssl.conf',
  '15-lda.conf',
  '15-mailboxes.conf',
  '20-imap.conf',
  '20-lmtp.conf',
  '20-managesieve.conf',
  '20-pop3.conf',
  '90-acl.conf',
  '90-plugin.conf',
  '90-quota.conf',
  '90-sieve.conf',
  '90-sieve-extprograms.conf',
  'auth-checkpassword.conf.ext',
  'auth-deny.conf.ext',
  'auth-dict.conf.ext',
  'auth-ldap.conf.ext',
  'auth-master.conf.ext',
  'auth-passwdfile.conf.ext',
  'auth-sql.conf.ext',
  'auth-static.conf.ext',
  'auth-system.conf.ext',
  'auth-vpopmail.conf.ext'
] %}


{% for file in dovecot_conf %}
/etc/dovecot/conf.d/{{ file }}:
  file.managed:
    - user: dovecot
    - group: dovecot
    - mode: 644
    - require:
      - pkg: dovecot
    - require_in:
      - service: start dovecot
    - watch_in:
      - service: start dovecot
    - template: jinja
    - source: 'salt://mx/dovecot/{{ file }}'
{% endfor %}

/etc/dovecot/dovecot.conf:
  file.managed:
    - user: dovecot
    - group: dovecot
    - mode: 644
    - require:
      - pkg: dovecot
    - require_in:
      - service: start dovecot
    - watch_in:
      - service: start dovecot
    - template: jinja
    - source: 'salt://mx/dovecot/dovecot.conf'

/etc/dovecot/dovecot-ldap.conf:
  file.managed:
    - user: dovecot
    - group: dovecot
    - mode: 644
    - require:
      - pkg: dovecot
    - require_in:
      - service: start dovecot
    - watch_in:
      - service: start dovecot      
    - template: jinja
    - source: 'salt://mx/dovecot/dovecot-ldap.conf'

/srv/vmails/global.sieve:
  file.managed:
    - user: vmails
    - group: vmails
    - mode: 644
    - require:
      - file: /srv/vmails
    - template: jinja
    - source: 'salt://mx/dovecot/global.sieve'

start dovecot:
  service.running:
    - name: dovecot
    - require:
      - pkg: dovecot
      - pkg: dovecot-pigeonhole
    - enable: true
    - provider: systemd