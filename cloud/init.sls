cloud configuration:
  file.managed:
    - name: /etc/nginx/conf.d/cloud.conf
    - require:
      - pkg: nginx
    - watch_in:
      - service: start nginx
    - source: 'salt://cloud/cloud.conf'