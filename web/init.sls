include:
  - nginx.nginx

remi:
  pkgrepo.managed:
    - humanname: Remi
    - baseurl: http://rpms.remirepo.net/fedora/$releasever/remi/$basearch/
    - gpgcheck: 1
    - gpgkey: http://rpms.remirepo.net/RPM-GPG-KEY-remi

remi-php7:
  pkgrepo.managed:
    - humanname: Remi PHP7
    - baseurl: http://rpms.remirepo.net/fedora/$releasever/php70/$basearch/
    - gpgcheck: 1
    - gpgkey: http://rpms.remirepo.net/RPM-GPG-KEY-remi

php.packages:
  pkg.installed:
    - pkgs:
      - php
      - php-fpm
      - php-pdo
      - php-pecl-zip
      - php-gd
      - php-pgsql
      - php-xml
      - php-intl
      - php-ldap
      - php-mysqlnd
      - php-mbstring
      - php-pecl-mysql
      - php-pecl-pq
      - php-process
      - php-pecl-imagick
      - php-pecl-apcu
    - require:
      - pkgrepo: remi
      - pkgrepo: remi-php7


configure php:
  file.managed:
    - name: /etc/php.ini
    - require:
      - pkg: php.packages
    - source: 'salt://web/php.ini'
    - watch_in:
      - service: start php fpm

configure www php fpm:
  file.managed:
    - name: /etc/php-fpm.d/www.conf
    - require:
      - pkg: php.packages
    - source: 'salt://web/www.conf'
    - watch_in:
      - service: start php fpm

start php fpm:
  service.running:
    - name: php-fpm
    - enable: true
    - require:
      - file: configure www php fpm
      - file: configure php
