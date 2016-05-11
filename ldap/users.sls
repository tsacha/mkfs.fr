### Users
{% if pillar['users'] is defined and pillar['users'] %}
{% for user in pillar['users'] %}
"modify {{ pillar['users'][user]['mail'] }}":
  cmd.run:
    - name: |
        ldapmodify -Y EXTERNAL -H  ldapi:/// <<EOF
        dn: uid={{ user }},ou=users,ou=virtual,{{ pillar['ldap']['dn'] }}
        changetype: modify
        replace: userPassword
        userPassword: {{ pillar['users'][user]['pwd'] }}
        -
        replace: cn
        {%- if 'b64:' in pillar['users'][user]['cn'] %}
        cn: $(echo {{ pillar['users'][user]['cn'].split('b64:')[1] }} | base64 -d)
	{%- else %}
        cn: {{ pillar['users'][user]['cn'] }}
	{%- endif %}
        -
        replace: sn
        {%- if 'b64:' in pillar['users'][user]['sn'] %}
        sn: $(echo {{ pillar['users'][user]['sn'].split('b64:')[1] }} | base64 -d)
	{%- else %}
        sn: {{ pillar['users'][user]['sn'] }}
	{%- endif %}
        -
        replace: displayName
        {%- if 'b64:' in pillar['users'][user]['cn'] %}
        {%- if 'b64:' in pillar['users'][user]['sn'] %}
        displayName: "$(echo {{ pillar['users'][user]['cn'].split('b64:')[1] }} | base64 -d) $(echo {{ pillar['users'][user]['sn'].split('b64:')[1] }} | base64 -d)"
	{%- else %}
        displayName: "$(echo {{ pillar['users'][user]['cn'].split('b64:')[1] }} | base64 -d) {{ pillar['users'][user]['dn'] }}"
        {%- endif %}
	{%- else %}
        {%- if 'b64:' in pillar['users'][user]['sn'] %}
        displayName: "{{ pillar['users'][user]['cn'] }} $(echo {{ pillar['users'][user]['sn'].split('b64:')[1] }} | base64 -d)"
        {%- else %}
        displayName: {{ pillar['users'][user]['cn'] }} {{ pillar['users'][user]['sn'] }}
	{%- endif %}
	{%- endif %}
        -
        replace: mail
        mail: {{ pillar['users'][user]['mail'] }}
        EOF
    - onlyif: ldapsearch -Y EXTERNAL -H ldapi:/// -b {{ pillar['ldap']['dn'] }} uid={{ user }} | grep numEntries
    - unless: ldapsearch -Y EXTERNAL -H ldapi:/// -b {{ pillar['ldap']['dn'] }} "(&(uid={{ user }})(cn={% if 'b64:' in pillar['users'][user]['cn'] %}$(echo {{ pillar['users'][user]['cn'].split('b64:')[1] }} | base64 -d){% else %}{{ pillar['users'][user]['cn'] }}{% endif %})(sn={% if 'b64:' in pillar['users'][user]['sn'] %}$(echo {{ pillar['users'][user]['sn'].split('b64:')[1] }} | base64 -d){% else %}{{ pillar['users'][user]['sn'] }}{% endif %})(mail={{ pillar['users'][user]['mail'] }})(userPassword={{ pillar['users'][user]['pwd'] }}))" | grep numEntries

"add {{ pillar['users'][user]['mail'] }}":
  cmd.run:
    - name: |
        ldapadd -Y EXTERNAL -H  ldapi:/// <<EOF
        dn: uid={{ user }},ou=users,ou=virtual,{{ pillar['ldap']['dn'] }}
        objectClass: inetOrgPerson
        uid: {{ user }}
        userPassword: {{ pillar['users'][user]['pwd'] }}
        {%- if 'b64:' in pillar['users'][user]['cn'] %}
        cn:: {{ pillar['users'][user]['cn'].split('b64:')[1] }}
	{%- else %}
        cn: {{ pillar['users'][user]['cn'] }}
	{%- endif %}
        {%- if 'b64:' in pillar['users'][user]['sn'] %}
        sn:: {{ pillar['users'][user]['sn'].split('b64:')[1] }}
	{%- else %}
        sn: {{ pillar['users'][user]['sn'] }}
	{%- endif %}
        mail: {{ pillar['users'][user]['mail'] }}
        EOF
    - unless: ldapsearch -Y EXTERNAL -H  ldapi:/// -b {{ pillar['ldap']['dn'] }} uid={{ user }} | grep numEntries

{% endfor %}
{% endif %}

{% for localuser in salt['cmd.run']("ldapsearch -Q -Y EXTERNAL -H  ldapi:/// -b ou=users,ou=virtual,"~ pillar['ldap']['dn']~" uid  2> /dev/null | grep -E '^uid' | sed 's/uid: //g'").splitlines() %}
{% if pillar['users'][localuser] is not defined %}
ldapdelete -Y EXTERNAL -H ldapi:/// uid={{ localuser }},ou=users,ou=virtual,{{ pillar['ldap']['dn'] }}:
  cmd.run
{% endif %}
{% endfor %}


### Groups

{% if pillar['groups'] is defined and pillar['groups'] %}
{% for group in pillar['groups'] %}
{% for user in pillar['groups'][group] %}
"add user {{ user }} to group {{ group }}":
  cmd.run:
    - name: |
        ldapmodify -Y EXTERNAL -H  ldapi:/// <<EOF
        dn: cn={{ group }},ou=groups,ou=virtual,dc=ldap,dc=local
        changetype: modify
        add: uniqueMember
        uniqueMember: uid={{ user }},ou=users,ou=virtual,{{ pillar['ldap']['dn'] }}
        EOF
    - unless: ldapsearch -Y EXTERNAL -H ldapi:/// -b cn={{ group }},ou=groups,ou=virtual,dc=ldap,dc=local uniqueMember=uid={{ user }},ou=users,ou=virtual,dc=ldap,dc=local | grep numEntries
    - onlyif: ldapsearch -Y EXTERNAL -H  ldapi:/// -b ou=groups,ou=virtual,{{ pillar['ldap']['dn'] }} cn={{ group }} | grep numEntries
{% endfor %}

"add group {{ group }}":
  cmd.run:
    - name: |
        ldapadd -Y EXTERNAL -H  ldapi:/// <<EOF
        dn: cn={{ group }},ou=groups,ou=virtual,{{ pillar['ldap']['dn'] }}
        objectClass: groupOfUniqueNames
{%- for user in pillar['groups'][group] %}
        uniqueMember: uid={{ user }},ou=users,ou=virtual,{{ pillar['ldap']['dn'] }}
{%- endfor %}
        EOF
    - unless: ldapsearch -Y EXTERNAL -H  ldapi:/// -b ou=groups,ou=virtual,{{ pillar['ldap']['dn'] }} cn={{ group }} | grep numEntries
{% endfor %}
{% endif %}


{% for localgroup in salt['cmd.run']("ldapsearch -Q -Y EXTERNAL -H ldapi:/// -b ou=groups,ou=virtual,"~ pillar['ldap']['dn']~"  cn 2> /dev/null | grep -E '^cn' | sed 's/cn: //g'").splitlines() %}
{% if pillar['groups'] is not defined or pillar['groups'][localgroup] is not defined %}
ldapdelete -Y EXTERNAL -H ldapi:/// cn={{ localgroup }},ou=groups,ou=virtual,{{ pillar['ldap']['dn'] }}:
  cmd.run
{% else %}
{% for localuser in salt['cmd.run']("ldapsearch -Q -Y EXTERNAL -H ldapi:/// -b cn="~ localgroup~",ou=groups,ou=virtual,"~ pillar['ldap']['dn']~"  uniqueMember 2> /dev/null | grep -E '^uniqueMember' | sed 's/uniqueMember: //g' | sed 's/uid=//g' | sed 's/,ou=users,ou=virtual,"~ pillar['ldap']['dn']~"//g'").splitlines() %}
{% if localuser not in pillar['groups'][localgroup] %}
delete {{ localuser }} from {{ localgroup }}:
  cmd.run:
    - name: |
        ldapmodify -Y EXTERNAL -H  ldapi:/// <<EOF
        dn: cn={{ localgroup }},ou=groups,ou=virtual,dc=ldap,dc=local
        changetype: modify
        delete: uniqueMember
        uniqueMember: uid={{ localuser }},ou=users,ou=virtual,{{ pillar['ldap']['dn'] }}
        EOF
{% endif %}
{% endfor %}
{% endif %}
{% endfor %}

### Aliases

{% if pillar['aliases'] is defined and pillar['aliases'] %}
{% for src,tgt in pillar['aliases'].iteritems() %}
modify alias {{ src }}:
  cmd.run:
    - name: |
        ldapmodify -Y EXTERNAL -H  ldapi:/// <<EOF
        dn: uid={{ src }},ou=aliases,ou=virtual,{{ pillar['ldap']['dn'] }}
        changetype: modify
        replace: homePostalAddress
        homePostalAddress: {{ tgt }}
        EOF
    - onlyif: ldapsearch -Y EXTERNAL -H ldapi:/// -b {{ pillar['ldap']['dn'] }} uid={{ src }} | grep numEntries
    - unless: ldapsearch -Y EXTERNAL -H ldapi:/// -b {{ pillar['ldap']['dn'] }} "(&(uid={{ src }})(homePostalAddress={{ tgt }}))" | grep numEntries

"add alias {{ src }}":
  cmd.run:
    - name: |
        ldapadd -Y EXTERNAL -H  ldapi:/// <<EOF
        dn: uid={{ src }},ou=aliases,ou=virtual,{{ pillar['ldap']['dn'] }}
        objectClass: inetOrgPerson
        uid: {{ src }}
        sn: {{ src }}
        cn: {{ src }}
        homePostalAddress: {{ tgt }}
        EOF
    - unless: ldapsearch -Y EXTERNAL -H  ldapi:/// -b {{ pillar['ldap']['dn'] }} uid={{ src }} | grep numEntries
{% endfor %}
{% endif %}

{% for localalias in salt['cmd.run']("ldapsearch -Y EXTERNAL -H  ldapi:/// -b ou=aliases,ou=virtual,"~ pillar['ldap']['dn']~" uid  2> /dev/null | grep -E '^uid' | sed 's/uid: //g'").splitlines() %}
{% if pillar['aliases'][localalias] is not defined %}
ldapdelete -Y EXTERNAL -H ldapi:/// uid={{ localalias }},ou=aliases,ou=virtual,{{ pillar['ldap']['dn'] }}:
  cmd.run
{% endif %}
{% endfor %}

### Domains

{% if pillar['domains'] is defined and pillar['domains'] %}
{% for domain in pillar['domains'] %}
"add domain {{ domain }}":
  cmd.run:
    - name: |
        ldapadd -Y EXTERNAL -H  ldapi:/// <<EOF
        dn: dc={{ domain }},ou=domains,ou=virtual,{{ pillar['ldap']['dn'] }}
        objectClass: organization
        objectClass: dcObject
        o: {{ domain }}
        dc: {{ domain }}
        EOF
    - unless: ldapsearch -Y EXTERNAL -H  ldapi:/// -b {{ pillar['ldap']['dn'] }} dc={{ domain }} | grep numEntries
{% endfor %}
{% endif %}

{% for localdomain in salt['cmd.run']("ldapsearch -Y EXTERNAL -H  ldapi:/// -b ou=domains,ou=virtual,"~ pillar['ldap']['dn']~" o  2> /dev/null | grep -E '^o' | sed 's/o: //g'").splitlines() %}
{% if not localdomain in pillar['domains'] %}
ldapdelete -Y EXTERNAL -H ldapi:/// dc={{ localdomain }},ou=domains,ou=virtual,{{ pillar['ldap']['dn'] }}:
  cmd.run
{% endif %}
{% endfor %}