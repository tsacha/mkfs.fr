include:
  - nginx.nginx

{% if grains['os'] == 'Fedora' %}
{% set nginx_user = 'nginx' %}
{% elif grains['os'] == 'Debian' %}
{% set nginx_user = 'www-data' %}
{% endif %}

/srv/certs:
  file.directory:
    - user: {{ nginx_user }}
    - group: {{ nginx_user }}
    - mode: 775
    - require:
      - pkg: nginx

{% if not pillar['disable_tls'] %}
{% for cert in pillar['certs'] %}
nginx crt {{ cert }}:
  file.copy:
    - name: /etc/nginx/certs/{{ cert }}.crt
    - user: {{ nginx_user }}
    - group: {{ nginx_user }}
    - mode: 644
    - makedirs: true
    - force: true
    - source: /etc/ssl/certs/{{ cert }}.crt
    - require:
      - file: crt {{ cert }}
    - watch:
      - file: crt {{ cert }}
    - require_in:
      - service: start nginx
    - watch_in:
      - service: start nginx

nginx key {{ cert }}:
  file.copy:
    - name: /etc/nginx/private/{{ cert }}.key
    - user: {{ nginx_user }}
    - group: {{ nginx_user }}
    - mode: 400
    - makedirs: true
    - force: true
    - source: /etc/ssl/private/{{ cert }}.key
    - require:
      - file: key {{ cert }}
    - watch:
      - file: key {{ cert }}
    - require_in:
      - service: start nginx
    - watch_in:
      - service: start nginx
    - makedirs: true
{% endfor %}
{% endif %}
