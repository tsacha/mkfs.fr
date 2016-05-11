{% if pillar['postgres']['dbs'] is defined and pillar['postgres']['dbs'] %}
/usr/lib/systemd/system/bak-postgres.timer:
  file.managed:
    - user: root
    - group: root
    - template: jinja
    - source: 'salt://bak/timer-postgres'
    - watch_in:
      - cmd: systemd reload

start bak postgres timer:
  service.running:
    - name: bak-postgres.timer
    - enable: true
    - require:
      - file: /usr/lib/systemd/system/bak-postgres.timer

/usr/lib/systemd/system/bak-postgres.service:
  file.managed:
    - user: root
    - group: root
    - template: jinja
    - source: 'salt://bak/service-postgres'
    - watch_in:
      - cmd: systemd reload
{% endif %}