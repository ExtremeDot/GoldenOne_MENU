#!/bin/bash
clear
echo "G O L D E N    O N E     MENU      V1.0"
echo "----------------------------------------"
PS3=" $(echo $'\n'-----------------------------$'\n' "   Enter Option: " ) "
echo ""
options=("InstallSoftEther v4" "Install v2ray Server" "v2RAY RUN" "Hetzner cURL Test" "SpeedTest" "NetFelix Test" "Angristan-OpenVpn" "Angristan-WireGuard" "OpenConnect" "Kernel Tuner" "OVPN Status" "myFUCKip" "socks10808 check" "check Listen Ports" "DNSMASQ EDIT" "SoftEther Info" "CLEAR" "Quit")
select opt in "${options[@]}"
do
case $opt in

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
"iptables show")
iptables-save -t nat
;;

# v2ray INSTALL
"Install v2ray Server")
mkdir /v2rayServer
cd /v2rayServer
wget --no-check-certificate -O install https://raw.githubusercontent.com/proxykingdev/x-ui/master/install
chmod +x instal
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

# EDIT DNSMASQ
"DNSMASQ EDIT")
nano /etc/dnsmasq.conf
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

# socks10808 port check
"socks10808 check")
curl --socks5 socks5://localhost:10808 https://myip.wtf/json
;;

# Check Ports
"check Listen Ports")
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

# WRONG INPUT
*) echo "invalid option $REPLY"
;;
esac

# DONE
done
