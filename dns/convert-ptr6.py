#!/usr/bin/env python3
import ipaddress
import sys
import re

if len(sys.argv) > 1:
    if(sys.argv[1] == 'zones'):
        raw = open("/etc/named.zones.source").read()
    else:
        raw = open("/etc/named/reverse6-"+sys.argv[1]+".source").read()
    try:
        replaced = re.sub('convert\((.+), ?([0-9]+)\)', lambda s: '.'.join(ipaddress.ip_address(s.group(1)).reverse_pointer.split('.')[32-int(int(s.group(2))/4):])+'.', raw)
    except AttributeError:
        replaced = raw
    if(sys.argv[1] == 'zones'):
        f = open("/etc/named.zones", "w+")
    else:
        f = open("/etc/named/zone.reverse6-"+sys.argv[1]+".local.", "w+")
    f.write(replaced)
    f.close()
