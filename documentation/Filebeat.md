# Beats

Els Beats son carregadors de dades de codi obert, basicament s'instal·len
com agents als servidors. Poden enviar dades directament a ElasticSearch
o enviar-les mitjançant Logstash a ElasticSearch. Hi han diferents tipus de 
Beats (PacketBeat, FileBeat, MetricBeat i WinLogBeat), però el més utilitzat
es FileBeat.

## FileBeat

FileBeat té com a funció monitoritzar els logs de directoris o directament
de fitxers i finalment enviar-los a ES o Logstash. El funcionament es el seguent,
quan iniciem FileBeat fa una recerca de les rutes que tu l'hi afegeixes als prospectors.
Per cada fitxer que troba FileBeat inicia un recolector. Cada recolector llegeix un fitxer de log 
i finalment l'envia a Logstash.

### Prospector

El prospector es el responsable de gestionar els recolectors i trobar totes les fonts
que ha de llegir. Exemple de un prospector:

```
filebeat.prospectors:
- input_type: log
  paths:
    - /var/log/*.log
    - /var/path2/*.log
```

### Harvester/Recolector

El recolector es el responsable de llegir el contingut de un fitxer de logs. 
Llegeix linea a linea el fitxer i envia el contingut al output. S'incia un
recolector per cada fitxer, també es responsable de obrir i tancar el fitxer.

### Fitxer de configuració

Els fitxers de configuració dels Beats están basats en YAML. La primera part
important d'aquest fitxer es la definició dels prospectors:

```
filebeat.prospectors:

# Cada - es un prospector. 

- input_type: log

  # Rutes de on volem extreure els logs.
  paths:
     - /var/log/openldap_example.log.1
  document_type: ldap (Aquesta entrada serveix per tagejar el log per desprès poder parsejar-lo amb Logstash.
```

``
output.file:
  path: "/tmp/filebeat"
  filename: filebeat
`` 
