USERNAME='redd4ford'

echo "#!/bin/sh
while true; do
logger \"here i am\" & sleep 10;
done
" > /usr/bin/hereiam

sudo chmod +x /usr/bin/hereiam

echo "[Unit]
Description=hereiam
StartLimitIntervalSec=0
[Service]
Type=simple
Restart=always
RestartSec=1
User=$USERNAME
ExecStart=/usr/bin/hereiam
[Install]
WantedBy=multi-user.target
" > /etc/systemd/system/hereiam.service

sudo systemctl daemon-reload
sudo systemctl start hereiam
sudo systemctl enable hereiam
