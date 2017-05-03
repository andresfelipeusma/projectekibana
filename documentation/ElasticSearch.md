# ElasticSearch

ElasticSearch es un tecnologia de recerca i analisis de codi obert bastant 
escalable. Permet emmagatzemar, trobar i analitzar grans volums de dades
rapidament i en temps real (casi). Generalment s'utilitza com a tecnologia
que potencia les aplicacions que tenen característiques de recerca complexes
i requisits.

## Conceptes basics

**Near Realtime** (NRT): ES es una plataforma de cerca que funciona
casi en temps real. Aixó significa que hi ha una lleu latencia (normalment
un segon) entre el temps que tu indexes un document fins el moment en que el 
pots cercar.

## Exemples d'ús de ElasticSearch

1 -> En cas de tenir una web de venta de productes, has de permetre
als teus clients fer cerques d'aquests productes. En aquest cas pots
utilitzar ElasticSearch per emmagatzemar el catalog dels productes i 
l'inventari i proporcionar una cerca amb suggerencias d'autocompletar.

2 -> Vols recopilar logs o dades de transaccions i desitjeu anatlizar-les,
mirar les tendencies, estadistiques, sumaritzacions o anomalies. En aquest cas
pots utilizar Logstash (part de ELK stack) per recollir, agregar i parsejar
les dades. Amb aquestes dades pots alimentar ElasticSearch i fer cerques.

3 -> Per exemple, tens una plataforma de alertes dels preus, es a dir
el client especifica una regla com la següent: "Estic interesat en comprar
un aparell electronic i vull estar notificat quan el preu d'aquest aparell 
baixi de X euros de qualsevol venedor durant el mes següent". En aquest cas
pots retallar el preus dels proveeidors, introduir-los en ElasticSearch i 
utilitzar la capacitat de cerca inversa (Percolator) per comparar els moviments
de preus amb les consultes de clients i eventualment enviar alertes al client
una vegada es trobin els resultats.

  
