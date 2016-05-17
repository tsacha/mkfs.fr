influxdb:
  pkg.installed

start influxdb:
  service.running:
    - name: influxdb
    - enable: true
    - require:
      - pkg: influxdb