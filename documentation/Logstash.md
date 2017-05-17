# Logstash
Logstash es una plataforma de codi obert que ens permet fer una recol·lecció
de dades amb la capacitat de canalitzar en temps real. Pot unificar
dinàmicament dades de diverses fonts i normalitzar-les. 

Originalment Logstash va impulsar la innovació en la recopilació de registes,
però les seves capacitats s'extendeixen molt més. Qualsevol tipus d'event
es pot transformar en una amplia gama d'inputs, filtres i output plugins.

El procès de logstash es basa en 3 etapes: **inputs -> filters -> output**. 

## Inputs
Utilitzats per rebre dades i guardar-les a Logstash. Hi han varis
tipus de Inputs però els més usats són **File** (llegeix les dades a partir
de un fitxer del sistema), **Syslog** (escolta el port 514 per missatges syslogs
i els parseja mitjançant el format RFC3164), **Redis** (llegeix les dades a partir
de un servidor redis), **Beats** (processa els esdeveniments enviats per Filebeat).

## Filtres
Serveixen per editar els logs que rebem que mitjançant certes condicions
es crearà un tipus de log o un altre. Alguns filtres útils **Grok** (parseja
logs desestructurats i els cambia per logs estructurats i cercables), 
**Mutate** (performa transformacions en els camps dels logs rebuts), 
**Drop** (esborra algun camp del log que no volem, per exemple debugs...),
**Clone** (crea una copia de un event), **GeoIp** (afegeix informació com
la localització geogràfica de una ip).

## Outputs
Finalment en aquesta etapa es decideix a on enviem aquest logs parsejats i modificats.
Tenim varis tipus de outputs, **ElasticSearch** ( enviem els logs a ES ),
**File** (enviem els logs en un fitxer local), **Graphite** (envia dades a l'aplicació graphite)...

Estructura del fitxer on es junten les etapes previes:

```
input {
  ...
}

filter {
  ...
}

output {
  ...
}
```

- Exemple de Input que ens envia el Filebeat:

```
input {
  beats {
    port => 5044
    ssl => true
    ssl_certificate => "/etc/pki/tls/certs/logstash-forwarder.crt"
    ssl_key => "/etc/pki/tls/private/logstash-forwarder.key"
  }
}
```

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
%{SYSLOGTIMESTAMP:radius_timestamp}%{SPACE}%{YEAR}%{SPACE}Packet-Type = %{GREEDYDATA:Packet_type}%{SPACE}User-Name = "%{USERNAME:user_name}"%{SPACE}NAS-IP-Address = %{GREEDYDATA:NAS_IP_address}%{SPACE}NAS-Identifier = "%{UUID:NAS_Identifier}"%{SPACE}NAS-Port = %{INT:NAS_Port}%{SPACE}Called-Station-Id = "%{DATA:Called_Station_Id}"%{SPACE}Calling-Station-Id = "%{DATA:Calling_Station_Id}"%{SPACE}Framed-MTU = %{GREEDYDATA:Framed_MTU}%{SPACE}NAS-Port-Type = %{GREEDYDATA:NAS_Port_Type}%{SPACE}Connect-Info = "%{DATA:Connect_Info}"%{SPACE}EAP-Message = %{GREEDYDATA:EAP_Message}%{SPACE}Message-Authenticator = %{GREEDYDATA:Message_Authenticator}
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
