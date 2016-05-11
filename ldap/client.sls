{% if grains['os'] == 'Fedora' %}
cyrus-sasl:
  pkg.installed
{% elif grains['os'] == 'Debian' %}
sasl2-bin:
  pkg.installed
{% endif %}

saslauthd call configuration:
  file.managed:
{% if grains['os'] == 'Fedora' %}
    - name: /etc/sysconfig/saslauthd
{% elif grains['os'] == 'Debian' %}
    - name: /etc/default/saslauthd
{% endif %}
    - template: jinja
    - source: 'salt://ldap/saslauthd'

saslauthd configuration:
  file.managed:
{% if grains['os'] == 'Fedora' %}
    - name: /etc/sasl2/saslauthd.conf
{% elif grains['os'] == 'Debian' %}
    - name: /etc/saslauthd.conf
{% endif %}
    - template: jinja
    - source: 'salt://ldap/saslauthd.conf'
 
saslauthd:
  service.running:
    - enable: true
    - provider: systemd
    - require:
      - file: saslauthd call configuration
      - file: saslauthd configuration
    - watch:
      - file: saslauthd call configuration
      - file: saslauthd configuration

install openldap client:
  pkg.installed:
{% if grains['os'] == 'Fedora' %}
    - name: openldap-clients
{% elif grains['os'] == 'Debian' %}
    - name: ldap-utils
{% endif %}

ldap configuration:
  file.managed:
{% if grains['os'] == 'Fedora' %}
    - name: /etc/openldap/ldap.conf
{% elif grains['os'] == 'Debian' %}
    - name: /etc/ldap/ldap.conf
{% endif %}
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: install openldap client
    - template: jinja
    - source: 'salt://ldap/config/ldap.conf.template'