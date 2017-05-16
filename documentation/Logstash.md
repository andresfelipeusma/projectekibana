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

Exemple de Input que ens envia el Filebeat:

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


Exemple de filtre LDAP:

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

Exemple de filtre Syslog:

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

Exemple de filtre Samba:

```
filter {
 if [type] == "samba" {
  grok {
    add_tag => ["samba","grooked"]
    match =>["message", [ "\[%{SAMBATIME:samba_timestamp},%{SPACE}%{NUMBER:severity_code}\] %{DATA:samba_class} %{GREEDYDATA:samba_message}", "\[%{SAMBATIME:samba_timestamp},%{SPACE}%{NUMBER:severity_code}\]%{GREEDYDATA:samba_class}" ] ]
    patterns_dir => ["/opt/logstash/patterns"]
   }
 }
}

```
Com podem observar cada filtre que volem afegir ha de començar amb el tipus de log (ldap, samba, syslog...).

Exemple de Output que enviem a ElasticSearch:

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
