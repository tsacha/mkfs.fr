---
{% if grains['os'] == 'Fedora' %}
salt minion unit file:
  file.managed:
    - name: /usr/lib/systemd/system/salt-minion.service
    - user: root
    - group: root
    - mode: '0644'
    - template: jinja
    - source: 'salt://salt/salt-minion.service'

{% for salt_bin in ['salt','salt-api','salt-call','salt-cloud','salt-cp','salt-key','salt-master','salt-minion','salt-proxy','salt-run','salt-ssh','salt-syndic','salt-unity'] %}
/usr/local/bin/{{ salt_bin }}:
  file.symlink:
    - target: /opt/venv/bin/{{ salt_bin }}
{% endfor %}
{% elif grains['os'] == 'Debian' %}
salt minion unit file:
  file.managed:
    - name: /lib/systemd/system/salt-minion.service
    - user: root
    - group: root
    - mode: '0644'
    - template: jinja
    - source: 'salt://salt/salt-minion.service'
/etc/init.d/salt-minion:
  file.absent
{% endif %}    

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