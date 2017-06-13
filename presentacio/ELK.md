# Elastic Search, Logstash, Kibana (ELK)  

**Alumne:** Andrés Felipe Usma Montenegro  
**Clase:** 2 ASIX  
**Curs:** 2016-2017  

---
ELK son un conjunt de tecnologies que juntes poden oferir deteccions de incidències en organitzacions de gran mida.  

- Filebeat s'encarrega d'enviar els registres desde un client, a un fitxer, a Elastic Search o a Logstash.  

- Logstash es el parsejador de les dades que provenen de diverses fonts i que filtrades podem prescindir d'alguna part del missatge que no es important.  

- Elastic Search fa el paper de servidor de recerques on s'emmagatzemen les dades ja optimitzades per la indexació.  

- Kibana serveix per analitzar, crear grafics, i visualitzar en temps real els registres rebuts de les bases de dades de Elastic Search.  

- Cadascun es pot utilitzar com a eina independent però la unió d'aquests crea una combinació perfecta per a la gestió de registres.  

---

**Filebeat**

FileBeat té com a funció rebre els registres de directoris o directament
de fitxers per a finalment enviar-los a Elastic Search o Logstash. El funcionament es el següent,
quan iniciem FileBeat fa una recerca de les rutes que tu l'hi afegeixes als prospectors.
Per cada fitxer que troba FileBeat inicia un recol·lector. Cada recol·lector llegeix un fitxer de log 
i finalment l'envia a Logstash.
