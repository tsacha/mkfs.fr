murmur:
  group.present:
    - gid: 5000
  user.present:
    - home: /srv/murmur
    - uid: 5000
    - gid: 5000
    - require:
      - group: murmur
    - shell: /sbin/nologin

/etc/systemd/system/murmur.service:
  file.managed:
    - user: root
    - group: root
    - mode: 644
    - source: 'salt://bla/murmur.service'