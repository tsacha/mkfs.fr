{% if grains['os'] == 'Fedora' %}
iptables-services:
  pkg.installed:
    - require_in:
      - file: /etc/sysconfig/iptables
      - file: /etc/sysconfig/ip6tables
{% elif grains['os'] == 'Debian' %}
iptables-persistent:
  pkg.installed:
    - require_in:
      - file: /etc/iptables/rules.v4
      - file: /etc/iptables/rules.v6
{% endif %}

{% if grains['os'] == 'Fedora' %}
/etc/sysconfig/ip6tables:
{% elif grains['os'] == 'Debian' %}
/etc/iptables/rules.v6:
{% endif %}
  file.managed:
    - user: root
    - group: root
    - mode: '0644'
    - template: jinja
    - source: 'salt://fw/ip6.rules'
{% if grains['os'] == 'Fedora' %}
/etc/sysconfig/iptables:
{% elif grains['os'] == 'Debian' %}
/etc/iptables/rules.v4:
{% endif %}
  file.managed:
    - user: root
    - group: root
    - mode: '0644'
    - template: jinja
    - source: 'salt://fw/ip.rules'
{% if grains['os'] == 'Fedora' %}
ip6tables:
  service.running:
    - enable: true
    - require:
      - file: /etc/sysconfig/ip6tables
    - watch:
      - file: /etc/sysconfig/ip6tables
iptables:
  service.running:
    - enable: true
    - require:
      - file: /etc/sysconfig/iptables
    - watch:
      - file: /etc/sysconfig/iptables
{% elif grains['os'] == 'Debian' %}
netfilter-persistent:
  service.running:
    - enable: true
    - require:
      - file: /etc/iptables/rules.v4
      - file: /etc/iptables/rules.v6
    - watch:
      - file: /etc/iptables/rules.v4
      - file: /etc/iptables/rules.v6
{% endif %}