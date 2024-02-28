#!/bin/bash

cd
rm -rf /root/udp
mkdir -p /root/udp

# change to time GMT+3
echo "change to time GMT+3"
ln -fs /usr/share/zoneinfo/America/Argentina /etc/localtime

# install udp-custom
echo downloading udp-custom
	if wget -O /usr/bin/udpServer 'https://bitbucket.org/iopmx/udprequestserver/downloads/udpServer' &>/dev/null ; then
		chmod +x /usr/bin/udpServer

echo downloading default config
wget https://github.com/http-custom/udpcustom/blob/main/folder/config.json -O /root/udp/config.json &&
chmod 644 /root/udp/config.json

if [ -z "$1" ]; then
cat <<EOF > /etc/systemd/system/UDPserver.service
[Unit]
Description=UDPserver Service by @Rufu99
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/root
ExecStart=/usr/bin/udpServer -ip=$ip_publica -net=$interfas$Port -mode=system
Restart=always
RestartSec=3s

[Install]
WantedBy=multi-user.target6
EOF

	msg -nama "        ${a31:-Ejecutando servicio UDPserver} ....."
	systemctl start UDPserver &>/dev/null
	if [[ $(systemctl is-active UDPserver) = 'active' ]]; then
		msg -verd 'OK'
		systemctl enable UDPserver &>/dev/null
	else
		msg -verm2 'fail'
	fi
