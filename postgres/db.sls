{% for user in pillar['postgres']['users'] %}
postgres create user {{ user }}:
  postgres_user.present:
    - name: {{ pillar['postgres']['users'][user]['name'] }}
    - encrypted: True
    - login: True
    - password: {{ pillar['postgres']['users'][user]['password'] }}
{% endfor %}

{% for db in pillar['postgres']['dbs'] %}
postgres create db {{ db }}:
  postgres_database.present:
    - name: {{ db }}    
{% endfor %}
