mariadb-server:
  pkg.installed

python2-PyMySQL:
  pkg.installed

mariadb:
  service.running:
    - enable: true
    - provider: systemd

set_localhost_root_password:
  mysql_user.present:
    - name: root
    - host: localhost
    - password: {{ pillar['mariadb']['pwd'] }}
    - connection_pass: ""
    - require:
      - service: mariadb

mysql-secure-installation:
  mysql_database.absent:
    - name: test
    - connection_pass: "{{ pillar['mariadb']['pwd'] }}"
    - require:
      - service: mariadb
      - mysql_user: set_localhost_root_password
      - pkg: python2-PyMySQL
  mysql_user.absent:
    - name: ""
    - connection_pass: "{{ pillar['mariadb']['pwd'] }}"
    - require:
      - service: mariadb
      - mysql_user: set_localhost_root_password
      - pkg: python2-PyMySQL

