## Creació del certificat SSL Autosignat
Primer afegim al fitxer **/etc/pki/tls/openssl.conf** la linea ``subjectAltName = IP: ip_server``.
Generem el certificat:

```openssl req -config /etc/pki/tls/openssl.cnf -x509 -days 3650 -batch -nodes -newkey rsa:2048 -keyout /etc/pki/tls/private/logstash-forwarder.key -out /etc/pki/tls/certs/logstash-forwarder.crt```
Nota: cal generar el certificat al servidor i enviar-ho als clients.

## Creació dels certificats signats per una CA
