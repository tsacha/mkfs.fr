ssh bak private key:
  file.managed:
    - name: /root/.ssh/bak
    - user: root
    - group: root
    - mode: '0600'
    - source: 'salt://private/ssh/bak'
    - makedirs: true

{% if pillar['bak']['paths'][grains['nodename']] is defined %}
bak-paths.timer:
  file.managed:
{% if grains['os'] == 'Fedora' %}
    - name: /usr/lib/systemd/system/bak-paths.timer
{% elif grains['os'] == 'Debian' %}
    - name: /lib/systemd/system/bak-paths.timer
{% endif %}
    - user: root
    - group: root
    - template: jinja
    - source: 'salt://bak/timer'
    - watch_in:
      - cmd: systemd reload

start bak paths timer:
  service.running:
    - name: bak-paths.timer
    - enable: true
    - require:
      - file: bak-paths.timer

bak-paths.service:
  file.managed:
{% if grains['os'] == 'Fedora' %}
    - name: /usr/lib/systemd/system/bak-paths.service
{% elif grains['os'] == 'Debian' %}
    - name: /lib/systemd/system/bak-paths.service
{% endif %}
    - user: root
    - group: root
    - template: jinja
    - source: 'salt://bak/service'
    - watch_in:
      - cmd: systemd reload
{% endif %}
