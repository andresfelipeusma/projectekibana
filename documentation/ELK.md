# Elastic Search, Logstash, Kibana (ELK)

ELK stack son tres eines amb aquestes característiques, juntes poden oferir
deteccions de incidències en una organització de gran mida. Logstash es el parsejador
de les dades que provenen de diverses fonts i que filtrades podem prescindir d'alguna 
part del missatge que no es important. ElasticSearch fa el paper de servidor de recerques
on s'emmagatzemen les dades ja optimitzades per la indexació. Kibana es el front-end
per a la visualització i anàlisi de dades. Cadascun es pot utilitzar com a eina 
independent però la unió d'aquests crea una combinació perfecta per a la gestió
de registres. 

## Funcionament

La monitorització de dades depèn de 3 aspectes importants:

- Enviament i recopilació (Logstash): eines amb capacitat d'enviar 
qualsevol format de logs/dades, facilitat per escollir inputs, crear filtres
i enviar la informació rellevant.
 
- Emmagatzematge i retenció de dades (ElasticSearch): eines amb capacitat 
de fer cerques completes i emmagatzemar les dades en una Base de dades.

- Anàlisi i visualització (Kibana): eines amb capacitat de crear dashboards
i gràfiques amb facilitat donats aquestes dades.

