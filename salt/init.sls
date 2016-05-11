---
salt minion unit file:
  file.managed:
{% if grains['os'] == 'Fedora' %}
    - name: /usr/lib/systemd/system/salt-minion.service
{% elif grains['os'] == 'Debian' %}
    - name: /lib/systemd/system/salt-minion.service
{% endif %}    
    - user: root
    - group: root
    - mode: '0644'
    - source: 'salt://salt/salt-minion.service'

{% if grains['nodename'] == 'salt.local' %}
salt master unit file:
  file.managed:
    - name: /usr/lib/systemd/system/salt-master.service
    - user: root
    - group: root
    - mode: '0644'
    - source: 'salt://salt/salt-master.service'

dynamic ip timer:
  file.managed:
    - name: /usr/lib/systemd/system/setip.timer
    - user: root
    - group: root
    - mode: '0644'
    - source: 'salt://salt/setip.timer'

dynamic ip service:
  file.managed:
    - name: /usr/lib/systemd/system/setip.service
    - user: root
    - group: root
    - mode: '0644'
    - source: 'salt://salt/setip.service'

dynamic ip script:
  file.managed:
    - name: /opt/ips/setip.py
    - user: root
    - group: root
    - mode: '0750'
    - source: 'salt://salt/setip.py'

active dynamic ip:
  service.running:
    - name: setip.timer
    - enable: true
    - require:
      - file: dynamic ip script
      - file: dynamic ip service
      - file: dynamic ip timer
{% endif %}