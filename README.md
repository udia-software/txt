# u0txt

Command line pastebin at [txt.udia.ca](https://txt.udia.ca).

```bash
mix deps.get
mix run --no-halt
```

## Deployment

This section is here for personal documentation and is not generic. Build from source on deployed machine due to `beam.smp: error while loading shared libraries: libtinfo.so.6: cannot open shared object file: No such file or directory`
```bash
sudo adduser \
  --system \
  --shell /bin/bash \
  --gecos 'u0txt command line pastebin' \
  --group --disabled-password \
  --home /home/u0txt \
  u0txt
# as u0txt
MIX_ENV=prod mix release
```

```text
# /etc/supervisor/supervisord.conf
[program:u0txt]
user=u0txt
directory=/home/u0txt
command=/home/u0txt/txt/_build/prod/rel/u0txt/bin/u0txt start
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
