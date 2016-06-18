acme.sh:
  git.latest:
    - name: https://github.com/Neilpang/acme.sh.git
    - target: /opt/acme.sh

configure acme.sh:
  cmd.run:
    - name: /opt/acme.sh/acme.sh --install --home /opt/certs --certhome  /opt/certs --accountemail  "{{ pillar['letsencrypt_account'] }}"
    - cwd: /opt/acme.sh/
    - unless: stat /opt/certs/account.conf

acme.sh uninstallcronjob:
  cmd.wait:
    - name: /opt/acme.sh/acme.sh --uninstallcronjob
    - cwd: /opt/acme.sh
    - watch:
      - cmd: configure acme.sh

{% for cert in pillar['certs'] %}
cert {{ cert }}:
  cmd.run:
    - env:
      - LE_WORKING_DIR: '/opt/certs'
    - name: /opt/acme.sh/acme.sh --issue -f -w {{ pillar['certs'][cert]['webroot'] }} -d {{ cert }} {% if pillar['certs'][cert]['domains'] is defined %}{% for domain in pillar['certs'][cert]['domains'] %}-d {{ domain }} {% endfor %}{% endif %} --keylength {% if pillar['certs'][cert]['keylength'] is defined %}{{ pillar['certs'][cert]['keylength'] }}{% else %}ec-256{% endif %}
    - unless: 'test $(($(date --date="$(openssl x509 -in /opt/certs/{{ cert }}/{{ cert }}.cer -enddate -noout | cut -d= -f2)" +%s)-$(date +%s))) -gt 864000{% if pillar['certs'][cert]['domains'] is defined %} && test $(echo {{ cert }},{{ pillar['certs'][cert]['domains']|join(',') }} | tr "," "\n" | sort | tr "\n" , | sed "s/,$//") == $(openssl x509 -in /opt/certs/{{ cert }}/{{ cert }}.cer -text | grep -A1 Alt | grep DNS | sed -r "s/ +DNS://g"){% endif %}'
    - require:
      - git: acme.sh
{% endfor %}
