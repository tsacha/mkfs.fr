{% if pillar['mariadb']['dbs'] is defined and pillar['mariadb']['dbs'] %}
/usr/lib/systemd/system/bak-mariadb.timer:
  file.managed:
    - user: root
    - group: root
    - template: jinja
    - source: 'salt://bak/timer-mariadb'
    - watch_in:
      - cmd: systemd reload

start bak mariadb timer:
  service.running:
    - name: bak-mariadb.timer
    - enable: true
    - require:
      - file: /usr/lib/systemd/system/bak-mariadb.timer

/usr/lib/systemd/system/bak-mariadb.service:
  file.managed:
    - user: root
    - group: root
    - template: jinja
    - source: 'salt://bak/service-mariadb'
    - watch_in:
      - cmd: systemd reload
{% endif %}