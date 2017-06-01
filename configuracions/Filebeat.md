# Configuració Filebeat al client
Primer de tot enviem al client el certificat generat previament mitjançant scp.

```scp /etc/pki/tls/certs/logstash-forwarder.crt root@remote_host:/etc/pki/tls/certs/.```

Editem el fitxer de configuració **/etc/filebeat/filebeat.yml**:

```
  paths(En aquesta secció li diem al filebeat d'on agafar els logs):  
    - /var/log/audit/audit.log  
  document-type: syslog  
  output.logstash:  
    #The Logstash hosts  
      hosts: ["ip_server:port_logstash_server"]  
      bulk_max_size: 1024  
      ssl.certificate_authorities: ["/etc/pki/tls/certs/logstash-forwarder.crt"]  
      template.name: "filebeat"  
      template.path: "filebeat.template.json"  
      template.overwrite: false
```

Reiniciem el servei Filebeat desde el client, ``systemctl restart Filebeat.service``.
