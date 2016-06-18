cloud configuration:
  file.managed:
    - name: /etc/nginx/conf.d/cloud.conf
    - require:
      - pkg: nginx
    - watch_in:
      - service: start nginx
    - source: 'salt://cloud/cloud.conf'

cron service:
  file.managed:
    - name: /etc/systemd/system/cron-owncloud.service
    - require:
      - pkg: nginx
    - source: 'salt://cloud/cron.service'

cron timer:
  file.managed:
    - name: /etc/systemd/system/cron-owncloud.timer
    - require:
      - pkg: nginx
    - source: 'salt://cloud/cron.timer'

start timer:
  service.running:
    - name: cron-owncloud.timer
    - enable: true