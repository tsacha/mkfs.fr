letsencrypt:
  pkg.installed

{% for cert in pillar['certs'] %}
cert {{ cert }}:
  cmd.run:   
    - name: letsencrypt certonly -n -m {{ pillar['letsencrypt_account'] }} --renew-by-default --break-my-certs --expand --rsa-key-size 4096 --webroot -w {{ pillar['certs'][cert]['webroot'] }} -d {{ cert }} {% if pillar['certs'][cert]['domains'] is defined %}{% for domain in pillar['certs'][cert]['domains'] %}-d {{ domain }} {% endfor %}{% endif %} --agree-tos
    - unless: 'test $(($(date --date="$(openssl x509 -in /etc/letsencrypt/live/{{ cert }}/cert.pem -enddate -noout | cut -d= -f2)" +%s)-$(date +%s))) -gt 864000{% if pillar['certs'][cert]['domains'] is defined %} && test $(echo {{ cert }},{{ pillar['certs'][cert]['domains']|join(',') }} | tr "," "\n" | sort | tr "\n" , | sed "s/,$//") == $(openssl x509 -in /etc/letsencrypt/live/{{ cert }}/cert.pem -text | grep -A1 Alt | grep DNS | sed -r "s/ +DNS://g"){% endif %}'
    - require:
      - pkg: letsencrypt
{% endfor %}
