bind:
  pkg.installed

python-ipaddress:
  pkg.installed

named:
  service.running:
    - enable: true
    - require:
      - pkg: bind
    - provider: systemd

/etc/named.conf:
  file.managed:
    - user: root
    - group: root
    - mode: '0644'
    - template: jinja
    - source: 'salt://dns/named.template'
    - require:
      - pkg: bind
    - watch_in:
      - service: named

/etc/named.zones.source:
  file.managed:
    - user: named
    - group: named
    - mode: '0644'
    - template: jinja
    - source: 'salt://dns/include.template'
    - defaults:
      zones: [{% for zone in pillar['zones'] %}{% if zone != 'common' %}{{ zone }}, {% endif %}{% endfor %}{% for host in pillar['network']['physical'] %}reverse6-{{ host }}.local., {% endfor %} 'reverse4.local.', 'local.']
    - watch_in:
      - cmd: reverse6 zones      
    - require:
      - pkg: bind
      
reverse6 zones:
  cmd.wait:
    - name: /etc/named/convert-ptr6.py zones
    - require:
      - file: /etc/named/convert-ptr6.py
    - watch_in:
      - service: named

/etc/named:
  file.directory:
    - user: named
    - group: named
    - mode: '0770'
    - require:
      - pkg: bind
    - watch_in:
      - service: named

/etc/named/convert-ptr6.py:
  file.managed:
    - user: named
    - group: named
    - mode: '0550'
    - template: jinja
    - source: 'salt://dns/convert-ptr6.py'
    - require:
      - pkg: bind

/etc/named/zone.reverse4.local.:
  file.managed:
    - user: named
    - group: named
    - mode: '0660'
    - template: jinja
    - source: 'salt://dns/reverse4.template'
    - require:
      - pkg: bind
    - watch_in:
      - service: named

{% if pillar['network']['hosts'][grains['nodename']]['host'] == "master" %}
/etc/named/dkim:
  file.directory:
    - user: named
    - group: named
    - mode: '0770'
    - require:
      - pkg: bind

/etc/named/keys:
  file.directory:
    - user: named
    - group: named
    - mode: '0770'
    - require:
      - pkg: bind

{% for host in pillar['network']['physical'] %}
/etc/named/reverse6-{{ host }}.source:
  file.managed:
    - user: named
    - group: named
    - mode: '0660'
    - template: jinja
    - defaults:
      host: {{ host }}
    - source: 'salt://dns/reverse6.template'
    - require:
      - pkg: bind
    - watch_in:
      - cmd: reverse6 {{ host }}
reverse6 {{ host }}:
  cmd.wait:
    - name: /etc/named/convert-ptr6.py {{ host }}
    - require:
      - file: /etc/named/convert-ptr6.py
    - watch_in:
      - service: named
{% endfor %}

/etc/named/zone.local.:
  file.managed:
    - user: named
    - group: named
    - mode: '0660'
    - template: jinja
    - source: 'salt://dns/local.template'
    - require:
      - pkg: bind
    - watch_in:
      - service: named

{% for zone in pillar['zones'] %}
{% if zone != 'common' and zone != 'local.' %}

{% if pillar['zones'][zone]['dkim'] is defined %}
/etc/named/dkim/{{ zone }}.txt:
  file.managed:
    - user: named
    - group: named
    - mode: '0660'
    - template: jinja
    - source: 'salt://private/dkim/{{ zone }}/{{ pillar['zones'][zone]['dkim'] }}.txt'
    - require:
      - file: /etc/named/dkim
    - watch_in:
      - service: named  
{% endif %}

{% if (pillar['zones'][zone]['dnssec'] is defined) and (pillar['zones'][zone]['dnssec']) %}
/etc/named/keys/K{{ zone }}+00{{ pillar['zones'][zone]['algo'] }}+{{ pillar['zones'][zone]['ksk'] }}.key:
  file.managed:
    - user: named
    - group: named
    - mode: '0660'
    - template: jinja
    - source: 'salt://private/dnssec/{{ zone }}/ksk.key'
    - require:
      - file: /etc/named/keys
    - watch_in:
      - service: named
/etc/named/keys/K{{ zone }}+00{{ pillar['zones'][zone]['algo'] }}+{{ pillar['zones'][zone]['ksk'] }}.private:
  file.managed:
    - user: named
    - group: named
    - mode: '0660'
    - template: jinja
    - source: 'salt://private/dnssec/{{ zone }}/ksk.private'
    - require:
      - file: /etc/named/keys
    - watch_in:
      - service: named

/etc/named/keys/K{{ zone }}+00{{ pillar['zones'][zone]['algo'] }}+{{ pillar['zones'][zone]['zsk'] }}.key:
  file.managed:
    - user: named
    - group: named
    - mode: '0660'
    - template: jinja
    - source: 'salt://private/dnssec/{{ zone }}/zsk.key'
    - require:
      - file: /etc/named/keys
    - watch_in:
      - service: named

/etc/named/keys/K{{ zone }}+00{{ pillar['zones'][zone]['algo'] }}+{{ pillar['zones'][zone]['zsk'] }}.private:
  file.managed:
    - user: named
    - group: named
    - mode: '0660'
    - template: jinja
    - source: 'salt://private/dnssec/{{ zone }}/zsk.private'
    - require:
      - file: /etc/named/keys
    - watch_in:
      - service: named

{% if (pillar['zones'][zone]['nsec3'] is defined) and (pillar['zones'][zone]['nsec3']) %}
nsec3 {{ zone }}:
  cmd.wait:
    - name: /usr/sbin/rndc signing -nsec3param 1 0 10 $(head -c 1000 /dev/urandom | sha1sum | cut -b 1-8) {{ zone }}
    - require:
      - service: named
{% endif %}

{% endif %}

/etc/named/zone.{{ zone }}:
  file.managed:
    - user: named
    - group: named
    - mode: '0660'
    - template: jinja
    - source: 'salt://dns/zone.template'
    - defaults:
      zone: ['common', {{ zone }}]
    - require:
      - pkg: bind
    - watch_in:
      - service: named
{% if (pillar['zones'][zone]['dnssec'] is defined) and (pillar['zones'][zone]['dnssec']) and (pillar['zones'][zone]['nsec3'] is defined) and (pillar['zones'][zone]['nsec3']) %}
      - cmd: nsec3 {{ zone }}
{% endif %}      
{% endif %}
{% endfor %}
{% endif %}