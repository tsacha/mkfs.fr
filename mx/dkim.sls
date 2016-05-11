/srv/dkim:
  file.directory:
    - user: _rmilter
    - group: _rspamd
    - mode: 770
    - require:
      - pkg: rmilter

{% for zone in pillar['zones'] %}
{% if zone != "common" %}
{% if pillar['zones'][zone]['dkim'] is defined %}
/srv/dkim/{{ zone }}.private:
  file.managed:
    - user: _rmilter
    - group: _rspamd
    - mode: '0400'
    - template: jinja
    - source: 'salt://private/dkim/{{ zone }}/{{ pillar['zones'][zone]['dkim'] }}.private'
    - require_in:
      - service: rmilter
      - service: rspamd
    - watch_in:
      - service: rmilter
      - service: rspamd
    - require:
      - file: /srv/dkim
      - pkg: rmilter      
{% endif %}

{% endif %}
{% endfor %}
