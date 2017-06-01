# Logstash configuració

Al directori **/etc/logstash/conf.d/** cal crear 3 fitxers de configuració (filebeat-input.conf, syslog-filter.conf, output-elasticsearch.conf).

**01-filebeat-input.conf:**

```
input {
  beats {
    port => 5044
    ssl => true
    ssl_certificate => "/etc/pki/tls/certs/logstash-forwarder.crt"
    ssl_key => "/etc/pki/tls/private/logstash-forwarder.key"
  }
}
```

**10-syslog-filter.conf** (el plugin grok ens permet parsejar els fitxers de logs):

```
filter {
  if [type] == "syslog" {
    grok {
      match => { "message" => "%{SYSLOGTIMESTAMP:syslog_timestamp} %{SYSLOGHOST:syslog_hostname} %{DATA:syslog_program}(?:\[%{POSINT:syslog_pid}\])?: %{GREEDYDATA:syslog_message}" }
      add_field => [ "received_at", "%{@timestamp}" ]
      add_field => [ "received_from", "%{host}" ]
    }
    date {
      match => [ "syslog_timestamp", "MMM  d HH:mm:ss", "MMM dd HH:mm:ss" ]
    }
  }
}
```

**30-output-elasticsearch.conf:**

```
output {  
  elasticsearch { hosts => ["localhost:9200"]  
    hosts => "localhost:9200"  
    manage_template => false  
    index => "%{[@metadata][beat]}-%{+YYYY.MM.dd}"  
    document_type => "%{[@metadata][type]}"  
  }  
}
```

Reiniciem el servei Logstash, ``systemctl restart Logstash.service``.

Per comprovar que tot ha anat bé mirem els logs de Logstash, **/var/log/logstash_plain.log**.
