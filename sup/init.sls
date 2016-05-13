# On Fedora 24, icinga2 packages are still not available
# From Fedora 24 :
# dnf install ncurses-compat-libs
# From Fedora 23 :
# > boost-chrono
# > boost-system
# > boost-thread
# > dyninst
# > systemtap
# > systemtap-client
# > systemtap-devel
# > systemtap-runtime
# > httpd
# > boost-program-options
# > boost-regex
# > gd
# > httpd-filesystem
# > httpd-tools
# > libicu
# > libvpx
# > php
# > php-bcmath
# > php-cli
# > php-common
# > php-gd
# > php-intl
# > php-ldap
# > php-mysqlnd
# > php-pdo
# > php-pgsql
# > php-process
# > php-xml
# Then, freeze theses packages in dnf.conf
# Not compatible with php7 — yet.

icinga-repo:
  pkgrepo.managed:
    - humanname: Icinga Stable
    - baseurl: http://packages.icinga.org/fedora/23/release/ 
    - gpgcheck: 1
    - gpgkey: http://packages.icinga.org/icinga.key

icinga.packages:
  pkg.installed:
    - pkgs:
      - icinga2-bin
      - icinga2-common
      - icinga2-ido-pgsql
      - icingaweb2
      - php-ldap

/var/log/httpd:
  file.directory:
    - user: apache
    - group: apache
    - mode: 775
    - require:
      - pkg: icinga.packages

/usr/bin/ping:
  file.managed:
    - mode: '4755'

/var/run/icinga2/cmd:
  file.directory:
    - user: apache
    - group: icingacmd
    - mode: 775
    - require:
      - pkg: icinga.packages


/etc/php.ini:
  file.managed:
    - source: 'salt://sup/php.ini'
    - require:
      - pkg: icinga.packages

httpd:
  service.running:
    - enable: true
    - reload: true
    - require:
      - file: /var/log/httpd
      - file: /etc/php.ini

icinga2:
  service.running:
    - enable: true
    - require:
      - pkg: icinga.packages


{% for cert in pillar['certs'] %}
im crt {{ cert }}:
  file.copy:
    - name: /etc/icinga2/pki/{{ cert }}.crt
    - user: icinga
    - group: icinga
    - mode: 644
    - makedirs: true
    - force: true
    - source: /etc/ssl/certs/{{ cert }}.crt
    - require:
      - pkg: icinga.packages
      - file: crt {{ cert }}
    - watch:
      - file: crt {{ cert }}
    - require_in:
      - service: icinga2
    - watch_in:
      - service: icinga2

im key {{ cert }}:
  file.copy:
    - name: /etc/icinga2/pki/{{ cert }}.key
    - user: icinga
    - group: icinga
    - mode: 400
    - makedirs: true
    - force: true
    - source: /etc/ssl/private/{{ cert }}.key
    - require:
      - pkg: icinga.packages
      - file: crt {{ cert }}
    - watch:
      - file: key {{ cert }}
    - require_in:
      - service: icinga2
    - watch_in:
      - service: icinga2
    - makedirs: true
{% endfor %}


{% set icinga_conf = [
  'app.conf',
  'commands.conf',
  'downtimes.conf',
  'groups.conf',
  'hosts.conf',
  'notifications.conf',
  'satellite.conf',
  'services.conf',
  'templates.conf',
  'timeperiods.conf',
  'users.conf',
  'zones.conf'
] %}

{% for file in icinga_conf %}
/etc/icinga2/conf.d/{{ file }}:
  file.managed:
    - user: icinga
    - group: icinga
    - mode: 644
    - require:
      - pkg: icinga.packages
    - require_in:
      - service: icinga2
    - watch_in:
      - service: icinga2
    - template: jinja
    - source: 'salt://sup/configuration/{{ file }}'
{% endfor %}