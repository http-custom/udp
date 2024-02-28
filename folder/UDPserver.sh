#!/bin/bash

cd
rm -rf /root/udp
mkdir -p /root/udp

# change to time GMT+3
echo "change to time GMT+3"
ln -fs /usr/share/zoneinfo/America/Argentina /etc/localtime

# install udp-custom
echo downloading udp-custom
wget https://bitbucket.org/iopmx/udprequestserver/downloads/udpServer -O /root/udp/udp-custom &&
chmod +x /usr/bin/udpServer

echo downloading default config
wget https://github.com/http-custom/udpcustom/blob/main/folder/config.json -O /root/udp/config.json &&
chmod 644 /root/udp/config.json

if [ -z "$1" ]; then
cat <<EOF > /etc/systemd/system/UDPserver.service
[Unit]
Description=UDP Custom by ePro Dev. Team

[Service]
User=root
Type=simple
ExecStart=/root/bin/udpServer server
WorkingDirectory=/root
Restart=always
RestartSec=3s

[Install]
WantedBy=default.target
EOF
else
cat <<EOF > /etc/systemd/system/UDPserver.service
[Unit]
Description=UDP Custom by ePro Dev. Team

[Service]
User=root
Type=simple
ExecStart=/usr/bin/udpServer server -exclude $1
WorkingDirectory=/root
Restart=always
RestartSec=3s

[Install]
WantedBy=default.target
EOF
fi

echo start service udp-custom
systemctl start UDPserver &>/dev/null

echo enable service udp-custom
systemctl enable UDPserver &>/dev/null

echo history -c