postgresql-server:
  pkg.installed

create directories:
  cmd.run:
    - name: /usr/bin/initdb /var/lib/pgsql/data
    - unless:
      - stat /var/lib/pgsql/data/postgresql.conf
    - require:
      - pkg: postgresql-server
    - user: postgres

/var/lib/pgsql/data/pg_hba.conf:
  file.managed:
    - user: postgres
    - group: postgres
    - template: jinja
    - source: 'salt://postgres/pg_hba.conf.template'
    - require:
      - pkg: postgresql-server

/var/lib/pgsql/data/pg_ident.conf:
  file.managed:
    - user: postgres
    - group: postgres
    - template: jinja
    - source: 'salt://postgres/pg_ident.conf.template'
    - require:
      - pkg: postgresql-server

/var/lib/pgsql/data/postgresql.conf:
  file.managed:
    - user: postgres
    - group: postgres
    - template: jinja
    - source: 'salt://postgres/postgresql.conf.template'
    - require:
      - pkg: postgresql-server

postgresql:
  service.running:
    - enable: true
    - provider: systemd
    - require:
      - cmd: create directories
      - file: /var/lib/pgsql/data/postgresql.conf
      - file: /var/lib/pgsql/data/pg_hba.conf
      - file: /var/lib/pgsql/data/pg_ident.conf
    - watch:
      - file: /var/lib/pgsql/data/postgresql.conf
      - file: /var/lib/pgsql/data/pg_hba.conf
      - file: /var/lib/pgsql/data/pg_ident.conf

change postgres password:
  postgres_user.present:
    - name: postgres
    - createdb: true
    - createroles: true
    - encrypted: true
    - login: true
    - superuser: true
    - replication: true
    - password: {{ pillar['postgres']['pwd'] }}
