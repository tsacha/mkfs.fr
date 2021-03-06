{% if grains['os'] == 'Fedora' %}
utils:
  pkg.installed:
    - pkgs:
      - bind-utils
      - tar
      - emacs-nox
      - zeromq-devel
      - libattr-devel
      - python-devel
      - libffi-devel
      - openssl-devel
      - libattr-devel
      - swig
      - libxml2-devel
      - libxslt-devel
      - net-tools
      - virt-what
      - git
      - redhat-rpm-config
      - vim-enhanced
      - htop
      - wget
      - lbzip2-utils
      - less
      - yum
      - tmux
      - powerline
      - tmux-powerline
      - nagios-plugins-all

firewalld:
  service.dead:
    - disabled: true

tmux-conf:
  file.managed:
    - name: /root/.tmux.conf
    - source: 'salt://base/tmux.conf'
    - user: root
    - group: root
    - mode: '0644'

bashrc:
  file.managed:
    - name: /root/.bashrc
    - source: 'salt://base/bashrc'
    - user: root
    - group: root
    - mode: '0644'

influxdata-repo:
  pkgrepo.managed:
    - humanname: InfluxData
    - baseurl: https://repos.influxdata.com/rhel/7/x86_64/stable/
    - gpgcheck: 1
    - gpgkey: https://repos.influxdata.com/influxdb.key

{% elif grains['os'] == 'Debian' %}
utils:
  pkg.installed:
    - pkgs:
      - tar
      - emacs-nox
      - python-dev
      - virt-what
      - git
      - vim-nox
      - htop
      - wget
      - lbzip2
      - monitoring-plugins
      - python-pip
      - libffi-dev
      - libssl-dev
      - swig
{% endif %}

set timezone:
  file.symlink:
    - name: /etc/localtime
    - target: /usr/share/zoneinfo/Europe/Paris

disable emacs temporary files:
  file.managed:
    - name: /root/.emacs.el
    - user: root
    - group: root
    - mode: '0644'
    - source: 'salt://base/emacs.el'

journald configuration:
  file.managed:
    - name: /etc/systemd/journald.conf
    - user: root
    - group: root
    - mode: '0644'
    - source: 'salt://base/journald.conf'

systemd-journald:
  service.running:
    - enable: true
    - watch:
      - file: journald configuration

add resolv.conf:
  file.managed:
    - name: /etc/resolv.conf
    - user: root
    - group: root
    - mode: '0644'
    - source: 'salt://base/resolv.conf'
    - template: jinja

add limits.conf:
  file.managed:
    - name: /etc/security/limits.conf
    - user: root
    - group: root
    - mode: '0644'
    - source: 'salt://base/limits.conf'
    - template: jinja

{% if grains['virtual']|lower == 'lxc' %}
{% if grains['os'] == 'Fedora' %}
auditd:
  service.dead:
    - disabled: true
{% endif %}
{% else %}
mosh:
  pkg.installed

ntp:
  pkg.installed

ntpd:
  service.running:
    - enable: true
    - require:
      - pkg: ntp

systemd configuration:
  file.managed:
    - name: /etc/systemd/system.conf
    - user: root
    - group: root
    - mode: '0644'
    - source: 'salt://base/system.conf'

sysctl configuration:
  file.managed:
    - name: /etc/sysctl.conf
    - user: root
    - group: root
    - mode: '0644'
    - source: 'salt://base/sysctl.conf'
{% endif %}

sshd configuration file:
  file.managed:
    - name: /etc/ssh/sshd_config
    - template: jinja
    - source: 'salt://base/sshd_config'
    - user: root
    - group: root
    - mode: '0600'

sshd:
  service.running:
    - enable: true
    - provider : system
    - watch:
      - file: sshd configuration file

ssh authorized keys:
  file.managed:
    - name: /root/.ssh/authorized_keys
    - template: jinja
    - source: 'salt://base/authorized_keys'
    - user: root
    - group: root
    - mode: '0640'
    - makedirs: true

ssh config:
  file.managed:
    - name: /root/.ssh/config
    - template: jinja
    - source: 'salt://base/ssh_config'
    - user: root
    - group: root
    - mode: '0640'
    - makedirs: true

systemd reload:
  cmd.wait:
{% if grains['os'] == 'Fedora' %}
    - name: /usr/bin/systemctl daemon-reload
{% elif grains['os'] == 'Debian' %}
    - name: /bin/systemctl daemon-reload
{% endif %}
