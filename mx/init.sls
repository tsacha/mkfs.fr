dovecot:
  pkg.installed

dovecot-pigeonhole:
  pkg.installed

dovecot-antispam:
  pkg.installed:
    - sources:
      - dovecot-antispam: 'salt://mx/dovecot-antispam/RPMS/x86_64/dovecot-antispam-2.0-2.fc24.x86_64.rpm'


# dovecot-antispam-repo:
#   pkgrepo.managed:
#     - humanname: Dovecot Antipam
#     - baseurl: 
#     - gpgcheck: 1
#     - gpgkey: 

postfix:
  pkg.installed

postfix-ldap:
  pkg.installed

opendkim:
  pkg.installed

openldap:
  pkg.installed

openldap-clients:
  pkg.installed

# rspamd-experimental-repo:
#   pkgrepo.managed:
#     - humanname: RSpamd Experimental
#     - baseurl: http://rspamd.com/rpm/fedora-23/x86_64/
#     - gpgcheck: 1
#     - gpgkey: http://rspamd.com/rpm/gpg.key


rspamd-repo:
  pkgrepo.managed:
    - humanname: RSpamd Stable
    - baseurl: http://rspamd.com/rpm-stable/fedora-23/x86_64/
    - gpgcheck: 1
    - gpgkey: http://rspamd.com/rpm-stable/gpg.key

rspamd:
  pkg.installed:
    - require:
      - pkgrepo: rspamd-repo

rmilter:
  pkg.installed:
    - require:
      - pkg: rspamd
      - pkgrepo: rspamd-repo

redis:
  pkg.installed

/etc/openldap/ldap.conf:
  file.managed:
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: openldap
    - template: jinja
    - source: 'salt://ldap/config/ldap.conf.template'

pypolicyd-spf:
  pkg.installed

/srv:
  file.directory:
    - user: root
    - group: root
    - mode: 775
    
vmails:
  group.present:
    - gid: 5000
  user.present:
    - home: /srv/vmails
    - uid: 5000
    - gid: 5000
    - require:
      - file: /srv
      - group: vmails
    - shell: /sbin/nologin

/srv/vmails:
  file.directory:
    - user: vmails
    - group: vmails
    - mode: 775
    - makedirs: True
    - require:
      - user: vmails
      - group: vmails

mx crt:
  file.managed:
    - name: /etc/dovecot/{{ pillar['mx']['cert'] }}.crt
    - user: root
    - group: root
    - mode: 440
    - source: 'salt://private/certs/live/{{ pillar['mx']['cert'] }}/cert.pem'
    - require:
      - pkg: dovecot    
    - require_in:
      - service: dovecot
      - service: postfix
    - watch_in:
      - service: dovecot
      - service: postfix
mx ca:
  file.managed:
    - name: /etc/dovecot/{{ pillar['mx']['cert'] }}.ca.crt
    - user: root
    - group: root
    - mode: 440
    - source: 'salt://private/certs/live/{{ pillar['mx']['cert'] }}/chain.pem'
    - require:
      - pkg: dovecot    
    - require_in:
      - service: dovecot
      - service: postfix
    - watch_in:
      - service: dovecot
      - service: postfix

mx key:
  file.managed:
    - name: /etc/dovecot/{{ pillar['mx']['cert'] }}.key
    - user: root
    - group: root
    - mode: 440
    - source: 'salt://private/certs/live/{{ pillar['mx']['cert'] }}/privkey.pem'
    - require:
      - pkg: dovecot
    - require_in:
      - service: dovecot
      - service: postfix
    - watch_in:
      - service: dovecot
      - service: postfix

include:
  - mx.postfix
  - mx.dovecot
  - mx.misc  
  - mx.dkim