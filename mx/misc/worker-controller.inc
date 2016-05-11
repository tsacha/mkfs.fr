type = "controller";
count = 1;
password = "{{ pillar['mx']['rspamd']['password'] }}";
secure_ip = "127.0.0.1";
secure_ip = "::1";
static_dir = "${WWWDIR}";
