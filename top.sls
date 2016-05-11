base:
  '*':
    - base
    - salt
    - bak
    - certs.client
  '*.local':
    - fw
    - base.network
  '*.mkfs.fr':
    - fw
    - base.network
  's1.mkfs.fr':
    - certs.create
  's2.mkfs.fr':
    - bak/server
  'dns*.local':
    - dns
  'db.local':
    - mariadb
    - mariadb.db
    - postgres
    - postgres.db
    - ldap
    - ldap.users
    - bak.mariadb
    - bak.postgres
  'db2.local':
    - postgres
    - postgres.db
    - ldap
    - ldap.users
  'mx.local':
    - mx
    - rp
  'rp.local':
    - rp
  'rp2.local':
    - rp
  'web.local':
    - web
    - web.private.default
    - web.private.webmail
    - web.private.freshrss
    - web.private.maxence
    - web.private.glenn
    - web.private.charlotte
    - web.private.autoconfig
  'cloud.local':
    - web
    - cloud
    - ldap.client
  'im.local':
    - rp
    - im
    - ldap.client
  'bla.local':
    - bla
    - rp
  'sup.local':
    - sup
    - ldap.client
  'st.local':
    - st
    - web    
  'cm.local':
    - web
    - web.private.ceramique
  'bcm.local':
    - web
    - web.private.betaceramique
  'srv.s.tremoureux.fr':
    - rp
    - web
    - web.private.srv