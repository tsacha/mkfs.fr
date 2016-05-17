telegraf:
  pkg.installed

telegraf configuration:
  file.managed:
    - name: /etc/telegraf/telegraf.conf
    - user: root
    - group: root
    - mode: 644
    - source: 'salt://sup/telegraf/telegraf.conf'
    - template: jinja
    - require:
      - pkg: telegraf
    - watch_in:
      - service: start telegraf

start telegraf:
  service.running:
    - name: telegraf
    - enable: true
    - require:
      - file: telegraf configuration