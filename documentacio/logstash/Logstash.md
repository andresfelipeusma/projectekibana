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
