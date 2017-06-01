# Nginx configuració

Del fitxer **/etc/nginx/nginx.conf** esborrem el block ``server{}``.
Creem el fitxer **/etc/nginx/conf.d/kibana.conf** per poder afegir una nova virtual host
i afegim el següent bloc:

```
server {
    listen 80;
 
    server_name andres_elk.co;
 
    auth_basic "Restricted Access";
    auth_basic_user_file /etc/nginx/.kibana-user;
 
    location / {
        proxy_pass http://localhost:5601;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
```

Creem les creedencials per autenticar-nos ``htpasswd -c /etc/nginx/.kibana-user admin``.

Finalment iniciem el servei nginx. 

Nota: *cal tenir el http apagat per que pugui funcionar nginx*.
