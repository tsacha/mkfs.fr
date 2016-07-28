start redis:
  service.running:
    - name: redis
    - enable: true
    - require:
      - pkg: redis

/etc/rmilter/rmilter.conf:
  file.managed:
    - user: _rmilter
    - group: _rspamd
    - mode: 644
    - require:
      - pkg: rmilter
      - pkg: rspamd
    - template: jinja
    - source: 'salt://mx/misc/rmilter.conf'

/etc/rmilter/rmilter.conf.common:
  file.managed:
    - user: _rmilter
    - group: _rspamd
    - mode: 644
    - require:
      - pkg: rmilter
      - pkg: rspamd
    - template: jinja
    - source: 'salt://mx/misc/rmilter.conf.common'

start rmilter:
  service.running:
    - name: rmilter
    - enable: true
    - require:
      - file: /etc/rmilter/rmilter.conf
      - service: redis      
    - provider: systemd
    - watch:
      - file: /etc/rmilter/rmilter.conf
      - file: /etc/rmilter/rmilter.conf.common

/etc/rspamd/override.d:
  file.directory:
    - user: _rspamd
    - group: _rspamd
    - mode: 755
    - require:
      - pkg: rspamd

/etc/rspamd/rspamd.conf.local.override:
  file.managed:
    - user: _rspamd
    - group: _rspamd
    - mode: 644
    - require:
      - pkg: rspamd
    - watch_in:    
      - service: start rspamd
    - template: jinja
    - source: 'salt://mx/misc/rspamd.conf'

/etc/rspamd/override.d/worker-controller.inc:
  file.managed:
    - user: _rspamd
    - group: _rspamd
    - mode: 644
    - require:
      - file: /etc/rspamd/override.d
      - pkg: rspamd
    - require_in:
      - service: rspamd
    - watch_in:
      - service: rspamd
    - template: jinja
    - source: 'salt://mx/misc/worker-controller.inc'

/etc/rspamd/override.d/metrics.conf:
  file.managed:
    - user: _rspamd
    - group: _rspamd
    - mode: 644
    - require:
      - file: /etc/rspamd/override.d
      - pkg: rspamd
    - require_in:
      - service: start rspamd
    - watch_in:
      - service: start rspamd
    - template: jinja
    - source: 'salt://mx/misc/metrics.conf'

/etc/rspamd/override.d/statistic.conf:
  file.managed:
    - user: _rspamd
    - group: _rspamd
    - mode: 644
    - require:
      - file: /etc/rspamd/override.d
      - pkg: rspamd
    - require_in:
      - service: start rspamd
    - watch_in:
      - service: start rspamd
    - template: jinja
    - source: 'salt://mx/misc/statistic.conf'

start rspamd:
  service.running:
    - name: rspamd
    - enable: true
    - require:
      - service: start redis
    - provider: systemd
