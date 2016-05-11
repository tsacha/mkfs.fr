prosody-repo:
  pkgrepo.managed:
    - humanname: Prosody
    - name: deb http://packages.prosody.im/debian sid main
    - key_url: https://prosody.im/files/prosody-debian-packages.key

prosody-trunk:
  pkg.installed:
    - require:
      - pkgrepo: prosody-repo
dependencies prosody:
  pkg.installed:
    - pkgs:
      - lua-bit32
      - lua-ldap
      - lua-sec-prosody
      - lua-filesystem
      - lua-expat
      - lua-socket
      - lua-dbi-postgresql
      - mercurial

{% for cert in pillar['certs'] %}
im crt {{ cert }}:
  file.copy:
    - name: /etc/prosody/certs/{{ cert }}.crt
    - user: prosody
    - group: prosody
    - mode: 644
    - makedirs: true
    - force: true
    - source: /etc/ssl/certs/{{ cert }}.crt
    - pkg:
      - pkg: prosody-trunk
      - file: crt {{ cert }}
    - watch:
      - file: crt {{ cert }}
    - require_in:
      - service: start prosody
    - watch_in:
      - service: start prosody

im key {{ cert }}:
  file.copy:
    - name: /etc/prosody/certs/{{ cert }}.key
    - user: prosody
    - group: prosody
    - mode: 400
    - makedirs: true
    - force: true
    - source: /etc/ssl/private/{{ cert }}.key
    - require:
      - pkg: prosody-trunk
      - file: crt {{ cert }}
    - watch:
      - file: key {{ cert }}
    - require_in:
      - service: start prosody
    - watch_in:
      - service: start prosody
    - makedirs: true
{% endfor %}

im generate dh:
  cmd.run:
    - user: prosody
    - name: openssl dhparam -out dhparams.pem 4096
    - cwd: /etc/prosody/certs/
    - unless: stat dhparams.pem
    - timeout: 7200
    - require:
      - pkg: prosody-trunk

config:
  file.managed:
    - name: /etc/prosody/prosody.cfg.lua
    - user: prosody
    - group: prosody
    - mode: 644
    - source: 'salt://im/prosody.cfg.lua'
    - template: jinja
    - watch_in:
      - service: start prosody
    - require_in:
      - service: start prosody
      - hg: download modules


start prosody:
  service.running:
    - name: prosody
    - enable: prosody
    - reload: true
    - require:
      - pkg: prosody-trunk

/opt/prosody:
  file.directory:
    - user: prosody
    - group: prosody
    - mode: 775
    - require:
      - pkg: prosody-trunk

download modules:
  hg.latest:
    - name: https://hg.prosody.im/prosody-modules/
    - target: /opt/prosody/modules
    - user: prosody
    - require:
      - file: /opt/prosody
# 
# # 
# # 
# # #auth_ldap:
# # #  file.managed:
# # #    - name: /lib/prosody/modules/mod_auth_ldap2.lua
# # #    - user: prosody
# # #    - group: prosody
# # #    - mode: 644
# # #    - source: 'salt://im/mod_auth_ldap2.lua'
# # #    - template: jinja
# # #
# # #lib_ldap:
# # #  file.managed:
# # #    - name: /opt/prosody/lib/prosody/modules/ldap.lib.lua
# # #    - user: prosody
# # #    - group: prosody
# # #    - mode: 644
# # #    - source: 'salt://im/ldap.lib.lua'
# # #    - template: jinja