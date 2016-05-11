{% if pillar['mariadb']['users'] %}
{% for user in pillar['mariadb']['users'] %}
mariadb create user {{ user }}:
  mysql_user.present:
    - name: {{ pillar['mariadb']['users'][user]['name'] }}
    - host: '{{ pillar['mariadb']['users'][user]['scope'] }}'
    - password: {{ pillar['mariadb']['users'][user]['password'] }}
    - connection_pass: "{{ pillar['mariadb']['pwd'] }}"    
{% endfor %}
{% endif %}


{% if pillar['mariadb']['dbs'] %}
{% for db in pillar['mariadb']['dbs'] %}
mariadb create db {{ db }}:
  mysql_database.present:
    - name: {{ db }}
    - connection_pass: "{{ pillar['mariadb']['pwd'] }}"

{% for user in pillar['mariadb']['dbs'][db]['users'] %}
mariadb grant {{ user }} for db {{ db }}:
  mysql_grants.present:
    - grant: all privileges
    - database: {{ db }}.*
    - host: '{{ pillar['mariadb']['users'][user]['scope'] }}'
    - connection_pass: "{{ pillar['mariadb']['pwd'] }}"    
    - user: {{ pillar['mariadb']['users'][user]['name'] }}
    - require:
      - mysql_user: mariadb create user {{ user }}
{% endfor %}

{% endfor %}
{% endif %}