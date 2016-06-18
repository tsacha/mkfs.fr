mariadb-server:
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
    - onlyif:
      - mysql -B --password="{{ pillar['mariadb']['pwd'] }}" mysql -e "show tables;"'
    - require:
      - service: mariadb

mysql-secure-installation:
  mysql_database.absent:
    - name: test
    - connection_pass: "{{ pillar['mariadb']['pwd'] }}"
    - require:
      - service: mariadb
      - mysql_user: set_localhost_root_password
  mysql_user.absent:
    - name: ""
    - connection_pass: "{{ pillar['mariadb']['pwd'] }}"
    - require:
      - service: mariadb
      - mysql_user: set_localhost_root_password


