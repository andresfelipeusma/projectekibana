# Elastic Search, Logstash, Kibana (ELK)

Alumne: Andrés Felipe Usma Montenegro  
Clase: 2 Hisix  
Curs: 2016-2017  

---
ELK stack son tres eines amb aquestes característiques, juntes poden oferir
deteccions de incidències en una organització de gran mida. Logstash es el parsejador
de les dades que provenen de diverses fonts i que filtrades podem prescindir d'alguna 
part del missatge que no es important. ElasticSearch fa el paper de servidor de recerques
on s'emmagatzemen les dades ja optimitzades per la indexació. Kibana es el front-end
per a la visualització i anàlisi de dades. Cadascun es pot utilitzar com a eina 
independent però la unió d'aquests crea una combinació perfecta per a la gestió
de registres. 

**Funcionament**

La monitorització de dades depèn de 4 aspectes importants:

- Carrega de dades (Filebeat): ja sigui mitjançant un beat, un fitxer de logs...
d'alguna forma hem d'enviar els logs a Logstash.

- Enviament i recopilació (Logstash): eines amb capacitat d'enviar 
qualsevol format de logs/dades, facilitat per escollir inputs, crear filtres
i enviar la informació rellevant.
 
- Emmagatzematge i retenció de dades (ElasticSearch): eines amb capacitat 
de fer cerques completes i emmagatzemar les dades en una Base de dades.

- Anàlisi i visualització (Kibana): eines amb capacitat de crear dashboards
i gràfiques amb facilitat donats aquestes dades.

---
## FileBeat

FileBeat té com a funció monitoritzar els logs de directoris o directament
de fitxers i finalment enviar-los a ES o Logstash. El funcionament es el següent,
quan iniciem FileBeat fa una recerca de les rutes que tu l'hi afegeixes als prospectors.
Per cada fitxer que troba FileBeat inicia un recol·lector. Cada recol·lector llegeix un fitxer de log 
i finalment l'envia a Logstash.

### Prospectors
Son els responsables de gestionar els recol·lectors i trobar totes les fonts que ha de llegir.

Exemple:

```
filebeat.prospectors:
- input_type: log
  paths:
    - /var/log/*.log
    - /var/path2/*.log
```

---
### Harvester/Recol·lector
Responsable de llegir el contingut dels fitxers de logs. Llegeix línia a línia el fitxer
les processa i les envia al output.

---
# Logstash
Logstash es una plataforma de codi obert que ens permet fer una recol·lecció
de dades amb la capacitat de canalitzar en temps real. Pot unificar
dinàmicament dades de diverses fonts i normalitzar-les. 

Originalment Logstash va impulsar la innovació en la recopilació de registes,
però les seves capacitats s'extendeixen molt més. Qualsevol tipus d'event
es pot transformar en una amplia gama d'inputs, filtres i output plugins.

El procès de logstash es basa en 3 etapes: **inputs -> filters -> output**. 

---
## Inputs
Utilitzats per rebre dades i guardar-les a Logstash. Hi han varis
tipus de Inputs però els més usats són **File** (llegeix les dades a partir
de un fitxer del sistema), **Syslog** (escolta el port 514 per missatges syslogs
i els parseja mitjançant el format RFC3164), **Beats** (processa els esdeveniments enviats per Filebeat).

## Filtres
Serveixen per editar els logs que rebem que mitjançant certes condicions
es crearà un tipus de log o un altre. Alguns filtres útils **Grok** (parseja
logs desestructurats i els cambia per logs estructurats i cercables), 
**Mutate** (performa transformacions en els camps dels logs rebuts), 
**Drop** (esborra algun camp del log que no volem, per exemple debugs...),
**Clone** (crea una copia de un event), **GeoIp** (afegeix informació com
la localització geogràfica de una ip).

---
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

---
