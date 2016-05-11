-- Metronome Configuration File
--
-- Information on configuring Metronome can be found on our
-- website at http://www.lightwitch.org/metronome/documentation
--
-- Tip: You can check that the syntax of this file is correct
-- when you have finished by running: luac -p metronome.cfg.lua
-- If there are any errors, it will let you know what and where
-- they are, otherwise it will keep quiet.
--
-- The only thing left to do is rename this file to remove the .dist ending, and fill in the
-- blanks. Good luck, and happy Jabbering!


---------- Server-wide settings ----------
-- Settings in this section apply to the whole server and are the default settings
-- for any virtual hosts

-- This is a (by default, empty) list of accounts that are admins
-- for the server. Note that you must create the accounts separately
admins = { "{{ pillar['im']['admins']|join("\", \"") }}" }

-- Server PID
pidfile = "/var/run/prosody/prosody.pid"

https_ports = { 5280 }
https_interfaces = { "{{ pillar['network']['hosts'][grains['nodename']]['ip']|join("\", \"") }}" }

https_ports = { 5281 }
https_interfaces = { "{{ pillar['network']['hosts'][grains['nodename']]['ip']|join("\", \"") }}" }
https_ssl = {
  key = "/etc/prosody/certs/im.{{ pillar['im']['root_domain'] }}.key";
  certificate = "/etc/prosody/certs/im.{{ pillar['im']['root_domain'] }}.crt";
  dhparam = "/etc/prosody/certs/dhparams.pem";
  options = { "no_sslv2", "no_sslv3", "no_ticket", "no_compression", "cipher_server_preference", "single_dh_use", "single_ecdh_use" };
  ciphers = "EECDH+ECDSA+AESGCM EECDH+aRSA+AESGCM EECDH+ECDSA+SHA384 EECDH+ECDSA+SHA256 EECDH+aRSA+SHA384 EECDH+aRSA+SHA256 EECDH EDH+aRSA !RC4 !aNULL !eNULL !LOW !3DES !MD5 !EXP !PSK !SRP !DSS";  
}

plugin_paths = { "/opt/prosody/modules" }

-- Enable IPv6
use_ipv6 = true

-- This is the list of modules Metronome will load on startup.
-- It looks for mod_modulename.lua in the plugins folder, so make sure that exists too.

modules_enabled = {

    -- Generally required
        --"roster"; -- Allow users to have a roster. Recommended ;)
        "saslauth"; -- Authentication for clients and servers. Recommended if you want to log in.
        "tls"; -- Add support for secure TLS on c2s/s2s connections
        "dialback"; -- s2s dialback support
        "disco"; -- Service discovery
        "extdisco"; -- External Service Discovery
	"smacks"; -- Stream Management
	"csi";
	"throttle_presence";
	"filter_chatstates";
	"cloud_notify";

    -- Not essential, but recommended
        "private"; -- Private XML storage (for room bookmarks, etc.)
        "vcard"; -- Allow users to set vCards

    -- These are commented by default as they have a performance impact
    --    "compression"; -- Stream compression

    -- Nice to have
        "version"; -- Replies to server version requests
        "uptime"; -- Report how long server has been running
        "time"; -- Let others know the time here on this server
        "ping"; -- Replies to XMPP pings with pongs
        "pep"; -- Enables users to publish their mood, activity, playing music and more

    -- Admin interfaces
        --"admin_adhoc"; -- Allows administration via an XMPP client that supports ad-hoc commands
        "admin_telnet"; -- Opens telnet console interface on localhost port 5582

    -- HTTP modules
        "bosh"; -- Enable BOSH clients, aka "Jabber over HTTP"
        "websocket"; -- Enable WebSocket clients
        --"http_files"; -- Serve static files from a directory over HTTP

    -- Other specific functionality
        "posix"; -- POSIX functionality, sends server to background, enables syslog, etc.
        "bidi"; -- Bidirectional Streams for S2S connections
        --"groups"; -- Shared roster support
        --"announce"; -- Send announcement to all online users
        --"motd"; -- Send a message to users when they log in
        --"legacyauth"; -- Legacy authentication. Only used by some old clients and bots.
};

-- These modules are auto-loaded, but should you want
-- to disable them then uncomment them here:
modules_disabled = {
    -- "offline"; -- Store offline messages
    -- "c2s"; -- Handle client connections
    -- "s2s"; -- Handle server-to-server connections
};

authentication = "ldap"
default_storage = "sql"
storage = "sql"


ldap_server = '{{ pillar['ldap']['uri'] }}'
ldap_base = 'ou=users,ou=virtual,{{ pillar['ldap']['dn'] }}'
ldap_rootdn = 'cn=admin,{{ pillar['ldap']['dn'] }}'
ldap_password = '{{ pillar['ldap']['root']['passwd'] }}'
ldap_filter = '(&(objectClass=inetOrgPerson)(uid=$user))'
ldap_tls = 'true'

sql = {
  driver = "PostgreSQL";
  database = "prosody";
  host = "{{ pillar['im']['psql_server'] }}";
  username = "{{ pillar['postgres']['users'][pillar['postgres']['dbs']['prosody']['users'][0]]['name'] }}";
  password = "{{ pillar['postgres']['users'][pillar['postgres']['dbs']['prosody']['users'][0]]['password'] }}";
}

-- External Service Discovery (mod_extdisco)
external_services = {
    ["stun.{{ pillar['im']['root_domain'] }}"] = {
        [1] = {
            port = "3478",
            transport = "udp",
            type = "stun"
        },

        [2] = {
            port = "3478",
            transport = "tcp",
            type = "stun"
        }
    }
};

disco_items = {
    { "muc.{{ pillar['im']['root_domain'] }}" },
    { "proxy.{{ pillar['im']['root_domain'] }}" },
    { "pubsub.{{ pillar['im']['root_domain'] }}" },
    { "anonymous.{{ pillar['im']['root_domain'] }}" },
    { "up.{{ pillar['im']['root_domain'] }}" }    
};
		
-- Bidirectional Streams configuration (mod_bidi)
bidi_exclusion_list = { "jabber.org" }

-- BOSH configuration (mod_bosh)
bosh_max_inactivity = 30
consider_bosh_secure = true
cross_domain_bosh = true
force_https_bosh = true

-- WebSocket configuration (mod_websocket)
consider_websocket_secure = true
cross_domain_websocket = true

ssl = {
  key = "/etc/prosody/certs/im.{{ pillar['im']['root_domain'] }}.key";
  certificate = "/etc/prosody/certs/im.{{ pillar['im']['root_domain'] }}.crt";

  dhparam = "/etc/prosody/certs/dhparams.pem";
  options = { "no_sslv2", "no_sslv3", "no_ticket", "no_compression", "cipher_server_preference", "single_dh_use", "single_ecdh_use" };
  ciphers = "EECDH+ECDSA+AESGCM EECDH+aRSA+AESGCM EECDH+ECDSA+SHA384 EECDH+ECDSA+SHA256 EECDH+aRSA+SHA384 EECDH+aRSA+SHA256 EECDH EDH+aRSA !RC4 !aNULL !eNULL !LOW !3DES !MD5 !EXP !PSK !SRP !DSS";
}

-- Force clients to use encrypted connections? This option will
-- prevent clients from authenticating unless they are using encryption.

c2s_require_encryption = true

-- Force servers to use encrypted connections? This option will
-- prevent servers from connecting unless they are using encryption.

s2s_require_encryption = true

-- Allow servers to use an unauthenticated encryption channel

s2s_secure_auth = false


-- Logging configuration
log = {
    info = "/var/log/prosody/prosody.log";
    error = "/var/log/prosody/prosody.err";
    -- "*syslog"; -- Uncomment this for logging to syslog
    -- "*console"; -- Log to the console, useful for debugging with daemonize=false
}


------ Components ------
-- You can specify components to add hosts that provide special services,
-- like multi-user conferences, and transports.

---Set up a MUC (multi-user chat) room server on muc.{{ pillar['im']['root_domain'] }}:
Component "muc.{{ pillar['im']['root_domain'] }}" "muc"
    name = "Chatrooms"

    modules_enabled = {
        "muc_limits";
        "muc_log";
        "muc_log_http";
        "pastebin";
    }

    muc_event_rate = 0.5
    muc_burst_factor = 10

    muc_log_http_config = {
        url_base = "logs";
        theme = "prosody";
    }

    pastebin_url = "https://muc.{{ pillar['im']['root_domain'] }}/paste/"
    pastebin_path = "/paste/"
    pastebin_expire_after = 0
    pastebin_trigger = "!paste"

---Set up a PubSub server
Component "pubsub.{{ pillar['im']['root_domain'] }}" "pubsub"
    name = "Publish/Subscribe"
    pubsub_admins = { "{{ pillar['im']['admins']|join("\", \"") }}" }
    unrestricted_node_creation = true

---Set up a BOSH service
Component "bind.{{ pillar['im']['root_domain'] }}" "http"
    modules_enabled = { "bosh" }

---Set up a WebSocket service
Component "websocket.{{ pillar['im']['root_domain'] }}" "http"
    modules_enabled = { "websocket" }

---Set up a BOSH + WebSocket service
Component "me.{{ pillar['im']['root_domain'] }}" "http"
    modules_enabled = { "bosh", "websocket" }


Component "up.{{ pillar['im']['root_domain'] }}" "http_upload"

---Set up a statistics service
Component "stats.{{ pillar['im']['root_domain'] }}" "http"
    modules_enabled = { "server_status" }
    server_status_basepath = "/xmppd/"
    server_status_show_hosts = { {% for domain in pillar['im']['domains'] %}"{{ domain }}", {% endfor %}"anonymous.{{ pillar['im']['root_domain'] }}" }
    server_status_show_comps = { "muc.{{ pillar['im']['root_domain'] }}", "proxy.{{ pillar['im']['root_domain'] }}", "pubsub.{{ pillar['im']['root_domain'] }}" }

-- Set up a SOCKS5 bytestream proxy for server-proxied file transfers:
Component "proxy.{{ pillar['im']['root_domain'] }}" "proxy65"
    proxy65_acl = { "{{ pillar['im']['root_domain'] }}", "anonymous.{{ pillar['im']['root_domain'] }}" }


----------- Virtual hosts -----------
-- You need to add a VirtualHost entry for each domain you wish Metronome to serve.
-- Settings under each VirtualHost entry apply *only* to that host.
VirtualHost "anonymous.{{ pillar['im']['root_domain'] }}"
    enabled = true
    authentication = "anonymous"
    allow_anonymous_multiresourcing = true
    allow_anonymous_s2s = false
    anonymous_jid_gentoken = "Anonymous User"
    anonymous_randomize_for_trusted_addresses = { "127.0.0.1", "::1" }
    default_storage = "sql"
    storage = "sql"    

{% for domain in pillar['im']['domains'] %}
VirtualHost "{{ domain }}"
    enabled = true
    authentication = "ldap"
    default_storage = "sql"
    storage = "sql"

    modules_enabled = {
        -- Generally required
            "roster"; -- Allow users to have a roster. Recommended ;)

        -- Not essential, but recommended
            "private"; -- Private XML storage (for room bookmarks, etc.)
            "vcard"; -- Allow users to set vCards

        -- These are commented by default as they have a performance impact
            "mam"; -- Message Archive Management
            "blocklist"; -- Support blocklist lists

        -- Nice to have
            "lastactivity"; -- Logs the user last activity timestamp
            "pep"; -- Enables users to publish their mood, activity, playing music and more
            "carbons"; -- Allow clients to keep in sync with messages send on other resources

        -- Admin interfaces
            "admin_adhoc"; -- Allows administration via an XMPP client that supports ad-hoc commands
    }

    mam_stores_cap = 1000
    resources_limit = 10

    ssl = {
      key = "/etc/prosody/certs/{{ pillar['im']['domains'][domain] }}.key";
      certificate = "/etc/prosody/certs/{{ pillar['im']['domains'][domain] }}.crt";
    
      dhparam = "/etc/prosody/certs/dhparams.pem";
      options = { "no_sslv2", "no_sslv3", "no_ticket", "no_compression", "cipher_server_preference", "single_dh_use", "single_ecdh_use" };
      ciphers = "EECDH+ECDSA+AESGCM EECDH+aRSA+AESGCM EECDH+ECDSA+SHA384 EECDH+ECDSA+SHA256 EECDH+aRSA+SHA384 EECDH+aRSA+SHA256 EECDH EDH+aRSA !RC4 !aNULL !eNULL !LOW !3DES !MD5 !EXP !PSK !SRP !DSS";
    }

{% endfor %}
