#!/bin/bash
clear
echo "G O L D E N    O N E     MENU      V1.10"
echo "----------------------------------------"
PS3=" $(echo $'\n'-----------------------------$'\n' "   Enter Option: " ) "
echo ""
options=( "Install SNAP-Certbot" "certbot" "X-UI Migration" "DHCP Server" "InstallSoftEther v4" "SoftEther RESTART" "SoftEther EDIT-VPNSERVER" "SoftEther Info" "SoftEther Secure-NAT" "SoftEther Restore" "Custom ROUTING" "Hetzner cURL Test" "SpeedTest" "NetFelix Test" "v2ray-Niduka" "Install v2ray Auto SSL" "Install v2ray Server" "v2RAY X-UI SERVER-RUN" "Install v2ray Client-v2fly" "Config v2ray Client-v2fly" "SpeedTest for Client-v2fly" "Angristan-OpenVpn" "OVPN Status" "Angristan-WireGuard" "OpenConnect" "Kernel Tuner" "IPTABLES show" "Check Listen Ports" "DNSMASQ Restart" "DNSMASQ EDIT" "DNSMASQ LOG" "myFUCKip" "Socks10808 check" "CLEAR" "UPDATE" "Quit")
select opt in "${options[@]}"
do
case $opt in

"X-UI Migration")
if test -f "/Golden1/main-xui-move.sh";
then
bash /Golden1/main-xui-move.sh
else
mkdir -p /Golden1
cd /Golden1
curl -O https://raw.githubusercontent.com/ExtremeDot/x-ui-migration/master/main-xui-move.sh
chmod +x /Golden1/main-xui-move.sh 
bash /Golden1/main-xui-move.sh
fi
;;

# INSTALLING SNAP
"Install SNAP-Certbot")
if [ $(dpkg-query -W -f='${Status}' snapd 2>/dev/null | grep -c "ok installed") -eq 0 ];
then
echo " Installing SNAP"
apt install -y snap snapd;
else echo " Snapd was installed before" ;
fi
snap install core
snap refresh core
sleep 1
snap install --classic certbot
sleep 1
sudo ln -s /snap/bin/certbot /usr/bin/certbot
echo " Now run certboot ro create certificates"
;;

# certbot
"certbot")
sudo certbot certonly --standalone
echo ""
echo "Certfile : /etc/letsencrypt/live/domain/cert.pem"
echo "Certfile : /etc/letsencrypt/live/domain/privkey.pem"
;;
# DHCP SERVER
"DHCP Server")
if test -f "/Golden1/dhcp-server.sh";
then
bash /Golden1/dhcp-server.sh
else
mkdir -p /Golden1
cd /Golden1
curl -O https://raw.githubusercontent.com/ExtremeDot/ubuntu-dhcp-server/master/dhcp-server.sh
chmod +x /Golden1/dhcp-server.sh
bash /Golden1/dhcp-server.sh
fi
;;

# ROUTING
"Custom ROUTING")
if test -f "/Golden1/ROUTE.sh";
then
/Golden1/ROUTE.sh
else
mkdir -p /Golden1
cd /Golden1
curl -O https://raw.githubusercontent.com/ExtremeDot/golden_one/master/ROUTE.sh
chmod +x /Golden1/ROUTE.sh
fi
;;

# V2RAY CLIENT INSTALL
"Install v2ray Client-v2fly")
apt install -y shadowsocks-libev
apt install -y iptables-persistent
apt install -y curl
apt install -y unzip
cd /tmp
bash <(curl -L https://raw.githubusercontent.com/v2fly/fhs-install-v2ray/master/install-release.sh)
sleep 2
systemctl enable v2ray
;;

"Config v2ray Client-v2fly")
nano /usr/local/etc/v2ray/config.json
;;

"SpeedTest for Client-v2fly")
curl --socks5 socks5://localhost:10808 -L https://speed.hetzner.de/100MB.bin > /tmp/test.file
;;

# EDIT VPNSERVER SOFTETHER
"SoftEther EDIT-VPNSERVER")
nano /etc/init.d/vpnserver
;;


# DNSMASQ RESTART
"DNSMASQ Restart")
/etc/init.d/dnsmasq restart
;;

# KERNEL Tuner
"Kernel Tuner")
if test -f "/KernelTuner/install_kernel.sh";
then
/KernelTuner/./install_kernel.sh
else
mkdir -p /KernelTuner
cd /KernelTuner
curl -O https://raw.githubusercontent.com/jinwyp/one_click_script/master/install_kernel.sh
chmod +x /KernelTuner/install_kernel.sh
fi
;;

# SOFTETHER V4
"InstallSoftEther v4")
echo "Installing SoftEther 4 Server [Gold1Script]"
mkdir -p /setemp
cd /setemp
curl -O https://raw.githubusercontent.com/ExtremeDot/golden_one/master/build_se_stable.sh
chmod +x /setemp/build_se_stable.sh
/setemp/./build_se_stable.sh
;;

# SPEEDTEST
"SpeedTest")
speedpkg=speedtest-cli
status="$(dpkg-query -W --showformat='${db:Status-Status}' "$speedpkg" 2>&1)"
if [ ! $? = 0 ] || [ ! "$status" = installed ]; then
echo " - - - Installing package :$speedpkg"
apt-get install -y speedtest-cli
sleep 2
echo " - - - Testing Speed By SPEEDTEST Servers"
speedtest
else
echo " - - - Testing Speed By SPEEDTEST Servers"
echo " "
speedtest
fi		
;;

# FAST.com
"Fast.com NetFelix Test")
fastpkg=fast
status="$(dpkg-query -W --showformat='${db:Status-Status}' "$fastpkg" 2>&1)"
if [ ! $? = 0 ] || [ ! "$status" = installed ]; then
echo " - - - Installing package :$fastpkg"
snap install fast
sleep 2
echo " - - - Testing Speed By NetFelix Servers"
fast
else
echo " - - - Testing Speed By NetFelix Servers"
echo " "
fast
fi		
;;

# Using cURL to speedtest of hetzner file
"Hetzner cURL Test")
echo " Press [Ctrl+C] to Cancel"
curl --interface eth0 -L https://speed.hetzner.de/100MB.bin > /tmp/test.file
rm /tmp/test.file
;;

# IPTABLES SHOW
"IPTABLES show")
iptables-save -t nat
;;


# v2ray INSTALL
"v2ray-Niduka")
if test -f "/v2rayServerNiduka/install.sh";
then
x-ui
else
mkdir -p /v2rayServerNiduka
cd /v2rayServerNiduka
wget https://raw.githubusercontent.com/NidukaAkalanka/x-ui-english/master/install.sh
chmod +x /v2rayServerNiduka/install.sh
bash /v2rayServerNiduka/install.sh
fi
;;

# v2ray INSTALL AUTO SSL
"Install v2ray Auto SSL")
mkdir /v2rayServerSSL
cd /v2rayServerSSL
curl -O https://raw.githubusercontent.com/ExtremeDot/vpn_setups/master/v2ray_ssl.sh
chmod +x v2ray_ssl.sh
bash /v2rayServerSSL/v2ray_ssl.sh
;;


# v2ray INSTALL
"Install v2ray Server")
mkdir /v2rayServer
cd /v2rayServer
wget --no-check-certificate -O install https://raw.githubusercontent.com/proxykingdev/x-ui/master/install
chmod +x install
/v2rayServer/./install
;;

# v2ray RUN
"v2RAY RUN")
x-ui
;;

# OPENCONNECT SERVER INSTALLATION
"OpenConnect")
if test -f "/AnyConnect/ocserv-en.sh";
then
bash /AnyConnect/ocserv-en.sh
else
echo " Installing the Server"
mkdir -p /AnyConnect
cd /AnyConnect
wget -N --no-check-certificate https://raw.githubusercontent.com/sfc9982/AnyConnect-Server/main/ocserv-en.sh
chmod +x /AnyConnectocserv-en.sh
fi
;;

# ANGRISTAN OPENVPN INSTALL
"Angristan-OpenVpn")
if test -f "/Angristan/OpenVPN/openvpn-install.sh";
then
bash /Angristan/OpenVPN/openvpn-install.sh
else
echo " Installing ANGRISTAN OPENVPN "
mkdir -p /etc/openvpn/easy-rsa/pki/issued/
mkdir -p /Angristan/OpenVPN
cd /Angristan/OpenVPN
wget https://raw.githubusercontent.com/angristan/openvpn-install/master/openvpn-install.sh
chmod +x /Angristan/OpenVPN/openvpn-install.sh
fi
;;

# ANGRISTAN WIREGUARD INSTALL
"Angristan-WireGuard")
if test -f "/Angristan/WireGuard/wireguard-install.sh";
then
bash /Angristan/WireGuard/wireguard-install.sh
else
mkdir -p /Angristan/WireGuard
cd /Angristan/WireGuard
curl -O https://raw.githubusercontent.com/angristan/wireguard-install/master/wireguard-install.sh
chmod +x /Angristan/WireGuard/wireguard-install.sh
fi
;;

# SoftEther Restart
"SoftEther RESTART")
/etc/init.d/vpnserver restart
;;

# EDIT DNSMASQ
"DNSMASQ EDIT")
nano /etc/dnsmasq.conf
;;

# CHECK DNSMASQ LOG
"DNSMASQ LOG")
systemctl status dnsmasq.service
;;

# OPENVPN STATUS
"OVPN Status")
systemctl status openvpn@server
;;

# my Fucking IP
"myFUCKip")
curl -4 https://myip.wtf/json
;;

# Softether SHOW GOLDEN 1
"SoftEther Info")
/bin/seshow
;;

# SOFTETHER RESTORE BACKUP
"SoftEther Restore")
echo "Stopping SoftEther Servcie"

/etc/init.d/vpnserver stop
if test -f "/etc/init.d/vpnserver_BACKUP1"
then
rm /etc/init.d/vpnserver_LASTRUN
cp /etc/init.d/vpnserver /etc/init.d/vpnserver_LASTRUN
rm /etc/init.d/vpnserver
mv /etc/init.d/vpnserver_BACKUP1 /etc/init.d/vpnserver
echo " the first-run vpnserver file was backed up before."
echo " SKIPing the backup creating"
else
echo " NO ANY BACKUP FOUND"
echo " SKIP"
fi
;;

# Softether SHOW GOLDEN 1
"SoftEther Secure-NAT")

# creating BACKUP
if test -f "/etc/init.d/vpnserver_BACKUP1";
then
echo " the first-run vpnserver file was backed up before."
echo " SKIPing the backup creating"
else
cp /etc/init.d/vpnserver /etc/init.d/vpnserver_BACKUP1
fi

cat <<EOF > /etc/init.d/vpnserver
#!/bin/sh
# chkconfig: 2345 99 01
# description: SoftEther VPN Server
DAEMON=/usr/local/vpnserver/vpnserver
LOCK=/var/lock/subsys/vpnserver
test -x \$DAEMON || exit 0
case "\$1" in
start)
\$DAEMON start
touch \$LOCK
;;
stop)
\$DAEMON stop
rm \$LOCK
;;
restart)
\$DAEMON stop
sleep 3
\$DAEMON start
;;
*)
echo "Usage: \$0 {start|stop|restart}"
exit 1
esac
exit 0

EOF

echo "vpnserver is configured as [SECURE-NAT]"
;;

# socks10808 port check
"Socks10808 check")
curl --socks5 socks5://localhost:10808 https://myip.wtf/json
;;

# Check Ports
"Check Listen Ports")
lsof -i -P -n | grep LIST
;;

# Quit
"Quit")
	break
;;

# CLEAR SCREEN
"CLEAR")
	clear
;;

# CLEAR SCREEN
"UPDATE")
cd /tmp
curl -O https://raw.githubusercontent.com/ExtremeDot/golden_one/master/MAIN.sh
chmod +x /tmp/MAIN.sh
mv /tmp/MAIN.sh /bin/GoldenONE
chmod +x /bin/GoldenONE
exit 0
;;

# WRONG INPUT
*) echo "invalid option $REPLY"
;;
esac

# DONE
done
