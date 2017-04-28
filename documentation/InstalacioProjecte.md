# Instalació dels paquets ELK (Elastic search, Logstash, Kibana)

## Afegir la clau GPG per poder descarregar-nos els paquets necessaris.
``rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch``

## Elastic Search instalació.
Primer ens descarreguem el paquet rpm del ElasticSearch:

``wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-5.1.1.rpm``

Instalem el rpm:
``rpm -ivh elasticsearch-5.1.1.rpm``

### Elastic Search configuració (Port 9200).
Editem el fitxer de configuració **/etc/elasticsearch/elasticsearch.yml**,
descomentem la linea ``#network.host`` i la cambiem per 
```network.host: localhost```, també descomentem la linea ``bootstrap.memory_lock: true``.

Descomentem del fitxer **/usr/systemd/system/elasticsearch.service** la seguent linea ``LimitMEMLOCK=infinity``,
del fitxer **/etc/sysconfig/elasticsearch** descomentem la linea ``MAX_LOCKED_MEMORY=unlimited``.

Per comprovar que ElasticSearch s'ha instalat correctament engeguem el servei ``elasticsearch.service`` i
executem al navegador ``localhost:9200``. També podem comprovar amb ``netstat -plntu`` que el port 9200 está escoltant. 

## Kibana instalació.
Primer ens descarreguem el paquet rpm del Kibana:

``wget https://artifacts.elastic.co/downloads/kibana/kibana-5.1.1-x86_64.rpm``

Instalem el rpm:
``rpm -ivh kibana-5.1.1-x86_64.rpm``

### Kibana configuració (Port 5601)
Editem el fitxer **/etc/kibana/kibana.yml**,
cambiem ``server.host:0.0.0.0`` per ``server.host:localhost``, descomentem les linees ``server.host`` i ``elasticsearch.url``.

Per comprovar que kibana s'ha instalat correctament, engeguem el servei ``kibana.service`` executem al navegador ``localhost:5601``.
També podem comprovar amb ``netstat -plntu`` que el port 5601 está escoltant.

## Instalació del Nginx (Proxy HTTP)
Ens descarreguem el paquet ``dnf -y install nginx httpd-tools``.

### Nginx configuració.
Del fitxer **/etc/nginx/nginx.conf** esborrem el block ``server{}``.
Creem el fitxer **/etc/nginx/conf.d/kibana.conf** per poder afegir una nova virtual host
i afegim el següent bloc:
```
server {
    listen 80;
 
    server_name andres_elk.co;
 
    auth_basic "Restricted Access";
    auth_basic_user_file /etc/nginx/.kibana-user;
 
    location / {
        proxy_pass http://localhost:5601;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
```
Creem les creedencials per autenticar-nos ``htpasswd -c /etc/nginx/.kibana-user admin``.
Finalment iniciem el servei nginx. 
Nota: cal tenir el http apagat per que pugui funcionar el proxy.

## Logstash instalació.
Primer ens descarreguem el paquet rpm del Kibana:

``wget https://artifacts.elastic.co/downloads/logstash/logstash-5.1.1.rpm``

Instalem el rpm:
``rpm -ivh logstash-5.1.1.rpm``

## Creació del certificat SSL 
Primer afegim al fitxer **/etc/pki/tls/openssl.conf** la linea ``subjectAltName = IP: ip_server``.
Generem el certificat:
``openssl req -config /etc/pki/tls/openssl.cnf -x509 -days 3650 -batch -nodes -newkey rsa:2048 -keyout /etc/pki/tls/private/logstash-forwarder.key -out /etc/pki/tls/certs/logstash-forwarder.crt``
Al directori **/etc/logstash/conf.d/** cal crear 3 fitxers de configuració (filebeat-input.conf, syslog-filter.conf, output-elasticsearch.conf).
01-filebeat-input.conf:
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
10-syslog-filter.conf (el plugin grok ens permet parsejar els fitxers de logs):
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
30-output-elasticsearch.conf:
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
Finalment iniciem el servei logstash.

## Instalació del Index Filebeat.
Descarreguem el paquet ``wget https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-5.1.1-x86_64.rpm`` i 
ho instalem ``rpm -ivh filebeat-5.1.1-x86_64.rpm``.

## Configuració Filebeat al client
Primer de tot enviem al client el certificat generat previament mitjançant scp.
``scp /etc/pki/tls/certs/logstash-forwarder.crt root@remote_host:/etc/pki/tls/certs/.``

Editem el fitxer de configuració **/etc/filebeat/filebeat.yml**:
```
  paths(En aquesta secció li diem al filebeat d'on agafar els logs):  
    - /var/log/audit/audit.log  
  document-type: syslog  
  output.logstash:  
    ->The Logstash hosts  
      hosts: ["ip_server:port_logstash_server"]  
      bulk_max_size: 1024  
      ssl.certificate_authorities: ["/etc/pki/tls/certs/logstash-forwarder.crt"]  
      template.name: "filebeat"  
      template.path: "filebeat.template.json"  
      template.overwrite: false
```
