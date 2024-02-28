#!/bin/bash

download_udpServer(){
	msg -nama "        ${a30:-Descargando binario UDPserver} ....."
	if wget -O /usr/bin/udpServer 'https://bitbucket.org/iopmx/udprequestserver/downloads/udpServer' &>/dev/null ; then
		chmod +x /usr/bin/udpServer
		msg -verd 'OK'
	else
		msg -verm2 'fail'
		rm -rf /usr/bin/udpServer*
	fi
}

make_service(){
	ip_nat=$(ip -4 addr | grep inet | grep -vE '127(\.[0-9]{1,3}){3}' | cut -d '/' -f 1 | grep -oE '[0-9]{1,3}(\.[0-9]{1,3}){3}' | sed -n 1p)
	interfas=$(ip -4 addr | grep inet | grep -vE '127(\.[0-9]{1,3}){3}'|grep "$ip_nat"|awk {'print $NF'})
	ip_publica=$(grep -m 1 -oE '^[0-9]{1,3}(\.[0-9]{1,3}){3}$' <<< "$(wget -T 10 -t 1 -4qO- "http://ip1.dynupdate.no-ip.com/" || curl -m 10 -4Ls "http://ip1.dynupdate.no-ip.com/")")

	#ip_nat=$(fun_ip nat)
	#interfas=$(ip -4 addr | grep inet | grep -vE '127(\.[0-9]{1,3}){3}'|grep "$ip_nat"|awk {'print $NF'})
	#ip_publica=$(fun_ip)

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
}