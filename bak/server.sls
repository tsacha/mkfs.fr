bak:
  group.present:
    - gid: 2000
  user.present:
    - home: /srv/bak
    - uid: 2000
    - gid: 2000
    - require:
      - group: bak
    - shell: /bin/bash

/srv/bak/live:
  file.directory:
    - user: bak
    - group: bak
    - mode: 700
    - makedirs: True
    - require:
      - user: bak
      - group: bak

{% for path in pillar['bak']['paths'] %}
/srv/bak/live/{{ path }}:
  file.directory:
    - user: bak
    - group: bak
    - mode: 700
    - makedirs: True
    - require:
      - user: bak
      - group: bak
{% endfor %}

ssh bak authorized_keys:
  file.managed:
    - name: /srv/bak/.ssh/authorized_keys
    - user: bak
    - group: bak
    - mode: '0640'
    - require:
      - file: /srv/bak/live
    - source: 'salt://private/ssh/bak.pub'
    - makedirs: true

snapper:
  pkg.installed

snapper cleanup:
  service.running:
    - name: snapper-cleanup.timer
    - enable: true
    - require:
      - pkg: snapper

snapper timeline:
  service.running:
    - name: snapper-timeline.timer
    - enable: true
    - require:
      - pkg: snapper

live-configuration-snapper:
  file.managed:
    - name: /etc/snapper/configs/live
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - source: 'salt://bak/snapper/live'
    - require:
      - pkg: snapper
    - require_in:
      - service: snapper timeline
    - watch_in:
      - service: snapper timeline

sysconfig-snapper:
  file.managed:
    - name: /etc/sysconfig/snapper
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - source: 'salt://bak/snapper/sysconfig'
    - require:
      - pkg: snapper
    - require_in:
      - service: snapper timeline
    - watch_in:
      - service: snapper timeline