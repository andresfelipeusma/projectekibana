# Grok i el seu filtrat

Grok es actualment la millor manera en Logstash per analitzar dades de 
registres no estructurades que ens permet estructurar i consultar més facilment.
Funciona combinant patrons de text els quals coincideixen amb als registres.

Exemple:

``%{NUMBER:duration} %{IP:client}``, per que coincideixi el nostre registre ``1234 192.168.2.44``

- Ldap logs:

```
Apr 11 09:53:08 ldapserver slapd[19329]: conn=1202229 fd=28 ACCEPT from IP=1.2.3.4:57632 (IP=0.0.0.0:389)
Apr 11 09:53:08 ldapserver slapd[19329]: conn=1202229 op=0 BIND dn="cn=User,c=corp" method=128
Apr 11 09:53:08 ldapserver slapd[19329]: conn=1202229 op=0 BIND dn="cn=User,c=corp" mech=SIMPLE ssf=0
Apr 11 09:53:08 ldapserver slapd[19329]: conn=1202229 op=0 RESULT tag=97 err=0 text=
Apr 11 09:53:08 ldapserver slapd[19329]: conn=1202229 op=1 SRCH base="c=fr" scope=0 deref=2 filter="(objectClass=*)"
Apr 11 09:53:08 ldapserver slapd[19329]: conn=1202229 op=1 SRCH attr=contextCSN
Apr 11 09:53:08 ldapserver slapd[19329]: conn=1202229 op=1 SEARCH RESULT tag=101 err=0 nentries=1 text=
Apr 11 09:53:08 ldapserver slapd[19329]: conn=1202229 fd=28 closed (connection lost) 
```

- Exemple de filtre LDAP:

```
filter {
 if [type] == "ldap" {
  grok {
    match => [ "message", "%{SYSLOGBASE} (?:(?:<= (?:b|m)db_%{DATA:index_error_filter_type}_candidates: \(%{WORD:index_error_attribute_name}\) not indexed)|(?:ppolicy_%{DATA:ppolicy_op}: %{DATA:ppolicy_data})|(?:connection_input: conn=%{INT:connection} deferring operation: %{DATA:deferring_op})|(?:connection_read\(%{INT:fd_number}\): no connection!)|(?:conn=%{INT:connection} (?:(?:fd=%{INT:fd_number} (?:(?:closed(?: \(connection lost\)|))|(?:ACCEPT from IP=%{IP:src_ip}\:%{INT:src_port} \(IP=%{IP:dst_ip}\:%{INT:dst_port}\))|(?:TLS established tls_ssf=%{INT:tls_ssf} ssf=%{INT:ssf})))|(?:op=%{INT:operation_number} (?:(?:(?:(?:SEARCH )|(?:))RESULT (?:tag=%{INT:tag}|oid=(?:%{DATA:oid}(?:))) err=%{INT:error_code}(?:(?: nentries=%{INT:nentries})|(?:)) text=(?:(?:%{DATA:error_text})|(?:)))|(?:%{WORD:operation_name}(?:(?: %{DATA:data})|(?:))))))))%{SPACE}$" ]
  }
  date {
    locale => "en"
    match => [ "timestamp", "MMM  d HH:mm:ss", "MMM dd HH:mm:ss", "ISO8601" ]
    target => "@timestamp"
  }
  if [operation_name] == "BIND" {
    grok {
      match => [ "data", "(?:(?:(?<bind_dn>anonymous))|(?:dn=\"%{DATA:bind_dn}\")) (?:(?:method=%{WORD:bind_method})|(?:mech=%{WORD:bind_mech} ssf=%{INT:bind_ssf}))%{SPACE}$" ]
      remove_field => [ "data" ]
    }
  }
  if [operation_name] == "SRCH" {
    grok {
      match => [ "data", "(?:(?:base=\"%{DATA:search_base}\" scope=%{INT:search_scope} deref=%{INT:search_deref} filter=\"%{DATA:search_filter}\")|(?:attr=%{DATA:search_attr}))%{SPACE}$" ]
      remove_field => [ "data" ]
    }
  }
  if [operation_name] == "MOD" {
    grok {
      match => [ "data", "(?:(?:dn=\"%{DATA:mod_dn}\")|(?:attr=%{DATA:mod_attr}))%{SPACE}$" ]
      remove_field => [ "data" ]
    }
  }
  if [operation_name] == "MODRDN" {
    grok {
      match => [ "data", "dn=\"%{DATA:modrdn_dn}\"%{SPACE}$" ]
      remove_field => [ "data" ]
    }
  }
  if [operation_name] == "ADD" {
    grok {
      match => [ "data", "dn=\"%{DATA:add_dn}\"%{SPACE}$" ]
      remove_field => [ "data" ]
    }
  }
  if [operation_name] == "DEL" {
    grok {
      match => [ "data", "dn=\"%{DATA:del_dn}\"%{SPACE}$" ]
      remove_field => [ "data" ]
    }
  }
  if [operation_name] == "CMP" {
    grok {
      match => [ "data", "dn=\"%{DATA:cmp_dn}\" attr=\"%{DATA:cmp_attr}\"%{SPACE}$" ]
      remove_field => [ "data" ]
    }
  }
  if [operation_name] == "EXT" {
    grok {
      match => [ "data", "oid=%{DATA:ext_oid}%{SPACE}$" ]
      remove_field => [ "data" ]
    }
  }
  if [ppolicy_op] == "bind" {
    grok {
      match => [ "ppolicy_data", "(?:(?:Entry %{DATA:ppolicy_bind_dn} has an expired password: %{INT:ppolicy_grace} grace logins)|(?:Setting warning for password expiry for %{DATA:ppolicy_bind_dn} = %{INT:ppolicy_expiration} seconds))%{SPACE}$" ]
      remove_field => [ "ppolicy_data" ]
    }
  }
 }
}
```

- Exemple de filtre Syslog:

```
filter {
  if [type] == "syslog" {
    grok {
      match => { "message" => "%{SYSLOGTIMESTAMP:syslog_timestamp} %{SYSLOGHOST:syslog_hostname} %{DATA:syslog_program}(?:\[%{POSINT:syslog_pid}\])?: %{GREEDYDATA:syslog_message}" }
      add_field => [ "received_at", "%{@timestamp}" ]
      add_field => [ "received_from", "%{host}" ]
    }
    date {
      match => [ "syslog_timestamp", "MMM  d HH:mm:ss", "MMM dd HH:mm:ss" ]
    }
  }
}
```

- Samba Logs:

```
[2017/05/07 03:48:30,  0] lib/util_sock.c:1491(get_peer_addr_internal) getpeername failed. Error was Transport endpoint is not connected
[2017/05/07 03:48:30,  0] lib/util_sock.c:1491(get_peer_addr_internal) getpeername failed. Error was Transport endpoint is not connected
[2017/05/07 03:48:30,  0] lib/access.c:410(check_access)
[2017/05/07 03:48:30,  0] lib/util_sock.c:1491(get_peer_addr_internal) getpeername failed. Error was Transport endpoint is not connected
[2017/05/07 03:48:30,  0] lib/util_sock.c:1491(get_peer_addr_internal) getpeername failed. Error was Transport endpoint is not connected Denied connection from 0.0.0.0 (0.0.0.0)
[2017/05/07 03:48:30,  0] lib/util_sock.c:738(write_data)
```

- Exemple de filtre Samba:

```
filter {
 if [type] == "samba" {
  grok {
    add_tag => ["samba","grooked"]
    match =>{ "message" => "\[%{SAMBATIME:samba_timestamp},%{SPACE}%{NUMBER:severity_code}\]%{SPACE}%{GREEDYDATA:samba_class}%{SPACE}%{GREEDYDATA:samba_message}" }
    patterns_dir => ["/opt/logstash/patterns"]
   }
 }
}
```

- Radius logs:

```
Wed May 10 13:24:20 2017 : Info: rlm_sql (sql_mysql): Driver rlm_sql_mysql (module rlm_sql_mysql) loaded and linked
Wed May 10 13:24:20 2017 : Info: rlm_sql (sql_mysql): Attempting to connect to radius@localhost:/radius
Wed May 10 13:24:20 2017 : Info: rlm_sql (sql_mysql): Attempting to connect rlm_sql_mysql #0
```

- Exemple de filtre Radius:

```
filter {
  if [type] == "radius" {
    grok {
      match => { "message" => "%{SYSLOGTIMESTAMP:radius_timestamp}%{SPACE}%{YEAR}%{SPACE}:%{SPACE}%{WORD:radius_severity}:%{SPACE}%{GREEDYDATA:radius_messsage}" }
      add_tag => "radius"
    }
    date {
      match => [ "syslog_timestamp", "MMM  d HH:mm:ss", "MMM dd HH:mm:ss" ]
    }
  }
}
```

- Radius logs amb detalls:

```
Tue Apr 18 07:37:13 2017
	Packet-Type = Access-Request
	User-Name = "rvazquez"
	NAS-IP-Address = 10.200.199.12
	NAS-Identifier = "002722fc0683"
	NAS-Port = 0
	Called-Station-Id = "0A-27-22-FD-06-83:edt_profes"
	Calling-Station-Id = "04-02-1F-EC-61-3C"
	Framed-MTU = 1400
	NAS-Port-Type = Wireless-802.11
	Connect-Info = "CONNECT 0Mbps 802.11b"
	EAP-Message = 0x02bf000d017276617a7175657a
	Message-Authenticator = 0xba4b839d2521175424397b36cceb0d8a

Tue Apr 18 07:37:22 2017
	Packet-Type = Access-Request
	User-Name = "rvazquez"
	NAS-IP-Address = 10.200.199.12
	NAS-Identifier = "002722fc0683"
	NAS-Port = 0
	Called-Station-Id = "0A-27-22-FD-06-83:edt_profes"
	Calling-Station-Id = "04-02-1F-EC-61-3C"
	Framed-MTU = 1400
	NAS-Port-Type = Wireless-802.11
	Connect-Info = "CONNECT 0Mbps 802.11b"
	EAP-Message = 0x02c000060319
	State = 0xd95a7a22d99a7ecf01c4ca7e8f61d063
	Message-Authenticator = 0x5f36c09c78168951f4bf0cd85a89865b
```

- Exemple filtre radius amb detalls:

```
filter {
 if [type] == "radius" {
  grok {
    match =>{ "message" => "%{RADIUSTIMESTAMP:radius_timestamp}%{SPACE}Packet-Type%{SPACE}=%{SPACE}
							%{GREEDYDATA:Packet_Type}%{SPACE}User-Name%{SPACE}=%{SPACE}\"%{USERNAME:User_Name}\"
							%{SPACE}NAS-IP-Address%{SPACE}=%{SPACE}%{IPV4:NAS_IP_Address}%{SPACE}NAS-Identifier
							%{SPACE}=%{SPACE}\"%{GREEDYDATA:NAS_Identifier}\"%{SPACE}NAS-Port%{SPACE}=%{SPACE}
							%{INT:NAS_Port}%{SPACE}Called-Station-Id%{SPACE}=%{SPACE}\"%{GREEDYDATA:Called_Station_Id}\"
							%{SPACE}Calling-Station-Id%{SPACE}=%{SPACE}\"%{GREEDYDATA:Calling_Station_Id}\"%{SPACE}Framed-MTU
							%{SPACE}=%{SPACE}%{INT:Framed_MTU}%{SPACE}NAS-Port-Type%{SPACE}=%{SPACE}%{GREEDYDATA:NAS_Port_Type}
							%{SPACE}Connect-Info%{SPACE}=%{SPACE}\"%{GREEDYDATA:Connect_Info}\"%{SPACE}EAP-Message%{SPACE}=%{SPACE}
							%{GREEDYDATA:EAP_Message}%{SPACE}Message-Authenticator%{SPACE}=%{SPACE}%{GREEDYDATA:Message_Authenticator}"}
    patterns_dir => ["/opt/logstash/patterns"]
   }
 }
}
```

-Exemple creació de una pattern per al timestamp de radius (**/opt/logstash/patterns/radius**):

```
RADIUSTIMESTAMP %{SYSLOGTIMESTAMP} %{YEAR}
```

- Altres logs de Radius:

```
Thu Apr 20 07:56:29 2017
        Acct-Session-Id = "00000027-0000007F"
        Acct-Status-Type = Start
        Acct-Authentic = RADIUS
        User-Name = "tca4581336"
        NAS-IP-Address = 10.200.199.11
        NAS-Identifier = "002722fc065e"
        NAS-Port = 0
        Called-Station-Id = "0A-27-22-FD-06-5E:edt_alumnes"
        Calling-Station-Id = "4C-74-03-F1-79-B2"
        NAS-Port-Type = Wireless-802.11
        Connect-Info = "CONNECT 0Mbps 802.11b"
        Acct-Unique-Session-Id = "b31f3e631c6ac63d"
        Timestamp = 1492667789
        
Thu Apr 20 08:19:35 2017
        Acct-Session-Id = "00000027-0000007F"
        Acct-Status-Type = Stop
        Acct-Authentic = RADIUS
        User-Name = "tca4581336"
        NAS-IP-Address = 10.200.199.11
        NAS-Identifier = "002722fc065e"
        NAS-Port = 0
        Called-Station-Id = "0A-27-22-FD-06-5E:edt_alumnes"
        Calling-Station-Id = "4C-74-03-F1-79-B2"
        NAS-Port-Type = Wireless-802.11
        Connect-Info = "CONNECT 0Mbps 802.11b"
        Acct-Session-Time = 1385
        Acct-Input-Packets = 12800
        Acct-Output-Packets = 21220
        Acct-Input-Octets = 1539710
        Acct-Output-Octets = 26632291
        Event-Timestamp = "Apr 20 2017 08:19:34 CEST"
        Acct-Terminate-Cause = User-Request
        Acct-Unique-Session-Id = "b31f3e631c6ac63d"
        Timestamp = 1492669175
```

- Exemple filtre radius on ``Acct-Status-Type = Start`` :

```
%{RADIUSTIMESTAMP:radius_timestamp}%{SPACE}Acct-Session-Id%{SPACE}=%{SPACE}\"%{GREEDYDATA:Acct_Session_Id}\"%{SPACE}Acct-Status-Type%{SPACE}=%{SPACE}%{GREEDYDATA:Acct_Status_Type}%{SPACE}Acct-Authentic%{SPACE}=%{SPACE}%{GREEDYDATA:Acct_Authentic}%{SPACE}User-Name%{SPACE}=%{SPACE}\"%{GREEDYDATA:User_Name}\"%{SPACE}NAS-IP-Address%{SPACE}=%{SPACE}%{IPV4:NAS_IP_Address}%{SPACE}NAS-Identifier%{SPACE}=%{SPACE}\"%{GREEDYDATA:NAS_Identifier}\"%{SPACE}NAS-Port%{SPACE}=%{SPACE}%{INT:NAS_Port}%{SPACE}Called-Station-Id%{SPACE}=%{SPACE}\"%{GREEDYDATA:Called_Station_Id}\"%{SPACE}Calling-Station-Id%{SPACE}=%{SPACE}\"%{GREEDYDATA:Calling_Station_Id}\"%{SPACE}NAS-Port-Type%{SPACE}=%{SPACE}%{GREEDYDATA:NAS_Port_Type}%{SPACE}Connect-Info%{SPACE}=%{SPACE}\"%{GREEDYDATA:Connect_Info}\"%{SPACE}Acct-Unique-Session-Id%{SPACE}=%{SPACE}\"%{GREEDYDATA:Acct_Uniq_Sess_Id}\"%{SPACE}Timestamp%{SPACE}=%{SPACE}%{INT:timestamp}
```

Com podem observar cada filtre que volem afegir ha de començar amb el tipus de log (ldap, samba, syslog...).

- Exemple de Output que enviem a ElasticSearch:

```
output {
  elasticsearch { hosts => ["localhost:9200"]
    hosts => "localhost:9200"
    manage_template => false
    index => "%{[@metadata][beat]}-%{+YYYY.MM.dd}"
    document_type => "%{[@metadata][type]}"
  }
}
```

### Altres utilitats dels filtres de Logstash

- Excloure camps: 

```
mutate {
  remove_field => ["%{beat}"] # Esborra tot el camp Beat
}
```

```
mutate {
  remove_field => ["%{[beat][hostname]}"] # Esborrar un camp niat
}
```

- Crear condicions: 

```
if [operation_name] == "DEL" { # Només es complirá si el nom de l'operació es DEL
  grok {
    match => [ "data", "dn=\"%{DATA:del_dn}\"%{SPACE}$" ]
    remove_field => [ "data" ]
  }
}
```

En aquesta web, [Grok Debugger](https://grokdebug.herokuapp.com/ "Grok Debugger"),
podrem probar els nostres groks i comprovar si coincideixen amb les condicions que creem.
