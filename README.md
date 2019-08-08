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
sudo mv txt /home/u0txt
sudo chown -R u0txt:u0txt /home/u0txt/txt
```

```text
# =========================
# u0txt systemd service configuration
#
# /home/u0txt/u0txt.service
# sudo ln -s /home/u0txt/u0txt.service /lib/systemd/system/u0txt.service
# =========================

[Unit]
Description=A high performance command line pastebin
After=nginx.service

[Service]
Type=simple
User=u0txt
Group=u0txt
Restart=on-failure
Environment=MIX_ENV=prod
Environment=LANG=en_US.UTF-8

WorkingDirectory=/home/u0txt
ExecStart=/home/u0txt/txt/rel/u0txt/bin/u0txt start
ExecStop=/home/u0txt/txt/rel/u0txt/bin/u0txt stop

[Install]
WantedBy=multi-user.target
```

```bash
sudo systemctl enable u0txt
sudo systemctl start u0txt
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
