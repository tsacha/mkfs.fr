systemd-networkd:
  service.running:
    - enable: true

{%- if grains['virtual'] == 'physical' %}
  {%- for host in pillar['network']['hosts'] %}
    {%- if pillar['network']['hosts'][host]['virtual'] == "physical" and host != grains['id'] %} 
      {%- if 'grains' in pillar['network']['hosts'][host]['ip'][0] %}
        {%- if grains[pillar['network']['hosts'][host]['ip'][0].split(':')[1]] is defined %}
          {%- set remote = grains[pillar['network']['hosts'][host]['ip'][0].split(':')[1]] %}
        {%- endif %}
      {%- else %}
        {%- set remote = pillar['network']['hosts'][host]['ip'][0] %}
      {%- endif %}
      
      gre netdev to {{ host }}:
        file.managed:
          - id: {{ pillar['network']['hosts'][grains['id']]['id'] }}
          - rid: {{ pillar['network']['hosts'][host]['id'] }}
          - remote: {{ remote }}
          - name: /etc/systemd/network/gre{{ pillar['network']['hosts'][grains['id']]['id'] }}{{ pillar['network']['hosts'][host]['id'] }}.netdev
          - template: jinja
          - source: 'salt://base/gre.netdev'
          - user: root
          - group: root
          - mode: '0644'
          - require_in:
            - service: systemd-networkd
          - watch_in:
            - service: systemd-networkd
      
      gre network to {{ host }}:
        file.managed:
          - id: {{ pillar['network']['hosts'][grains['id']]['id'] }}
          - rid: {{ pillar['network']['hosts'][host]['id'] }}
          - rprivate: {{ pillar['network']['physical'][pillar['network']['hosts'][host]['host']]['private_ip4'] }}
          - name: /etc/systemd/network/gre{{ pillar['network']['hosts'][grains['id']]['id'] }}{{ pillar['network']['hosts'][host]['id'] }}.network
          - template: jinja
          - source: 'salt://base/gre.network'
          - user: root
          - group: root
          - mode: '0644'
          - require_in:
            - service: systemd-networkd
          - watch_in:
            - service: systemd-networkd
    {%- endif %}
  {%- endfor %}
{%- else %}
interface configuration:
  file.managed:
    - name: /etc/systemd/network/{{ pillar['network']['LXC'][pillar['network']['hosts'][grains['id']]['host']]['int'] }}.network
    - template: jinja
    - source: 'salt://base/lxc-int.network'
    - user: root
    - group: root
    - mode: '0644'
    - require_in:
      - service: systemd-networkd
    - watch_in:
      - service: systemd-networkd
{% endif %}
