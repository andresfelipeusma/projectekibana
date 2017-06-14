# ElasticSearch

ElasticSearch es un tecnologia de recerca i anàlisis de codi obert bastant 
escalable. Permet emmagatzemar, trobar i analitzar grans volums de dades
ràpidament i en temps real (casi). Generalment s'utilitza com a tecnologia
que potencia les aplicacions que tenen característiques de recerca complexes
i requisits.

## Conceptes basics

**Near Realtime** (NRT): ES es una plataforma de cerca que funciona
casi en temps real. Això significa que hi ha una lleu latència (normalment
un segon) entre el temps que tu indexes un document fins el moment en que el 
pots cercar.

**Node**: es un servidor que forma part del cluster, emmagatzema les dades
i participa en la indexació i les capacitats de recerca que proporciona el cluster.
El node esta identificat per el seu nom per defecte es un UUID, aquest nom
es important per propòsits administratius on tu vols identificar quins servers
de la teva xarxa corresponen al node en el teu ES cluster.

**Cluster**: es una col·lecció de un o més nodes (servers) que en conjunt 
contenen totes les dades i proporcionen capacitats d'indexació i recerca.
El cluster esta identificat per un únic nom per defecte es "elasticsearch",
aquest nom es important ja que el node només pot formar part del cluster 
al qual s'afegirà per el seu nom.

**Index**: es una col·lecció de documents que tenen característiques similars.
Per exemple, index per a dades del client, index per productes d'un catalog...
L'index està identificat pel seu nom (ha de estar en minúscules) ja que
es usat per referir-se al index quan es fan recerques, actualitzacions o esborrar
els documents que contenen. En un sol cluster pots definir els index que tu 
vulguis.

**Type**: dins de un index pots definir un o més "types". Un "type" es una 
categoria/partició lògica dels teus index on la semàntica depèn completament
del usuari. En general, es defineix un "type" per documents que tenen molts
camps en comú.

**Document**: es una unitat bàsica de informació que pots indexar. Per exemple
pots tenir documents però a un sol client, un altre per a un sol producte i un altre
per a una sola comanda. Aquest document s'expressa en JSON. Aquest document
ha d'estar indexat/assignat en un "type" dins de un index.

## Exemples d'ús de ElasticSearch

1 -> En cas de tenir una web de venta de productes, has de permetre
als teus clients fer cerques d'aquests productes. En aquest cas pots
utilitzar ElasticSearch per emmagatzemar el catalog dels productes i 
l'inventari i proporcionar una cerca amb suggerències d'auto-completar.

2 -> Vols recopilar logs o dades de transaccions i desitgeu analitzar-les,
mirar les tendències, estadístiques, sumaritzacions o anomalies. En aquest cas
pots utilitzar Logstash (part de ELK stack) per recollir, agregar i parsejar
les dades. Amb aquestes dades pots alimentar ElasticSearch i fer cerques.

3 -> Per exemple, tens una plataforma de alertes dels preus, es a dir
el client especifica una regla com la següent: "Estic interessat en comprar
un aparell electrònic i vull estar notificat quan el preu d'aquest aparell 
baixi de X euros de qualsevol venedor durant el mes següent". En aquest cas
pots retallar el preus dels proveïdors, introduir-los en ElasticSearch i 
utilitzar la capacitat de cerca inversa (Percolator) per comparar els moviments
de preus amb les consultes de clients i eventualment enviar alertes al client
una vegada es trobin els resultats.

Podem fer consultes a la BD de ElasticSEarch amb l'ordre curl com per exemple:

Mostrar els index que tenim a la BD de ElasticSearch:
 
``curl -XGET 'http://localhost:9200/filebeat-*/_search?pretty'``

Esborrar un index de la BD:

``curl -XDELETE 'localhost:9200/filebeat-2017.04.26'``


