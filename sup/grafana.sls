grafana-repo:
  pkgrepo.managed:
    - humanname: Grafana
    - baseurl: https://packagecloud.io/grafana/stable/el/7/$basearch
    - gpgcheck: 0

grafana:
  pkg.installed:
    - require:
      - pkgrepo: grafana-repo

start grafana:
  service.running:
    - name: grafana-server
    - enable: true
    - require:
      - pkg: grafana
    