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

**Cluster**: es una colecció.

## Exemples d'ús de ElasticSearch

1 -> En cas de tenir una web de venta de productes, has de permetre
als teus clients fer cerques d'aquests productes. En aquest cas pots
utilitzar ElasticSearch per emmagatzemar el catalog dels productes i 
l'inventari i proporcionar una cerca amb suggerencias d'auto-completar.

2 -> Vols recopilar logs o dades de transaccions i desitgeu analitzar-les,
mirar les tendències, estadístiques, sumaritzacions o anomalies. En aquest cas
pots utilitzar Logstash (part de ELK stack) per recollir, agregar i parsejar
les dades. Amb aquestes dades pots alimentar ElasticSearch i fer cerques.

3 -> Per exemple, tens una plataforma de alertes dels preus, es a dir
el client especifica una regla com la següent: "Estic interessat en comprar
un aparell electrònic i vull estar notificat quan el preu d'aquest aparell 
baixi de X euros de qualsevol venedor durant el mes següent". En aquest cas
pots retallar el preus dels proveeidors, introduir-los en ElasticSearch i 
utilitzar la capacitat de cerca inversa (Percolator) per comparar els moviments
de preus amb les consultes de clients i eventualment enviar alertes al client
una vegada es trobin els resultats.

  
