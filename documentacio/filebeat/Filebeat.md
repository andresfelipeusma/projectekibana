# Beats

Els Beats son carregadors de dades de codi obert, bàsicament s'instal·len
com agents als servidors. Poden enviar dades directament a ElasticSearch
o enviar-les mitjançant Logstash a ElasticSearch. Hi han diferents tipus de 
Beats (PacketBeat, FileBeat, MetricBeat i WinLogBeat), però el més utilitzat
es FileBeat.

## FileBeat

FileBeat té com a funció monitoritzar els logs de directoris o directament
de fitxers i finalment enviar-los a ES o Logstash. El funcionament es el següent,
quan iniciem FileBeat fa una recerca de les rutes que tu l'hi afegeixes als prospectors.
Per cada fitxer que troba FileBeat inicia un recol·lector. Cada recol·lector llegeix un fitxer de log 
i finalment l'envia a Logstash.

### Prospector

El prospector es el responsable de gestionar els recol·lectors i trobar totes les fonts
que ha de llegir. Exemple de un prospector:

```
filebeat.prospectors:
- input_type: log
  paths:
    - /var/log/*.log
    - /var/path2/*.log
```

### Harvester/Recolector

El recol·lector es el responsable de llegir el contingut de un fitxer de logs. 
Llegeix línia a línia el fitxer i envia el contingut al output. S'inicia un
recol·lector per cada fitxer, també es responsable de obrir i tancar el fitxer.

### Fitxer de configuració

Els fitxers de configuració dels Beats estan basats en YAML. La primera part
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

També podem definir una sortida al client per veure si els logs s'han enviat o no:

```
output.file:
  path: "/tmp/filebeat"
  filename: filebeat
```

Finalment cal definir el output, on enviarem els logs:

```
output.logstash:
  # Host que té Logstash en funcionament
  hosts: ["10.250.100.190:5044"]
  bulk_max_size: 1024
  # SSL
  ssl.certificate_authorities: ["/etc/pki/tls/certs/logstash-forwarder.crt"]
  template.name: "filebeat"
  template.path: "filebeat.template.json"
  template.overwrite: false
```

Filebeat per defecte llegeix línia a línia els fitxers de log,
per tant si tens un fitxer amb el següent format et llegirá cada línia com a nou log:

```
[2017/05/07 04:12:44,  0] lib/util_sock.c:1491(get_peer_addr_internal)
  getpeername failed. Error was Transport endpoint is not connected
[2017/05/07 04:12:44,  0] lib/access.c:410(check_access)
[2017/05/07 04:12:44,  0] lib/util_sock.c:1491(get_peer_addr_internal)
  getpeername failed. Error was Transport endpoint is not connected
```

Per evitar això i poder utilitzar fitxers de logs multilínia, podem afegir
la següent configuració al filebeat:

```
multiline.pattern: '^\[[0-9]{4}\/[0-9]{2}\/[0-9]{2}' # Aqui definim el patró que identificará una línia com a nova.
multiline.negate: true 
multiline.match: after
```

Test per comprovar que no hi han errades al fitxer de configuració:

```filebeat.sh -c /etc/filebeat/filebeat.yml -configtest```

