{% if grains['os'] == 'Fedora' %}
nginx-repo:
  pkgrepo.managed:
    - humanname: Nginx Mainline
    - baseurl: https://copr-be.cloud.fedoraproject.org/results/cbrspc/nginx-mainline/fedora-23-$basearch/
    - gpgcheck: 1
    - gpgkey: https://copr-be.cloud.fedoraproject.org/results/cbrspc/nginx-mainline/pubkey.gpg
    - require_in:
      - pkg: nginx

{% set nginx_user = 'nginx' %}
{% elif grains['os'] == 'Debian' %}
{% set nginx_user = 'www-data' %}
{% endif %}

nginx:
  pkg.installed:
{% if grains['os'] == 'Fedora' %}  
    - name: nginx-mainline
{% elif grains['os'] == 'Debian' %}
    - name: nginx
{% endif %}

generate dh:
  cmd.run:
    - name: openssl dhparam -out dhparams.pem 4096
    - cwd: /etc/nginx/
    - unless: stat dhparams.pem
    - timeout: 7200
    - require:
      - pkg: nginx

nginx configuration:
  file.managed:
    - name: /etc/nginx/nginx.conf
    - template: jinja
    - source: 'salt://nginx/nginx.conf.template'
    - watch_in:
      - service: start nginx

start nginx:
  service.running:
    - name: nginx
    - enable: true
    - reload: true
    - require:
      - file: nginx configuration
      - cmd: generate dh
      - pkg: nginx
