## Creació del certificat SSL Autosignat

Primer afegim al fitxer **/etc/pki/tls/openssl.conf** la linea ``subjectAltName = IP: ip_server``.
Generem el certificat:

```
openssl req -config /etc/pki/tls/openssl.cnf -x509 -days 3650 -batch -nodes -newkey rsa:2048 -keyout /etc/pki/tls/private/logstash-forwarder.key -out /etc/pki/tls/certs/logstash-forwarder.crt
```

**Nota**: cal generar el certificat al servidor i enviar-ho als clients mitjançant scp.

## Creació dels certificats signats per una CA

- 1r. Generem la clau privada de la CA i el seu certificat autosignat: 

```
openssl genrsa -nodes -out CAkey.pem 2048

openssl req -new -x509 -nodes -out CA.crt -key CAkey.pem
```

- 2n. Generem la clau privada del client/servidor: 

```
openssl genrsa -nodes -out Server.key 2048
```

- 3r. Desde el client/servidor generem la petició de certificat: 

```
openssl req -new -key Server.key -out server.req
```

- 4rt. Com a CA creem el fitxer ca.conf on afegirem les següent línies:

```
basicConstraints = critical,CA:FALSE
extendedKeyUsage = serverAuth,emailProtection
subjectAltName = IP: ip_servidor_kibana
```

- 5é. Com a CA signem aquest certificat amb les extensions creades al pas previ, 

```
openssl x509 -CA CA.crt -CAkey CAkey.pem -req -in server.req -days 365 -sha256 -extfile ca.conf -CAcreateserial -out server.crt
```

- 6é. Validar el certificat:

```
curl -v --cacert ca.crt https://10.250.100.190:5044
```

Fonts:

[Elastic SSL](https://www.elastic.co/guide/en/beats/filebeat/current/configuring-ssl-logstash.html)
[Tutorial Configuració Certs](https://www.digitalocean.com/community/tutorials/how-to-install-elasticsearch-logstash-and-kibana-elk-stack-on-ubuntu-14-04#generate-ssl-certificates)
