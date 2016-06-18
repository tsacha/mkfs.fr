{% if pillar['certs'] is defined and pillar['certs'] %}
{% for cert in pillar['certs'] %}
ca {{ cert }}:
  file.managed:
    - name: /etc/ssl/ca/{{ cert }}.ca
    - user: root
    - group: root
    - mode: 644
    - makedirs: true
    - force: true
    - source: 'salt://private/certs/{{ cert }}/ca.cer'

crt {{ cert }}:
  file.managed:
    - name: /etc/ssl/certs/{{ cert }}.crt
    - user: root
    - group: root
    - mode: 644
    - makedirs: true
    - force: true
    - source: 'salt://private/certs/{{ cert }}/fullchain.cer'

key {{ cert }}:
  file.managed:
    - name: /etc/ssl/private/{{ cert }}.key
    - user: root
    - group: root
    - mode: 400
    - makedirs: true
    - makedirs: true
    - force: true
    - source: 'salt://private/certs/{{ cert }}/{{ cert }}.key'
{% endfor %}
{% endif %}