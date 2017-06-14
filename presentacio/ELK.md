# Elastic Search, Logstash, Kibana (ELK)  

**Alumne:** Andrés Felipe Usma Montenegro  
**Clase:** 2 ASIX  
**Curs:** 2016-2017  

---

ELK son un conjunt de tecnologies que juntes poden oferir deteccions de incidències en organitzacions de gran mida.  

- Filebeat s'encarrega d'enviar els registres desde un client, a un fitxer, a Elastic Search o a Logstash.  

- Logstash es el parsejador de les dades que provenen de Filebeat i que filtrades podem prescindir d'alguna part del missatge que no es important.  

- Elastic Search fa el paper de servidor de recerques on s'emmagatzemen les dades ja optimitzades per la indexació.  

- Kibana serveix per analitzar, crear gràfics, i visualitzar en temps real els registres rebuts de les bases de dades de Elastic Search.  

- Cadascun es pot utilitzar com a eina independent però la unió d'aquests crea una combinació perfecta per a la gestió de registres.  

---

**Filebeat**

FileBeat té com a funció rebre els registres de directoris o directament
de fitxers per a finalment enviar-los a Elastic Search o Logstash. El funcionament es el següent,
quan iniciem FileBeat fa una recerca de les rutes que tu l'hi afegeixes als prospectors.
Per cada fitxer que troba FileBeat inicia un recol·lector. Cada recol·lector llegeix un fitxer de log 
i finalment l'envia a Logstash.

**Prospectors:** son els responsables de gestionar els recol·lectors i trobar totes les fonts que ha de llegir(fitxers...).  

Exemple (/etc/filebeat/filebeat.yml):  

```
filebeat.prospectors:
  input_type: log  
  paths:  
    - /var/log/radius.log  
    - /var/log/radius_detail.log  
  document_type: radius
```

**Harvester/Recol·lector:** llegeixen el contingut dels fitxers de logs. Llegeix línia a línia el fitxer
les processa i les envia al output(Elastic Search, fitxer de text...).  

---

**Logstash**

Logstash és una plataforma de codi obert que ens permet fer una recol·lecció
de dades amb la capacitat de canalitzar en temps real. Pot unificar
dinàmicament dades de diverses fonts i normalitzar-les. 

Originalment Logstash va impulsar la innovació en la recopilació de registes,
però les seves capacitats s'extendeixen molt més. Qualsevol tipus d'event
es pot transformar en una amplia gama d'inputs, filtres i output plugins.

El procès de logstash es basa en 3 etapes: **inputs -> filtres -> output**. 

---

**Inputs**: utilitzats per rebre registres i guardar-los a Logstash. Hi han varis
tipus de Inputs però els més usats són fitxers (llegeix les dades a partir
de un fitxer del sistema), syslog (escolta el port 514 per missatges syslogs
i els parseja mitjançant el format RFC3164), Beats (processa els registres enviats per Filebeat).

Exemple de _Input_: 

```
input {  
  beats {  
    port => 5044  
    ssl => true  
    ssl_certificate => "/var/tmp/logstash-forwarder.crt"  
    ssl_key => "/var/tmp/private/logstash-forwarder.key"  
  }  
}  
```

Bàsicament al input, assignem quin port escoltem per rebre els registres i si volem tenir
un trànsit segur mitjançant ssl.

---

**Filtres**: serveixen per editar els logs que rebem, aquests logs han de complir el _match_ 
que nosaltres creem mitjançant **Grok**. 

**Grok**: aquesta eina ens permet organitzar els logs que rebem de manera estructurada i arbitrària.

Exemple log de _Samba_:

```
[2017/05/07 03:48:30, 0] lib/util_sock.c:1491 getpeername failed. 
Error was Transport endpoint is not connected
```

Com hauria de ser el _Grok_:

```
"\[%{SAMBATIME:samba_timestamp}, %{NUMBER:severity_code}\] 
%{GREEDYDATA:samba_class}. %{GREEDYDATA:samba_message}" 
```

--- 

Exemple de _Filtre_:

```
filter {
 if [type] == "samba" {
  grok {
    add_tag => ["samba","grooked"]
    match =>{ "message" => "\[%{SAMBATIME:samba_timestamp},
    %{NUMBER:severity_code}\]%{GREEDYDATA:samba_class}
    %{GREEDYDATA:samba_message}" }
    patterns_dir => ["/opt/logstash/patterns"]
   }
 }
}
```

En aquesta etapa assignem el tipus del log, podem afegir tags(després es poden veure en Kibana),
tenir un directori amb plantilles de Grok que generem nosaltres, i finalment el camp _match_
que si tot ha anat correcte ens transformará l'estructura del registre.

---

**Output**: és l'ultima etapa pel qual pasa el registre. Tenim diferents opcions a on enviar els registres
modificats, ja sigui a un fitxer local, a Elastic Search o a l'aplicació Graphite. 

Exemple de _Output_:

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

En aquest exemple enviem els registres a Elastic Search, definint el host i el port on es troba
Elastic Search treballant, afegim un index al registre ja que es necessari per Elastic Search i 
finalment el tipus de document que es.

--- 

**Elastic Search**

Elastic Search es un tecnologia de recerca i anàlisis de codi obert bastant escalable. 
Permet emmagatzemar, trobar i analitzar grans volums de dades ràpidament i en temps real (casi). 
Generalment s'utilitza com a tecnologia que potencia les aplicacions que tenen característiques de recerca complexes 
i requisits.
