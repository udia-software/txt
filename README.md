# u0txt

Command line pastebin at [txt.udia.ca](https://txt.udia.ca).

```bash
mix deps.get
mix run --no-halt
```

## Deployment

This section is here for personal documentation and is not generic.

```bash
MIX_ENV=prod release
scp -r _build/prod rac:~/txt
ssh rac

sudo adduser \
  --system \
  --shell /bin/bash \
  --gecos 'u0txt command line pastebin' \
  --group --disabled-password \
  --home /home/u0txt \
  u0txt
sudo rsync txt /home/u0txt
sudo chown -R u0txt:u0txt /home/u0txt/txt
```

```text
# /etc/supervisor/supervisord.conf
[program:u0txt]
user=u0txt
directory=/home/u0txt
command=/home/u0txt/txt/rel/u0txt/bin/u0txt start
autostart=true
```

```text
# /etc/nginx/sites-available
server {
    server_name txt.udia.ca;
    location / {
        proxy_pass http://localhost:4004;
    }
    listen 80;
    listen [::]:80;
}

# symlink to enabled, then run certbot --nginx 
```
