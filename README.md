# u0txt

Command line pastebin at [txt.udia.ca](https://txt.udia.ca).

```bash
mix deps.get
mix run --no-halt
```

## Deployment

This section is here for personal documentation and is not generic.
```bash
# build docker image
docker build -t elixir-ubuntu:latest .
# build application binary release
docker run -v $(pwd):/opt/build --rm -it elixir-ubuntu:latest /opt/build/bin/build.sh
# copy artifact over to prod server
scp rel/artifacts/u0txt-1.0.0.tar.gz rac:
ssh rac
mv u0txt-1.0.0.tar.gz /mnt/rose
cd /mnt/rose
mkdir -p u0txt
tar -xzvf u0txt-1.0.0.tar.gz -C u0txt
sudo adduser \
  --system \
  --shell /bin/bash \
  --gecos 'u0txt command line pastebin' \
  --group --disabled-password \
  --home /home/u0txt \
  u0txt
sudo usermod -aG u0txt alexander
sudo chmod :u0txt -R /mnt/rose
sudo chown 770 -R /mnt/rose
```

```text
# /mnt/rose/u0txt.service 
[Unit]
Description=u0txt
After=network.target

[Service]
Type=forking
User=u0txt
Group=u0txt
WorkingDirectory=/mnt/rose/u0txt
ExecStart=/mnt/rose/u0txt/bin/u0txt start
ExecStop=/mnt/rose/u0txt/bin/u0txt stop
PIDFile=/mnt/rose/u0txt/u0txt.pid
Restart=on-failure
RestartSec=5
Environment=PORT=4004
Environment=LANG=en_US.UTF-8
Environment=PIDFILE=/mnt/rose/u0txt/u0txt.pid
SyslogIdentifier=u0txt
RemainAfterExit=no

[Install]
WantedBy=multi-user.target
# symlink to /etc/systemd/system, then run sudo systemctl enable u0txt, systemctl start u0txt
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
