grafana-repo:
  pkgrepo.managed:
    - humanname: Grafana
    - baseurl: https://packagecloud.io/grafana/stable/el/7/$basearch
    - gpgcheck: 0

grafana:
  pkg.installed:
    - require:
      - pkgrepo: grafana-repo

grafana configuration:
  file.managed:
    - name: /etc/grafana/grafana.ini
    - user: root
    - group: grafana
    - mode: 644
    - require:
      - pkg: grafana
    - template: jinja
    - source: 'salt://sup/grafana.ini'

grafana ldap integration:
  file.managed:
    - name: /etc/grafana/ldap.toml
    - user: root
    - group: grafana
    - mode: 644
    - require:
      - pkg: grafana
    - template: jinja
    - source: 'salt://sup/ldap.toml'

start grafana:
  service.running:
    - name: grafana-server
    - enable: true
    - require:
      - file: grafana configuration
      - file: grafana ldap integration