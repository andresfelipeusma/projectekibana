# Instalació dels paquets ELK (Elastic search, Logstash, Kibana)

## Afegir la clau GPG per poder descarregar-nos els paquets necessaris.
``rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch``

## Elastic Search instalació.
Primer ens descarreguem el paquet rpm del ElasticSearch:

``wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-5.1.1.rpm``

Instalem el rpm:
``rpm -ivh elasticsearch-5.1.1.rpm``

Per comprovar que ElasticSearch s'ha instalat correctament engeguem el servei ``elasticsearch.service`` i
executem al navegador ``localhost:9200``. També podem comprovar amb ``netstat -plntu`` que el port 9200 está escoltant. 

## Kibana instalació.
Primer ens descarreguem el paquet rpm del Kibana:

``wget https://artifacts.elastic.co/downloads/kibana/kibana-5.1.1-x86_64.rpm``

Instalem el rpm:

``rpm -ivh kibana-5.1.1-x86_64.rpm``

Iniciem el servei Kibana, ``systemctl start Kibana.service``.

## Instalació del Nginx (Proxy HTTP)
Ens descarreguem el paquet ``dnf -y install nginx httpd-tools``.

Iniciem el servei Nginx, ``systemctl start Nginx.service``.

## Logstash instalació.
Primer ens descarreguem el paquet rpm del Kibana:

``wget https://artifacts.elastic.co/downloads/logstash/logstash-5.1.1.rpm``

Instalem el rpm:

``rpm -ivh logstash-5.1.1.rpm``

Finalment iniciem el servei logstash, ``systemct start Logstash.service``.


## Instalació del Index Filebeat.
Descarreguem el paquet ``wget https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-5.1.1-x86_64.rpm`` i 
ho instalem ``rpm -ivh filebeat-5.1.1-x86_64.rpm``.

Fonts:

- [Web Oficial ELK](https://www.elastic.co/guide/index.html)
- [Tutorial Instalació](https://www.digitalocean.com/community/tutorials/how-to-use-logstash-and-kibana-to-centralize-logs-on-centos-6)
