# Kibana configuració (Port 5601)
Editem el fitxer **/etc/kibana/kibana.yml**,
cambiem ``server.host:0.0.0.0`` per ``server.host:localhost``, descomentem les linees ``server.host`` i ``elasticsearch.url``.

Per comprovar que kibana s'ha instalat correctament, engeguem el servei ``kibana.service`` executem al navegador ``localhost:5601``.
També podem comprovar amb ``netstat -plntu`` que el port 5601 está escoltant.
