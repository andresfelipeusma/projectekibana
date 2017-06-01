# Elastic Search configuració (Port 9200).
Editem el fitxer de configuració **/etc/elasticsearch/elasticsearch.yml**,
descomentem la linea ``#network.host`` i la cambiem per 
```network.host: localhost```, també descomentem la linea ``bootstrap.memory_lock: true``.

Descomentem del fitxer **/usr/systemd/system/elasticsearch.service** la seguent linea ``LimitMEMLOCK=infinity``,
del fitxer **/etc/sysconfig/elasticsearch** descomentem la linea ``MAX_LOCKED_MEMORY=unlimited``.

Finalment iniciem el servei ElasticSearch, ``systemctl start ElasticSearch.service``.
