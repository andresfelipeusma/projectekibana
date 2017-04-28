## ElasticSearch
ElasticSearch es un motor d'emmagatzament, cerca y anàlisi en temps real. 
Pot utilitzarse per a molts proposits, pero el principal es la indexació 
del fluxe de dades semiestructurades (registres, paquets de xarxa decodificats...)

## Logstash (opcional)
Logstash es l'arquitectura més senzilla per la configuració de la plataforma
Beats, consisteix en un o més Beats, ElasticSearch i kibana. S'encarrega de
la recolecció de logs, parsejarlos i emmagatzermar-los en ElasticSearch.

## Kibana
Kibana es una interfície que recull dades del ElasticSearch. Consisteix en una
aplicació web dinámica en Javascript que ens permet crear dashboards o realitzar
cerques facilment, també permet generar grafics.

## Nginx
Servidor proxy.

https://www.howtoforge.com/tutorial/how-to-install-elastic-stack-on-centos-7/

filebeat.prospectors ( de on treiem els logs )

Leer el GROK (parametros del message log)
https://www.elastic.co/guide/en/logstash/current/plugins-filters-grok.html
