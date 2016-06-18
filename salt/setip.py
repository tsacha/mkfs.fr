#!/opt/venv/bin/python
# -*- coding: utf-8 -*-
import datetime
import yaml
import salt.client
client = salt.client.LocalClient()
pillar = open('/srv/pillar/dns/zones/dynamic.sls', 'r')
ips = yaml.load(pillar)['dynamic']

date = int(datetime.date.today().strftime('%Y%m%d'))*100
pillar = open('/srv/pillar/dns/zones/common.sls', 'r')
data = yaml.load(pillar)
serial = data['zones']['common']['SOA']['@']['sn']

edit = 0
dns_srv = 'dns.local'
for domain, values in ips.items():
    for record,ip in values.items():
        new = open('/opt/ips/'+ip+'.txt', 'r').read()
        result = client.cmd('*', 'grains.get', [ip])
        for k,v in result.items():
            if v != new:
                print("MàJ "+k)
                result = client.cmd(k, 'grains.setval', (ip, new))
                if(k == dns_srv):
                    edit = 1
if edit:
    print("MàJ DNS")
    if serial/100*100 == date:
        n_serial = date+(serial%100)+1
    else:
        n_serial = date+1
    data['zones']['common']['SOA']['@']['sn'] = n_serial
    with open('/srv/pillar/dns/zones/common.sls', 'w') as yaml_file:
        yaml_file.write(yaml.dump(data, default_flow_style=False))    
    result = client.cmd(dns_srv, 'state.highstate')
    print(result)
    result = client.cmd('rp.local', 'service.restart', ['nginx'])
    print(result)
