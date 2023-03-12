#!/bin/bash
#EXTREME DOT GL1MENU
scriptVersion=1.32

echo "nameserver 8.8.8.8" > /etc/resolv.conf

# root checker
function isRoot() {
        if [ "$EUID" -ne 0 ]; then
                return 1
        fi
}

# IS root access?
if ! isRoot; then
        echo "Sorry, you need to run this as root"
        exit 1
fi

apt --fix-broken install

# Load Colors
function colorScript() {

mkdir -p /Golden1/
touch /Golden1/defaults.sh
cat <<EOF > /Golden1/defaults.sh
RED='\033[0;31m'        # Red
BLUE='\033[1;34m'       # LIGHTBLUE
GREEN='\033[0;32m'      # Green
NC='\033[0m'            # No Color
HOST_PING=8.8.8.8
PINGTXT1=\`echo "-- PING Check: -----------------------------------------------" | cut -c 1-45\`
INTFTXT1=\`echo "-- INTERFACE Check: -----------------------------------------------" | cut -c 1-45\`
EOF

# COLOR SCRIPTING
YELLOW='\033[0;33m'	# YELLOW
RED='\033[0;31m'        # Red
BLUE='\033[1;34m'       # LIGHTBLUE
GREEN='\033[0;32m'      # Green
NC='\033[0m'            # No Color
red(){
    echo -e "\033[31m\033[01m$1\033[0m"
}
green(){
    echo -e "\033[32m\033[01m$1\033[0m"
}
yellow(){
    echo -e "\033[33m\033[01m$1\033[0m"
}
blue(){
    echo -e "\033[34m\033[01m$1\033[0m"
}
bold(){
    echo -e "\033[1m\033[01m$1\033[0m"
}
Green_font_prefix="\033[32m" 
Red_font_prefix="\033[31m" 
Green_background_prefix="\033[42;37m" 
Red_background_prefix="\033[41;37m" 
Font_color_suffix="\033[0m"
}

# Installing Tools
function installTools() {

echo "nameserver 8.8.8.8" > /etc/resolv.conf
# get apt updates
apt-get updates

echo "nameserver 8.8.8.8" > /etc/resolv.conf
# installing lsof
if [ $(dpkg-query -W -f='${Status}' lsof 2>/dev/null | grep -c "ok installed") -eq 0 ];
then
yellow "Installing lsof"
apt install -y lsof
else
green "lsof has installed"
fi

echo "nameserver 8.8.8.8" > /etc/resolv.conf
# installing shadowsocks-libev
if [ $(dpkg-query -W -f='${Status}' shadowsocks-libev 2>/dev/null | grep -c "ok installed") -eq 0 ];
then
yellow "Installing shadowsocks-libev"
apt install -y shadowsocks-libev
else
green "shadowsocks-libev has installed"
fi

echo "nameserver 8.8.8.8" > /etc/resolv.conf
# installing iptables-persistent
if [ $(dpkg-query -W -f='${Status}' iptables-persistent 2>/dev/null | grep -c "ok installed") -eq 0 ];
then
yellow "Installing iptables-persistent"
apt install -y iptables-persistent
else
green "iptables-persistent has installed"
fi

echo "nameserver 8.8.8.8" > /etc/resolv.conf
if [ $(dpkg-query -W -f='${Status}' crontab 2>/dev/null | grep -c "ok installed") -eq 0 ];
then
yellow "Installing cron services"
apt-get install cron
else
green "cron service has allready installed"
fi

echo "nameserver 8.8.8.8" > /etc/resolv.conf
# installing unzip
if [ $(dpkg-query -W -f='${Status}' unzip 2>/dev/null | grep -c "ok installed") -eq 0 ];
then
yellow "Installing unzip"
apt install -y unzip
else
green "unzip has installed"
fi
echo "nameserver 8.8.8.8" > /etc/resolv.conf
# installing socat
if [ $(dpkg-query -W -f='${Status}' socat 2>/dev/null | grep -c "ok installed") -eq 0 ];
then
yellow "Installing socat"
apt install -y socat
else
green "socat has installed"
fi
echo "nameserver 8.8.8.8" > /etc/resolv.conf
# installing curl
if [ $(dpkg-query -W -f='${Status}' curl 2>/dev/null | grep -c "ok installed") -eq 0 ];
then
yellow "Installing curl"
apt install -y curl
else
green "curl has installed"
fi
echo "nameserver 8.8.8.8" > /etc/resolv.conf
# installing sshpass
if [ $(dpkg-query -W -f='${Status}' sshpass 2>/dev/null | grep -c "ok installed") -eq 0 ];
then
yellow "Installing sshpass"
apt install -y sshpass
else
green "sshpass has installed"
fi
echo "nameserver 8.8.8.8" > /etc/resolv.conf
# installing dnsutils
if [ $(dpkg-query -W -f='${Status}' dnsutils  2>/dev/null | grep -c "ok installed") -eq 0 ];
then
yellow "Installing dnsutils"
apt install -y dnsutils 
else
green "dnsutils has installed"
fi
echo "nameserver 8.8.8.8" > /etc/resolv.conf
# installing mc
if [ $(dpkg-query -W -f='${Status}' mc  2>/dev/null | grep -c "ok installed") -eq 0 ];
then
yellow "Installing mc file explorer"
apt install -y mc 
else
green "mc has installed"
fi

echo "nameserver 8.8.8.8" > /etc/resolv.conf
if [ $(dpkg-query -W -f='${Status}' net-tools  2>/dev/null | grep -c "ok installed") -eq 0 ];
then
yellow "Installing net tools package"
apt install -y net-tools 
else
green "net tools has installed allready"
fi

echo "nameserver 8.8.8.8" > /etc/resolv.conf
if [ $(dpkg-query -W -f='${Status}' ifupdown  2>/dev/null | grep -c "ok installed") -eq 0 ];
then
yellow "Installing ifupdown package"
apt-get install -y ifupdown
else
green "ifupdown has installed allready"
fi
}

# OLD SERVER GET DATA HELPER
function oLDInfo() {
green "Please Enter OLD SERVER information here"
echo
read -e -i "$OLD_IPv4" -p "OLD SERVER: Please input PUBLIC IP v4: " input
OLD_IPv4="${input:-$OLD_IPv4}"
read -e -i "$OLD_LOGINNAME" -p "OLD SERVER: Please input Login Username: " input
OLD_LOGINNAME="${input:-$OLD_LOGINNAME}"
read -e -i "$OLD_PASSWORD" -p "OLD SERVER: Please input Login Password: " input
OLD_PASSWORD="${input:-$OLD_PASSWORD}"
getOldServerData
}

# OLD SERVER GET DATA
function getOldServerData() {
if [[ -z $OLD_IPv4 || -z $OLD_LOGINNAME || -z $OLD_PASSWORD ]]; then #INFORMATION IS NOT CORRECT
red "OLD SERVER: ERROR getting DATA"; echo
oLDInfo
else
echo
yellow "OLD SERVER INFORMATION ---------"
green "IP=[$OLD_IPv4]"
green "USER=[$OLD_LOGINNAME]"
green "PASS=[$OLD_PASSWORD] "
OLD_SETUP=""
until [[ $OLD_SETUP =~ (y|n) ]]; do
read -rp "OLD SERVER: Confirm OLD Server Information? [y/n]: " -e -i y OLD_SETUP
done
if [[ $OLD_SETUP == "n" ]]; then
yellow "Setting New Values for OLD SERVER"
oLDInfo
fi; fi
}

# NEW SERVER GET DATA HELPER
function nEWInfo() {

NEW_PASSWORD="$OLD_PASSWORD"
echo "Please Enter NEW SERVER information here"
echo
read -e -i "$NEW_IPv4" -p "NEW SERVER: Please input PUBLIC IP v4: " input
NEW_IPv4="${input:-$NEW_IPv4}"
read -e -i "$NEW_LOGINNAME" -p "NEW SERVER: Please input Login Username: " input
NEW_LOGINNAME="${input:-$NEW_LOGINNAME}"
read -e -i "$NEW_PASSWORD" -p "NEW SERVER: Please input Login Password: " input
NEW_PASSWORD="${input:-$NEW_PASSWORD}"
getNewServerData
}

# NEW SERVER GET DATA
function getNewServerData() {
if [[ -z $NEW_IPv4 || -z $NEW_LOGINNAME || -z $NEW_PASSWORD ]]; then #INFORMATION IS NOT CORRECT
red "NEW SERVER: ERROR getting DATA"; echo
nEWInfo
else
echo
yellow "NEW SERVER INFORMATION ---------"
green "IP=[$NEW_IPv4]"
green "USER=[$NEW_LOGINNAME]"
green "PASS=[$NEW_PASSWORD] "
NEW_SETUP=""
until [[ $NEW_SETUP =~ (y|n) ]]; do
read -rp "NEW SERVER: Confirm NEW Server Information? [y/n]: " -e -i y NEW_SETUP
done
if [[ $NEW_SETUP == "n" ]]; then
green "Setting New Values for NEW SERVER"
nEWInfo
fi; fi
}

# DOMAIN CHECK HELPER
function getDomainInfoHelper() {
echo; red "NEW SERVER: ERROR getting DOMAIN name"; echo
read -e -i "$DOMAIN_ADDRESS" -p "NEW SERVER: Please enter damain address: " input
DOMAIN_ADDRESS="${input:-$DOMAIN_ADDRESS}"
getDomainInfo
}

# DOMAIN CHECK
function getDomainInfo() {
green "New Server Domain Check"; echo
if [[ -z $DOMAIN_ADDRESS ]]; then #DOMAIN ADDRESS IS NOT ENTERED
getDomainInfoHelper
else
if [[ $DOMAINANMES == "n" ]]; then
yellow "Specify Domain Name"
getDomainInfoHelper

fi; fi
}

# EMAIL CHECK HELPER
function getEmailInfoHelper() {
echo; red "NEW SERVER: ERROR getting E-MAIL Address"; echo
read -e -i "$EMAIL_ADDRESS" -p "NEW SERVER: Please enter E-MAIL address: " input
EMAIL_ADDRESS="${input:-$EMAIL_ADDRESS}"
getEmailInfo
}

# EMAIL CHECK
function getEmailInfo() {
green "New Server Email Address Check"; echo
if [[ -z $EMAIL_ADDRESS ]]; then #E-MAIL ADDRESS IS NOT ENTERED
getEmailInfoHelper
else

if [[ $EMAILANMES == "n" ]]; then
yellow "Specify E-MAIL ADDRESS"
getEmailInfoHelper
fi; fi

}

# CHECK DOMAIN NAME WITH IP
function checkDomainNamewithIP() {
echo
green "$DOMAIN_ADDRESS IP must be $NEW_IPv4, now check the ip of domain!"
echo
green "Checking IP for $DOMAIN_ADDRESS"
IPCHECKNEWDOMAIN=`dig +short $DOMAIN_ADDRESS` && sleep 1
DOMCHECKS=""
until [[ $DOMCHECKS =~ (y|n) ]]; do
read -rp "[$IPCHECKNEWDOMAIN] is set to [$DOMAIN_ADDRESS], is Correct? [y/n]: " -e -i y DOMCHECKS
done
if [[ $DOMCHECKS == "n" ]]; then
red "Setup proccess is paused now"
yellow "goto Cloudflare dashboard and set [$NEW_IPv4] IP for [$DOMAIN_ADDRESS]"
yellow "don't forget to Set to \"DNS ONLY\" "
echo
green "when you change the domain to new ip , press Enter to continue"
DOMCHECKS2=""
until [[ $DOMCHECKS2 =~ (y|n) ]]; do
read -rp "Have you updated Domain Settings to New Server's IP? [y/n]: " -e -i y DOMCHECKS2
done
if [[ $DOMCHECKS2 == "n" ]]; then
checkDomainNamewithIP
fi; fi
}

# CHECK CURRENT VPS IS NEW OR OLD SERVER, depends on OLD SERVER GET DATA and NEW SERVER GET DATA functions are running before.
function vpsDetectionByIP() {
# VPSMACHINE can be set as NEW,OLD or UNKNOWN
CURRENTPUBIP=`curl --silent -4 icanhazip.com`
#$NEW_IPv4 #$OLD_IPv4
if [[ $CURRENTPUBIP == $NEW_IPv4 ]]; then
echo "Its NEW Server VPS"
VPSMACHINE=NEW
else if [[ $CURRENTPUBIP == $OLD_IPv4 ]]; then
echo "Its OLD Server VPS"
VPSMACHINE=OLD
else
echo "ERROR, Can't reconize "
VPSMACHINE=UNKNOWN
fi; fi 
}

# ipv6 Enabler
function ipv6Enabler() {
echo
green "IPv6 Disable or Enabler"
yellow "Enter 0 to Disable IPv6"
yellow "Enter 1 to Enable IPv6"
until [[ $IPV6ABLE =~ (0|1) ]]; do
read -rp "Enter 0 to Disable or 1 to Enable ! [0 or 1]: " -e IPV6ABLE
done
if [[ $IPV6ABLE == "1" ]]; then
	green "Enabling IPV6 Support"
	if [[ $(sysctl -a | grep 'disable_ipv6.*=.*1') || $(cat /etc/sysctl.{conf,d/*} | grep 'disable_ipv6.*=.*1') ]]; then
        sed -i '/disable_ipv6/d' /etc/sysctl.{conf,d/*}
        echo 'net.ipv6.conf.all.disable_ipv6 = 0' >/etc/sysctl.d/ipv6.conf
        sysctl -w net.ipv6.conf.all.disable_ipv6=0
	fi
	sleep 1
elif [[ $IPV6ABLE == "0" ]]; then
green "Disabling IPV6 Support"
	if [[ $(sysctl -a | grep 'disable_ipv6.*=.*0') || $(cat /etc/sysctl.{conf,d/*} | grep 'disable_ipv6.*=.*0') ]]; then
        sed -i '/disable_ipv6/d' /etc/sysctl.{conf,d/*}
        echo 'net.ipv6.conf.all.disable_ipv6 = 1' >/etc/sysctl.d/ipv6.conf
        sysctl -w net.ipv6.conf.all.disable_ipv6=1
	fi
fi
}

# Install XanMoD Kernl
function installXanModKernel() {
clear && echo
green "Installing XanMod Kernel"
echo -e "${GREEN}"
echo "What XanMod Kernel Version want to install? "
echo "   1) Stable XanMod Kernel Release"
echo "   2) Latest Kernel XanMod EDGE (recommended for the latest kernel)"
echo "   3) XanMod LTS (Kernel 5.15 LTS) "
echo -e "${GREEN}"
echo
until [[ $KERNINSTAL =~ ^[0-3]+$ ]] && [ "$KERNINSTAL" -ge 1 ] && [ "$KERNINSTAL" -le 3 ]; do
read -rp "KERNINSTAL [1-3]: " -e -i 2 KERNINSTAL
done
echo
green "Downloading the XanMod repository files..."
curl -fSsL https://dl.xanmod.org/gpg.key | gpg --dearmor | tee /usr/share/keyrings/xanmod.gpg > /dev/null && sleep 1
echo 'deb [signed-by=/usr/share/keyrings/xanmod.gpg] http://deb.xanmod.org releases main' | tee /etc/apt/sources.list.d/xanmod-kernel.list && sleep 1
grep xanmod /etc/apt/sources.list.d/xanmod-kernel.list && sleep 1
echo
green "Updating System... starting."
apt-get -y update
apt -y upgrade
echo
green "Updating System... finished."
case $KERNINSTAL in
1) # Stable XanMod Kernel Release
echo && echo "Stable XanMod Kernel Install.."
apt install linux-xanmod
;;
2) # Latest Kernel XanMod EDGE
echo && echo "Latest Kernel XanMod EDGE Install.."
apt install linux-xanmod-edge
;;
3) # XanMod LTS
echo && echo "XanMod LTS Install.."
apt install linux-xanmod-lts
echo -e "${GREEN}"
;;
esac
echo
green "Kernel has installed ..."
echo
apt install -y intel-microcode iucode-tool
}

# Installing ACME Certificate Generator
function acmeInstaller() {
green "ACME Certificate Installer"
if [[ -z $EMAIL_ADDRESS || -z $DOMAIN_ADDRESS ]]; then #INFORMATION IS NOT CORRECT
	red "No DOMAIN and E-MAIL address has defined."
	red "Please Define Email address and Domain name by choosing \"7) Input Domain and Email Address\" ,then run it again."
	echo
	green "back to main menu"
	enter2main
else
	echo
	green "Email Address:   [$EMAIL_ADDRESS]"
	green "Domain Name:     [$DOMAIN_ADDRESS]"
	echo
	until [[ $confirmAddresses =~ (y|n) ]]; do
	read -rp "Domain name and Email Address are correct? [y/n]: " -e -i y confirmAddresses
	done
	if [[ $confirmAddresses == "n" ]]; then
	green "back to main menu"
	enter2main
	fi

fi
echo && green "Installing ACME certificate tool"
ufw allow https
ufw allow http
ufw allow 443
ufw allow 80

curl https://get.acme.sh | sh
sleep 1
~/.acme.sh/acme.sh --set-default-ca --server letsencrypt
sleep 1
~/.acme.sh/acme.sh --register-account -m $EMAIL_ADDRESS
sleep 1
~/.acme.sh/acme.sh --issue -d $DOMAIN_ADDRESS --standalone
sleep 1
~/.acme.sh/acme.sh --installcert -d $DOMAIN_ADDRESS --key-file /root/private.key --fullchain-file /root/cert.crt
echo
green "Certfiles are installed and copied to :"
echo
blue "/root/cert.crt"
blue "/root/private.key"
echo

}

# Installing BBR Function
function bbrEnabler() {
green "Enabling BBR?"
red "If you have installed XANMOD kernel, please don't install and Skip this installation"
until [[ $BBREANBLE =~ (y|n) ]]; do
read -rp "Enable BBR?  [y/n]: " -e -i n BBREANBLE
done
if [[ $BBREANBLE == "y" ]]; then
echo "Enabling BBR "
yellow "Enable BBR acceleration"
echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
sleep 1
sysctl -p
else
sleep 1
echo "Skip Enable BBR Service"
fi
}

# Install Vaxilu X-UI V2ray Panel
function vaxiluv2rayInstaller() {
echo
until [[ $vaxiluInstallerAsk =~ (y|n) ]]; do
read -rp "Installing Vaxilu X-UI Panel? [y/n]: " -e -i y vaxiluInstallerAsk
done
if [[ $vaxiluInstallerAsk == "y" ]]; then
bash <(curl -Ls https://raw.githubusercontent.com/vaxilu/x-ui/master/install.sh)
fi

}

# Install Niduka X-UI V2ray Panel
function nidukav2rayInstaller() {
green "Niduka Akalanka X-UI Panel Installer"
red "its based on ENGLISH X-UI and is different from X-UI vaxilu panels."
echo
until [[ $nidukaInstallerAsk =~ (y|n) ]]; do
read -rp "Installing Niduka English X-UI Panel? [y/n]: " -e -i y nidukaInstallerAsk
done
if [[ $nidukaInstallerAsk == "y" ]]; then
bash <(curl -Ls https://raw.githubusercontent.com/NidukaAkalanka/x-ui-english/master/install.sh)
fi
}

# Install ProxyKing X-UI V2ray Panel
function proxyKingV2rayInstaller() {
green "ProxyKing X-UI Panel Installer"
yellow "its translated ENGLISH version of Vaxilu X-UI panel."
echo
	until [[ $proxyKingV2rayAsk =~ (y|n) ]]; do
		read -rp "Installing ProxyKing's English Translated Vaxilu based X-UI Panel? [y/n]: " -e -i y proxyKingV2rayAsk
	done
		if [[ $proxyKingV2rayAsk == "y" ]]; then
		mkdir -p /tmp/v2Server && cd /tmp/v2Server
		wget --no-check-certificate -O install https://raw.githubusercontent.com/proxykingdev/x-ui/master/install
		sleep 1 && chmod +x install
		/tmp/v2Server/./install
		fi
}

# Install HAMED AP X-UI V2ray Panel
function hamedAPv2rayInstaller() {
green "HamedAP X-UI Panel Installer"
red "its based on ENGLISH X-UI and is different from X-UI vaxilu panels."
echo
	until [[ $HAPV2rayAsk =~ (y|n) ]]; do
		read -rp "Installing ProxyKing's English Translated Vaxilu based X-UI Panel? [y/n]: " -e -i y HAPV2rayAsk
	done
		if [[ $HAPV2rayAsk == "y" ]]; then
		bash <(curl -Ls https://raw.githubusercontent.com/HamedAp/x-ui-Persian/master/install.sh)
		fi
}

# Install V2RAy-AGENT ENGLISH
function extremeDotV2RAInstaller() {
green "English v2ray agent script"
yellow "its translated ENGLISH version of mack-a v2ray-agent script."
echo
until [[ $extremeDotv2rayAgentAsk =~ (y|n) ]]; do
read -rp "Installing ExtremeDot V2ray-Agent ? [y/n]: " -e -i y extremeDotv2rayAgentAsk
done
if [[ $extremeDotv2rayAgentAsk == "y" ]]; then
mkdir -p /tmp/v2Server && cd /tmp/v2Server
wget -P /root -N --no-check-certificate "https://raw.githubusercontent.com/ExtremeDot/v2ray-agent/EnglishVersion/en-install.sh" && chmod 700 /root/en-install.sh
mv /root/en-install.sh /root/install.sh 
bash /root/install.sh
fi
echo
green "run \"vasma\" to start "
}

function enter2main() {
read -p "Press enter to back to menu"
mainMenuRun
}

function firewallEnabler() {
echo
if [ $(dpkg-query -W -f='${Status}' ufw 2>/dev/null | grep -c "ok installed") -eq 0 ];
then
	green "Installing Firewall"
	apt-get update
	apt install -y ufw
	green "Firewall is installed " ;
else
	green "Firewall has installed allready.." ;
fi
FWREADSTAT=`ufw status | grep Status | cut -c 9-14`
if [[ $FWREADSTAT == "inacti" ]]; then
green "Firewall is Disabled, Do you want to Enable it?"
	FIREWALLINS2=""
	until [[ $FIREWALLINS2 =~ (y|n) ]]; do
	read -rp "Enable Firewall? [y/n]: " -e -i y FIREWALLINS2
	done
	if [[ $FIREWALLINS2 == "y" ]]; then

		echo
		green "Please enter the Port number for ADMIN Panel"
		echo
		read -e -i "$PANELPORT" -p "please Enter X-UI Panel Port: " input
		PANELPORT="${input:-$PANELPORT}"
		echo
		yellow " Please enter the STARTING Port number for Users over v2ray Panel"
		echo
		read -e -i "$FIREWALLSTART" -p "Please Enter STARTING Port for users: " input
		FIREWALLSTART="${input:-$FIREWALLSTART}"
		echo 
		yellow " Please enter the ENDING Port number for Users over v2ray Panel"
		read -e -i "$FIREWALLSTOP" -p "Please Enter ENDING Port for users: " input
		FIREWALLSTOP="${input:-$FIREWALLSTOP}"
		echo
		green "Open ports for ssh, http and https access."
		ufw allow http
		ufw allow https
		ufw allow ssh
		echo
		green "Firewall Opened Port for X-UI admin panel on $PANELPORT port."
		echo
		ufw allow $PANELPORT
		sleep 1
		green "Firewall Opened Ports from $FIREWALLSTART to $FIREWALLSTOP for Users access."
		ufw allow $FIREWALLSTART:$FIREWALLSTOP/tcp
		sleep 1
		ufw allow $FIREWALLSTART:$FIREWALLSTOP/udp
		sleep
		green "Enabling Firewall"
		ufw enable
		echo
		green " you can disable or enable firewall using commands:"
		blue " ufw enable"
		red " ufw disable"
	fi
elif [[ $FWREADSTAT == "active" ]]; then
	green "Firewall is Enabled, Do you want to Disable it?"
	FIREWALLINS3=""
	read -rp "Disable Firewall? [y/n]: " -e -i y FIREWALLINS3
	if [[ $FIREWALLINS3 == "y" ]]; then
	ufw disable
	green "Firewall has Disabled"
	fi
fi

}

function xuiMigrator() {
	if [[ $VPSMACHINE == "OLD" ]]; then
		red "OLD SERVER has Detected!"; echo
		red "PLEASE RUN SCRIPT OVER NEW SERVER"
		red "E X I T "
		echo
	elif [[ $VPSMACHINE == "NEW" ]]; then
		yellow "New SERVER is Detected!"; echo
		echo
		green "Check if data are available?"
			
			#Check OLD SERER DATA
			if [[ -z $OLD_IPv4 || -z $OLD_LOGINNAME || -z $OLD_PASSWORD ]]; then #INFORMATION IS NOT CORRECT
				red "OLD SERVER DATA has not found, please set data for OLD Server "
				red "Back to main menu" 
				sleep 5 && mainMenuRun
			else
				green "OLD SERVER DATA has found."
			fi
			
			#Check NEW SERER DATA
			if [[ -z $NEW_IPv4 || -z $NEW_LOGINNAME || -z $NEW_PASSWORD ]]; then #INFORMATION IS NOT CORRECT
				red "NEW SERVER DATA has not found, please set data for OLD Server "
				red "Back to main menu" 
				sleep 5 && mainMenuRun
			else
				green "NEW SERVER DATA has found."
			fi
		
		# SELECT X-UI PANEL TYPE
		echo -e "${GREEN}"
		echo "Which vpn panel are you using?"
		echo "   1) Vaxilu Based V2ray Panels, vaxilu and proxykingdev panels"
		echo "   2) English X-UI Based Panels , HAMED-AP and NidukaAkalanka panels )"
		echo "   3) V2RAY Aegnt - MACK-A panel"
		echo "   4) SSH Panel by HAMED AP"
		echo "   5) SSR Panel V4"
		echo "   6) back to menu"		
		echo -e "${GREEN}"
		echo " "
		until [[ $migratePanels =~ ^[0-6]+$ ]] && [ "$migratePanels" -ge 1 ] && [ "$migratePanels" -le 6 ]; do
		read -rp "migratePanels [1-6]: " -e -i 1 migratePanels
		done
		case $migratePanels in
		
		1) # VAXILU BASED
		echo
		green "Vaxilu Based Panels - Start Migrations"
		echo " Moving BACKUPS"
		green "Downloading X-UI files from OLD Server"
		sshpass -p "$OLD_PASSWORD" scp -o StrictHostKeyChecking=no $OLD_LOGINNAME@$OLD_IPv4:/usr/local/x-ui/bin/config.json /usr/local/x-ui/bin/config.json
		sleep 1
		sshpass -p "$OLD_PASSWORD" scp -o StrictHostKeyChecking=no $OLD_LOGINNAME@$OLD_IPv4:/etc/x-ui/x-ui.db /etc/x-ui/x-ui.db
		green "X-UI files moved from old server to new server"
		enter2main
		;;
		
		2) # English X-UI Based
		echo
		yellow "its not completed, it's in test"
		enter2main		
		;;
		
		2) # English X-UI Based
		echo
		yellow "its not completed, it's in test"
		enter2main		
		;;
		
		3) # V2RAY Aegnt
		echo
		yellow "its not completed, it's in test"
		enter2main		
		;;
		
		4) # SSH PANEL
		echo
		yellow "its not completed yet, it's on test "
		enter2main		
		;;
		
		5) # SSR PANEL
		echo
		yellow "its not completed, it's in test"
		enter2main		
		;;
		
		6) #EXIT to main
		echo
		mainMenuRun
		;;		
		
		esac
	fi
}
		
function dhcpServerInstall() {

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

}
			
function customRouting() {

if test -f "/Golden1/ROUTE.sh";
then
rm /Golden1/ROUTE.sh
fi

mkdir -p /Golden1
cd /Golden1
curl -O https://raw.githubusercontent.com/ExtremeDot/golden_one/master/ROUTE.sh
chmod +x /Golden1/ROUTE.sh
bash /Golden1/ROUTE.sh

}

function v2flyClientInstall() {
green "Install v2ray Client-v2fly"
cd /tmp
bash <(curl -L https://raw.githubusercontent.com/v2fly/fhs-install-v2ray/master/install-release.sh)
sleep 2
systemctl enable v2ray
}

function v2flyClientConfig() {
nano /usr/local/etc/v2ray/config.json
}

function socksPortIpCheck() {
socksPortInput=1080
read -e -i "$socksPortInput" -p "Please Enter the Socks Port to check running Client's IP: " input
socksPortInput="${input:-$socksPortInput}"
curl --socks5 socks5://localhost:$socksPortInput https://myip.wtf/json
enter2main
}

function interfaceIpCheck() {
green "Listing Interfaces"
ifconfig | grep flags | awk '{print $1}' | sed 's/:$//' | grep -Ev 'lo'
green ""
interfaceName="$(ip -4 route ls | grep default | grep -Po '(?<=dev )(\S+)' | head -1)"
read -e -i "$interfaceName" -p "Please Enter the Network Interface name to check its IP: " input
interfaceName="${input:-$interfaceName}"

curl --interface $interfaceName https://myip.wtf/json
}

function jinwypScript() {
if test -f "/Golden1/jinwypScript/install_kernel.sh";
then
bash /Golden1/jinwypScript/install_kernel.sh
else
mkdir -p /Golden1/jinwypScript/
cd /Golden1/jinwypScript/
curl -O https://raw.githubusercontent.com/jinwyp/one_click_script/master/install_kernel.sh
chmod +x /Golden1/jinwypScript/install_kernel.sh
sleep 2
bash /Golden1/jinwypScript/install_kernel.sh
fi

}

function softEtherv4Install() {

green "Installing SoftEther 4 Server [Gold1Script]"
mkdir -p /Golden1/softether4
cd /Golden1/softether4
curl -O https://raw.githubusercontent.com/ExtremeDot/golden_one/master/build_se_stable.sh
chmod +x /Golden1/softether4/build_se_stable.sh
/Golden1/softether4/./build_se_stable.sh

}

function speedTestcli() {

status="$(dpkg-query -W --showformat='${db:Status-Status}' speedtest-cli 2>&1)"
if [ ! $? = 0 ] || [ ! "$status" = installed ]; then
green " - - - Installing package speedtest-cli"
apt-get install -y speedtest-cli
sleep 2
green " - - - Testing Speed By SPEEDTEST Servers"
speedtest
else
green " - - - Testing Speed By SPEEDTEST Servers"
speedtest
fi
}

function showCurrentipTABLES() {
iptables-save -t nat
}

function openConnectServer() {
if test -f "/Golden1/AnyConnect/ocserv-en.sh";
then
bash /Golden1/AnyConnect/ocserv-en.sh
else
echo " Installing the Server"
mkdir -p /Golden1/AnyConnect/
cd /Golden1/AnyConnect/
wget -N --no-check-certificate https://raw.githubusercontent.com/sfc9982/AnyConnect-Server/main/ocserv-en.sh
chmod +x /Golden1/AnyConnect/ocserv-en.sh
bash /Golden1/AnyConnect/ocserv-en.sh
fi
}

function openVpnAngristanInstall() {
if test -f "/Golden1/OpenVPN/openvpn-install.sh";
then
bash /Golden1/OpenVPN/openvpn-install.sh
else
echo " Installing ANGRISTAN OPENVPN "
mkdir -p /etc/openvpn/easy-rsa/pki/issued/
mkdir -p /Golden1/OpenVPN/
cd /Golden1/OpenVPN/
wget https://raw.githubusercontent.com/angristan/openvpn-install/master/openvpn-install.sh
chmod +x /Golden1/OpenVPN/openvpn-install.sh
bash /Golden1/OpenVPN/openvpn-install.sh
fi

}

function wireGuardAngristanInstall() {
if test -f "/Golden1/WireGuard/wireguard-install.sh";
then
bash /Golden1/WireGuard/wireguard-install.sh
else
mkdir -p /Golden1/WireGuard/
cd /Golden1/WireGuard/
curl -O https://raw.githubusercontent.com/angristan/wireguard-install/master/wireguard-install.sh
chmod +x /Golden1/WireGuard/wireguard-install.sh
bash /Golden1/WireGuard/wireguard-install.sh
fi
}

function restartSoftEtherServer() {
/etc/init.d/vpnserver restart

}

function dnsmasqEdit() {
nano /etc/dnsmasq.conf
}

function dnsmasqLogCheck() {
systemctl status dnsmasq.service
}

function openVpnStatusCheck() {
systemctl status openvpn@server
}

function softEtherInfoShow() {
/bin/seshow
}

function softEtherSecureNATinstall() {

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

green "vpnserver is configured as [SECURE-NAT]"
}

function checkRunningPorts() {
lsof -i -P -n | grep LIST
}

function dotRouterInstall() {
cd /tmp && curl -O https://raw.githubusercontent.com/ExtremeDot/DOT_ROUTER/master/main.sh
mv /tmp/main.sh /bin/dotrouter && chmod +x /bin/dotrouter
}

function getSystemStatus() {
echo -e "${YELLOW}Current Installed Kernel= `cat /proc/version | sed 's/.(.*//'`"
echo -e "${YELLOW}Current IPV4= `ifconfig eth0 | grep inet | grep netmask | grep -o -P '(?<=inet ).*(?=  netmask)'`"
echo -e "${YELLOW}Current IPV6= [`ifconfig eth0 | grep inet6 | grep global | grep -o -P '(?<=inet6 ).*(?=  prefixlen)'`]"
}

function getBbrStatus() {
green " check if bbr is running"
sysctl -n net.ipv4.tcp_congestion_control
sleep 1
lsmod | grep bbr
}

function nekorayCLIcustom() {
cd /tmp && curl -O https://raw.githubusercontent.com/ExtremeDot/vpn_setups/master/NEKORAY-CLI.sh
mv /tmp/NEKORAY-CLI.sh /bin/NEKORAY-CLI && chmod +x /bin/NEKORAY-CLI
bash /bin/NEKORAY-CLI
enter2main
}

function xrayClientInstaller() {
green "Installing latest xray core"
mkdir -p /Golden1/XrayClient
cd /Golden1/XrayClient
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install
sleep 2
systemctl enable xray
sleep 2
echo ""
echo "Updating geo files to latest"
cd /Golden1/XrayClient
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install-geodata
echo " all client requirements has installed"
}

function xrayClientConfig() {
nano /usr/local/etc/xray/config.json
}

function tun2SockInstaller() {
green  "Installing tune2socks"
mkdir -p /Golden1/tun2socks
cd /Golden1/tun2socks
wget https://github.com/xjasonlyu/tun2socks/releases/download/v2.4.1/tun2socks-linux-amd64.zip
unzip tun2socks-linux-amd64.zip
# 7z x tun2socks-linux-amd64.zip
rm *.zip
mv tun2socks-linux-amd64 /bin/tun2socks
chmod +x /bin/tun2socks
green " finishing tun2socks ......"

}

function badvpnTun2socksInstaller() {
green "Installing BADVPN " 
mkdir -p /Golden1/badvpn && cd /Golden1/badvpn && wget https://github.com/ambrop72/badvpn/archive/refs/tags/1.999.130.zip
sleep 2
unzip /Golden1/badvpn/1.999.130.zip && cd /Golden1/badvpn/badvpn-1.999.130/
sleep 2
cmake -DBUILD_NOTHING_BY_DEFAULT=1 -DBUILD_TUN2SOCKS=1
sleep 1
make
sleep 1
make install
sleep 1
green "badvpn installed successfully...."
}

function sstpClientInstaller() {
apt-get update
green "Installing sstp latest apt"
apt install sstp-client
green "sstp client installing has finished."
sstpc --version
}

function loadBalancerInstaller() {
green "Install LoadBalancer"
apt-get install -y build-essential
apt-get install -y perl
mkdir -p /Golden1/LoadBalancer && cd /Golden1/LoadBalancer
wget https://github.com/lstein/Net-ISP-Balance/archive/master.zip
sleep 2
unzip /Golden1/LoadBalancer/master.zip
sleep 1
cd /Golden1/LoadBalancer/Net-ISP-Balance-master
cpan Module::Build
sleep 1
perl ./Build.PL
sleep 1
./Build installdeps
sleep 1
./Build test
sleep 2
sudo ./Build install
echo
green "nano /etc/network/balance.conf to edit load balancer config"
echo
green "load_balance.pl  -d > commands.sh "
green "run above command to have your custom loadbalancer by running commands.sh script"
enter2main

}
function softEtherNote() {
echo
echo
blue " Blocked Country - IRAN -------------------------------------------------------"
yellow " Edit vpn_server.config file"
echo
green "	declare DDnsClient"
green "	{"
green "		bool Disabled true"
echo
green "	declare ServerConfiguration"
echo
green "		bool DisableNatTraversal true "
echo
echo
yellow " In the blocked country setup SE Server with a vHUB as follows"
green "- no bridge"
green "- no SecureNAT"
green "- no L3"
green "- no VPN Azure"
green "- yes IPsec/L2TP"
green "- yes OpenVPN/MS-SSTP"
green "- add VPN users"
echo 
blue " UnBlocked Country - WorldWide ----------------------------------------------"
yellow " On the VPS in unblocked country setup SE Server with a vHUB as follows:"
green "- no bridge"
green "- yes SecureNAT (with all defaults)"
green "- no L3"
green "- no VPN Azure"
green "- no IPsec/L2TP"
green "- no OpenVPN/MS-SSTP"
green "- add only 1 VPN user"
echo
green "Modify the value of "bool DisableJsonRpcWebApi" from "false" to "true" on the vpn_server.config or vpn_bridge.config."
green "Now cascade from the blocked SE Server to the unblocked SE Server on port 443 to avoid detection."

echo
}

function sstpClientConfigs() {
mkdir -p /Golden1/SSTP/
cd /Golden1/SSTP/

echo " "
SSTPCONAME1="sstp_"
read -e -i "$SSTPCONAME1" -p "SSTP CLient1: Please enter name for connection: " input
SSTPCONAME1="${input:-$SSTPCONAME1}"
echo " "
SSTPIP1="78."
read -e -i "$SSTPIP1" -p "SSTP CLient1: Please enter the SSTP Server IP: " input
SSTPIP1="${input:-$SSTPIP1}"
echo " "
SSTPORT1="443"
read -e -i "$SSTPORT1" -p "SSTP CLient1: Please enter the SSTP Server Port: " input
SSTPORT1="${input:-$SSTPORT1}"
echo " "
USERNAME1=""
read -e -i "$USERNAME1" -p "SSTP CLient1: Please enter username: " input
USERNAME1="${input:-$USERNAME1}"
echo " "
PASSWORD1=""
read -e -i "$PASSWORD1" -p "SSTP CLient1: Please enter password: " input
PASSWORD1="${input:-$PASSWORD1}"

# CLIENT1.SH
touch /Golden1/SSTP/client1.sh
sleep 1
cat <<EOF > /Golden1/SSTP/client1.sh
#!/bin/bash
client_name=$SSTPCONAME1
user=$USERNAME1
pass=$PASSWORD1
server=$SSTPIP1
port=$SSTPORT1
sstpc --cert-warn --save-server-route --user \$user --password \$pass \$server:\$port usepeerdns require-mschap-v2 noauth noipdefault ifname \$client_name
EOF

chmod +x /Golden1/SSTP/client1.sh

# SSTP1 CONNECT1.SH
touch /Golden1/SSTP/connect1.sh
cat <<EOF > /Golden1/SSTP/connect1.sh
#!/bin/bash
source /Golden1/defaults.sh
CLIENT_FILE=/Golden1/SSTP/client1.sh
CLIENT_NAME=\`sed -n -e '/client_name/{s/.*= *//p}' \$CLIENT_FILE | sed  's/.*"\(.*\)".*/\1/'\`
echo ""
echo -e "\${BLUE}[\$CLIENT_NAME] ---------------------------------------------- \${NC}" | cut -c 1-60
HTT=\`ip address show label \$CLIENT_NAME | grep inet | awk '{print \$2}'\`
if [ -n "\$HTT" ] ; then
echo -e "\${GREEN}\$INTFTXT1 [OK]\${NC} "
PINGTEST=\`ping -I \$CLIENT_NAME -qc2 \$HOST_PING | awk -F'/' 'END{ print (/^rtt/? "1":"0") }'\`
sleep 1
if [ \$PINGTEST = 1 ] ; then
echo -e "\${GREEN}\$PINGTXT1 [OK] \${NC}"
exit
else
# IF NO RESPONCE
echo -e "\${RED}\$PINGTXT1 [ER]\${NC}"
fi
fi
echo -e "\${RED}\$INTFTXT1 [ER]\${NC}"
# IF NO RESPONCE
# KILLING LAST CONNECTION IF EXISTS
SSTPID1=\`ps -ef | grep sstpc | grep \$CLIENT_NAME | awk '{print \$2}'\`
kill -9 \$SSTPID1
sleep 1
echo "\$CLIENT_NAME: STARTING SSTP CONNECTION"
# RUNNING CONNECTING SCRIPT SILENTLY
bash \$CLIENT_FILE </dev/null &>/dev/null &
EOF

chmod +x /Golden1/SSTP/connect1.sh

echo ""
echo "Run SSTP Client1?"
echo ""
until [[ $SSTP1_RUN =~ (y|n) ]]; do
read -rp "Run SSTP Connection: $SSTPCONAME1 ? [y/n]: " -e -i y SSTP1_RUN
done

if [[ $SSTP1_RUN == "y" ]]; then
echo ""
echo " Running $SSTPCONAME1 "
bash /Golden1/SSTP/connect1.sh
else
echo " you can test connection using these command"
echo "bash /Golden1/SSTP/connect1.sh"
fi


################################
# SETTING UP SSTP CLIENT 2
green "Setup SSTP Client Number 2"
mkdir -p /Golden1/SSTP/
cd /Golden1/SSTP/

echo
SSTPCONAME2="sstp_"
read -e -i "$SSTPCONAME2" -p "SSTP Client2: Please enter name for connection: " input
SSTPCONAME2="${input:-$SSTPCONAME2}"
echo " "
SSTPIP2="78."
read -e -i "$SSTPIP2" -p "SSTP Client2: Please enter the SSTP Server IP: " input
SSTPIP2="${input:-$SSTPIP2}"
echo " "
SSTPORT2="443"
read -e -i "$SSTPORT2" -p "SSTP Client2: Please enter the SSTP Server Port: " input
SSTPORT2="${input:-$SSTPORT2}"
echo " "
USERNAME2=""
read -e -i "$USERNAME2" -p "SSTP Client2: Please enter username: " input
USERNAME2="${input:-$USERNAME2}"
echo " "
PASSWORD2=""
read -e -i "$PASSWORD2" -p "SSTP Client2: Please enter password: " input
PASSWORD2="${input:-$PASSWORD2}"

# Client2.sh
touch /Golden1/SSTP/client2.sh
sleep 1
cat <<EOF > /Golden1/SSTP/client2.sh
#!/bin/bash
client_name2=$SSTPCONAME2
user=$USERNAME2
pass=$PASSWORD2
server=$SSTPIP2
port=$SSTPORT2
sstpc --cert-warn --save-server-route --user \$user --password \$pass \$server:\$port usepeerdns require-mschap-v2 noauth noipdefault ifname \$client_name2
EOF

chmod +x /Golden1/SSTP/client2.sh

# SSTP1 CONNECT2.SH
touch /Golden1/SSTP/connect2.sh
cat <<EOF > /Golden1/SSTP/connect2.sh
#!/bin/bash
source /Golden1/defaults.sh
CLIENT_FILE2=/Golden1/SSTP/client2.sh
CLIENT_NAME2=\`sed -n -e '/client_name/{s/.*= *//p}' \$CLIENT_FILE2 | sed  's/.*"\(.*\)".*/\1/'\`
echo ""
echo -e "\${BLUE}[\$CLIENT_NAME2] ---------------------------------------------- \${NC}" | cut -c 1-60
HTT2=\`ip address show label \$CLIENT_NAME2 | grep inet | awk '{print \$2}'\`
if [ -n "\$HTT2" ] ; then
echo -e "\${GREEN}\$INTFTXT1 [OK]\${NC} "
PINGTEST2=\`ping -I \$CLIENT_NAME2 -qc2 \$HOST_PING | awk -F'/' 'END{ print (/^rtt/? "1":"0") }'\`
sleep 1
if [ \$PINGTEST2 = 1 ] ; then
echo -e "\${GREEN}\$PINGTXT1 [OK] \${NC}"
exit
else
# IF NO RESPONCE
echo -e "\${RED}\$PINGTXT1 [ER]\${NC}"
fi
fi
echo -e "\${RED}\$INTFTXT1 [ER]\${NC}"
# IF NO RESPONCE
# KILLING LAST CONNECTION IF EXISTS
SSTPID2=\`ps -ef | grep sstpc | grep \$CLIENT_NAME2 | awk '{print \$2}'\`
kill -9 \$SSTPID2
sleep 1
echo "\$CLIENT_NAME2: STARTING SSTP CONNECTION"
# RUNNING CONNECTING SCRIPT SILENTLY
bash \$CLIENT_FILE2 </dev/null &>/dev/null &
EOF

chmod +x /Golden1/SSTP/connect2.sh

echo ""
echo "Run SSTP Client2?"
echo ""
until [[ $SSTP2_RUN =~ (y|n) ]]; do
read -rp "Run SSTP Connection: $SSTPCONAME2 ? [y/n]: " -e -i y SSTP2_RUN
done

if [[ $SSTP2_RUN == "y" ]]; then
echo ""
echo " Running $SSTPCONAME2 "
bash /Golden1/SSTP/connect2.sh
else
echo " you can test connection using these command"
echo "bash /Golden1/SSTP/connect2.sh"
fi

}

function irandatGeofiles() {
cd /usr/local/x-ui/bin
sleep
wget https://github.com/bootmortis/iran-hosted-domains/releases/latest/download/iran.dat
wget https://github.com/v2fly/domain-list-community/releases/latest/download/dlc.dat
echo
green " read https://github.com/iranxray/hope/blob/main/routing.md "
}

function readStatus() {
echo 
green "Show System Status ============================================================================="
echo -e "${YELLOW} Current Installed Kernel= `cat /proc/version | sed 's/.(.*//'`"
echo
VPSSERVER_NIC=$(ip -4 route ls | grep default | grep -Po '(?<=dev )(\S+)' | head -1)
echo -e "${YELLOW} Current IPV4= `ifconfig $VPSSERVER_NIC | grep inet | grep netmask | grep -o -P '(?<=inet ).*(?=  netmask)'`"
echo -e "${YELLOW} Current IPV6= [`ifconfig $VPSSERVER_NIC | grep inet6 | grep global | grep -o -P '(?<=inet6 ).*(?=  prefixlen)'`]"
echo 
echo -e "${YELLOW} BBR Status= `sysctl -n net.ipv4.tcp_congestion_control` - `lsmod | grep bbr`" 
echo
green "Current DNS status --"
cat /etc/resolv.conf
echo
green "User Variables Info --"
echo -e "${YELLOW} OLD SERVER: IP:$OLD_IPv4 | Username: $OLD_LOGINNAME | Password: $OLD_PASSWORD"
echo -e "${YELLOW} NEW SERVER: IP:$NEW_IPv4 | Username: $NEW_LOGINNAME | Password: $NEW_PASSWORD"
echo -e "${YELLOW} Domain: $DOMAIN_ADDRESS | Email: $EMAIL_ADDRESS"
echo -e "${GREEN}"

}

function changeSshApachePorts() {
nano /etc/ssh/sshd_config
nano /var/www/html/p/menu.php
nano /var/www/html/p/kill.php
systemctl restart apache2
systemctl restart sshd
}

function sshPanelUMHamedAP() {
bash <(curl -Ls https://raw.githubusercontent.com/HamedAp/Ssh-User-management/master/install.sh --ipv4)
}

function shadowSocksRPanel() {
bash <(curl -sL https://raw.githubusercontent.com/Miuzarte/hijk.sh/main/Original/ssr.sh)
}


# all functions
function listHelp() {

green "shadowSocksRPanel"
green "sstpClientConfigs"
green "loadBalancerInstaller"
green "sstpClientInstaller"
green "badvpnTun2socksInstaller"
green "tun2SockInstaller"
green "colorScript"
green "installTools"
green "isRoot"
green "getOldServerData"
green "getNewServerData"
green "getDomainInfo"	# get Domain name data from User Input 
green "getEmailInfo"	# get Email Address data from User Input 
green "checkDomainNamewithIP" # check if Current VPS ip is set to NEW Server or Not?
green "vpsDetectionByIP" # check if current VPS is NEW or OLD Server after getOldServerData and getNewServerData function
# MISC
green "dnsmasqEdit"	# EDIT DNSMASQ
green "dnsmasqLogCheck" # CHECK DNSMASQ LOG
green "openVpnStatusCheck"	# OPENVPN STATUS
green "getSystemStatus"	#Get System Status
green "getBbrStatus"	#get BBR STATUS
green "acmeInstaller"
green "mainMenuRun"
green "bbrEnabler"
green "ipv6Enabler"
green "firewallEnabler"
green "enter2main"	#hit enter to back to main menu

green "dotRouterInstall"	#DOT ROUTER
green "dhcpServerInstall"	#Installing DHCP Server
green "customRouting"	#custom ROUTING 
# V2RAYS
green "nekorayCLIcustom"	#NEKORAY CLI CUSTOM
green "v2flyClientInstall"
green "v2flyClientConfig"
green "xrayClientConfig"	#XRAY CONFIG
green "xrayClientInstaller"	#XRAY INSTALLER
green "xuiMigrator"
green "extremeDotV2RAInstaller"	#V2ray-Agent english translated
green "vaxiluv2rayInstaller"
green "nidukav2rayInstaller"
green "proxyKingV2rayInstaller"
green "hamedAPv2rayInstaller"
# TUNERS
green "installXanModKernel"
green "jinwypScript"
# SOFTETHER
green "softEtherv4Install"
green "restartSoftEtherServer"
green "softEtherInfoShow"	# Softether SHOW GOLDEN 1
green "softEtherSecureNATinstall"	#SoftEther Secure-NAT
# TESTS
green "checkRunningPorts"
green "socksPortIpCheck"	# check IP baesd on Proxy Port running over localhost
green "interfaceIpCheck"	# check IP for NIC
green "speedTestcli"
green "showCurrentipTABLES"
# VPN SERVERS
green "openConnectServer"
green "openVpnAngristanInstall"
green "wireGuardAngristanInstall"
green "sshPanelUMHamedAP"	#Ssh-User-management In Persian Language
}

function xrayv2rayInstall() {
mkdir -p /Golden1/V2ray
cd /Golden1/V2ray/
echo ""
echo "Installing latest V2Ray,V2fly clients"
bash <(curl -L https://raw.githubusercontent.com/v2fly/fhs-install-v2ray/master/install-dat-release.sh)
echo ""
echo "Updating Geo Files for V2ray Client"
bash <(curl -L https://raw.githubusercontent.com/v2fly/fhs-install-v2ray/master/install-dat-release.sh)

echp "Installing latest xray core"
mkdir -p /Golden1/Xray
cd /Golden1/Xray
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install

sleep 2
echo "Updating geo files to latest"
cd /Golden1/Xray

bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install-geodata

systemctl enable xray
sleep 2
systemctl enable v2ray
}

function xrayvrayRestart() {
green "Restarting V2ray and Xray Services"
systemctl restart v2ray
sleep 2
systemctl restart xray
}

function updateTheScript() {
mkdir -p /tmp/extdot
cd /tmp/extdot
wget https://raw.githubusercontent.com/ExtremeDot/golden_one/main/extremeDOT.sh
chmod +x /tmp/extdot/extremeDOT.sh
mv /tmp/extdot/extremeDOT.sh /bin/extremeDOT
chmod +x /bin/extremeDOT
bash /bin/extremeDOT ; exit
}

function firstStart() {
clear
isRoot
colorScript
installTools
}

function extractCert() {
DOMAINNM1=""
read -e -i "$DOMAINNM1" -p "Please Enter The Domain Name " input
DOMAINNM1="${input:-$DOMAINNM1}"
~/.acme.sh/acme.sh --installcert -d $DOMAINNM1 --key-file /root/private.key --fullchain-file /root/cert.crt
green " /root/private.key & /root/cert.crt"
}

function xrayconfigEdit() {
nano /usr/local/etc/xray/config.json
}

function v2rayconfigEdit() {
nano /usr/local/etc/v2ray/config.json
}

function loadbalancerInstall() {
green "Install LoadBalancer"
apt-get install -y build-essential
apt-get install -y perl
mkdir -p /Golden1/loadbalancer
cd /Golden1/loadbalancer
wget https://github.com/lstein/Net-ISP-Balance/archive/master.zip
sleep 2
unzip /Golden1/loadbalancer/master.zip
sleep 1
cd /Golden1/loadbalancer/Net-ISP-Balance-master
cpan Module::Build
sleep 1
perl ./Build.PL
sleep 1
./Build installdeps
sleep 1
./Build test
sleep 2
sudo ./Build install
echo
green "nano /etc/network/balance.conf to edit load balancer config"
echo
green "load_balance.pl  -d > commands.sh "
green "run above command to have your custom loadbalancer by running commands.sh script"
}

function tuns2socksInstaller() {
green "Installing BADVPN " 
mkdir -p /Golden1/badvpn && cd /Golden1/badvpn && wget https://github.com/ambrop72/badvpn/archive/refs/tags/1.999.130.zip
sleep 2
unzip /Golden1/badvpn/1.999.130.zip && cd /Golden1/badvpn/badvpn-1.999.130/
sleep 2
cmake -DBUILD_NOTHING_BY_DEFAULT=1 -DBUILD_TUN2SOCKS=1
sleep 1
make
sleep 1
make install
sleep 1
green "badvpn finished ...."
echo
green "Installing tune2socks"
mkdir -p /Golden1/tun2s
cd /Golden1/tun2s
wget https://github.com/xjasonlyu/tun2socks/releases/download/v2.4.1/tun2socks-linux-amd64.zip
unzip tun2socks-linux-amd64.zip
# 7z x tun2socks-linux-amd64.zip
rm *.zip
mv tun2socks-linux-amd64 /bin/tun2socks
chmod +x /bin/tun2socks
green "finishing tun2socks ......"
}

function setDNSpermanent() {
echo "nameserver 8.8.8.8" > /etc/resolv.conf
apt install -y resolvconf
sudo systemctl start resolvconf.service
sudo systemctl enable resolvconf.service
echo "nameserver 8.8.8.8" > /etc/resolvconf/resolv.conf.d/head
echo "nameserver 8.8.4.4" >> /etc/resolvconf/resolv.conf.d/head
sudo systemctl restart resolvconf.service
sudo systemctl restart systemd-resolved.service
echo " Do reboot to take effects."
echo
echo "you can change the configs from /etc/resolvconf/resolv.conf.d/head file"
echo
}

function portCheckCustom() {
echo
V2RAYPORT=10808
read -e -i "$V2RAYPORT" -p "Enter The V2ray Running Local Port: " input
V2RAYPORT="${input:-$V2RAYPORT}"
V2RAYPING=`curl --silent --connect-timeout 10 -m 10 --socks5 socks5://localhost:$V2RAYPORT -o /dev/null -s -w 'Total: %{time_total}s\n' google.com | cut -c 7-20`
V2RAYIP=`curl --silent --connect-timeout 10 -m 10 --socks5 socks5://localhost:$V2RAYPORT https://myip.wtf/json | grep YourFuckingIPAddress | sed  's/.*"\(.*\)".*/\1/'`
V2RAYLOCATION=`curl --silent --connect-timeout 10 -m 10 --socks5 socks5://localhost:$V2RAYPORT https://myip.wtf/json | grep YourFuckingLocation | sed  's/.*"\(.*\)".*/\1/'`
echo
echo -e "${YELLOW}Connection Name [V2RAY]= NEEDUPDATE" ;echo ""
echo -e "${RED}IP=$V2RAYIP ${GREEN}IP Location=$V2RAYLOCATION "
echo -e "${BLUE}Ping to Google=$V2RAYPING ${NC}"
echo
}


function interfaceCheckCustom() {
echo
customInterfaceName=xray-tun
read -e -i "$customInterfaceName" -p "Enter Interface to check running net over it: " input
customInterfaceName="${input:-$customInterfaceName}"
INTERFACEPING=`curl --connect-timeout 10 -m 10 --interface $customInterfaceName -o /dev/null -s -w 'Total: %{time_total}s\n' google.com | cut -c 7-20`
INTERFACEIP=`curl --silent --connect-timeout 10 -m 10 --interface $customInterfaceName -4 myip.wtf/json | grep YourFuckingIPAddress | sed  's/.*"\(.*\)".*/\1/'`
INTERFACELOCATION=`curl --silent --connect-timeout 10 -m 10 --interface $customInterfaceName -4 myip.wtf/json | grep YourFuckingLocation | sed  's/.*"\(.*\)".*/\1/'`
echo -e "${YELLOW}Connection Name $customInterfaceName"
echo
echo -e "${RED}IP=$INTERFACEIP ${GREEN}IP Location=$INTERFACELOCATION "
echo -e "${BLUE}Ping to Google=$INTERFACEPING ${NC}"
echo
}


function mainMenuRun() {
#MAIN MENU SCRIPt
echo "nameserver 8.8.8.8" > /etc/resolv.conf
echo -e "${GREEN}"
yellow "EXTREME DOT - GOLDEN1 MENU ============================================================[Version $scriptVersion]"

blue "--- Initial Setup -----------------------------------------------------------------------------------"
echo "1)  System Status & Show Status                            6) Input OLD and NEW Server Information "
echo "2)  Install XAN MOD KERNEL                                 7) Input Domain and Email Address "
echo "3)  Install JINWYP Kernel Tuner Script                     8) IPV6 [DIS/EN]ABLER"
echo "4)  Install Certificate USING ACME                         9) Edit SSH config file"
echo "5)  Firewall [DIS/EN]ABLER"

blue "--- X-UI BASED VPN SERVERS --------------------------------------------------------------------------"
echo "10) X-UI MIGRATION SCRIPT - MOVE FILES TO NEW SERVER"
echo "11) Install VAXILU v2RAY X-UI Panel                      19) Misaka X-UI Panel"
echo "12) Install ProxyKingDEV v2RAY X-UI Panel                20) Iran Geo and Dat files"
echo "13) Install NIDUKA AKALANKA ENGLISH X-UI Panel  "
echo "14) Install HAMED-AP V2RAY Panel  "
echo "15) Install MACK-A v2RAY AGENT Script [ENGLISH]"


blue "--- SSH, SSR and ETC --------------------------------------------------------------------------------"
echo "16) Install HAMED-AP SSH Panel                            18) Change SSH & Apache Port numbers"
echo "17) Install ShodowSocksR Server"

blue "--- SoftEther ---------------------------------------------------------------------------------------"
echo "Install Softether Server          21) [OUTSIDE IRAN]      22)[INSIDE IRAN]"
echo "                                  23) Secure NAT MODE     24) Show Settings "
echo "                                  25) Restart             26) Installation Note"

blue "--- Configs, Tools, Clients & Misc. -----------------------------------------------------------------"
echo "31) Install XRAY and V2RAY                                36) EDIT CONFIG: NEKORAY CLI"				
echo "32) Restarting V2ray And Xray Services                    37) Install SSTP Client"
echo "33) Config Edit X-ray                                     38) EDIT CONFIG: SSTP Client 1"
echo "34) Config Edit V2ray                                     39) EDIT CONFIG: SSTP Client 2"
echo "35) Install NEKORAY CLI Client                            40) ACME extract Cert to /root/*"

blue "--- Local Server/Clients ----------------------------------------------------------------------------"
echo "51) Install DHCP Server                                   56) Interface net check "
echo "52) Install DOT ROUTER                                    57) EDIT CONFIG: XRAY Client"
echo "53) Install LOAD BALANCER"
echo "54) Install BADVPN-TUN2SOCKS & TUN2SOCKS"
echo "55) Cutom Port Number Check "

blue "--- OpenVPN, WireGuard and Open Connect Servers -----------------------------------------------------"
echo "71) Install ANGRISTAN OPEN VPN SERVER                     74) Custom Routing between two connections"
echo "72) Install ANGRISTAN WIREGUARD SERVER"
echo "73) Install Open Connect SERVER"

blue "--- Diagnostics,troubleshooting tools ---------------------------------------------------------------"
echo "80) SpeedTest Client to check the real SPEED              85) Show Current IPTABLES ROUTING"
echo "81) Show Current System Public IP                         86) GET BBR STATUS"
echo "82) Check Public IP by Socks 5 Port's Number              87) Set DNS Permanently to Google"
echo "83) Check Public IP by Interface's Name"
echo "84) Show Busy/Used Ports by System"
echo "0)  EXIT                                                  98) Reboot Linux      99) Update ExtremeDOT "
yellow "Please Enter the Number ============================================================================="
echo -e "${GREEN}"
MENUITEMR=""
until [[ $MENUITEMR =~ ^[0-9]+$ ]] && [ "$MENUITEMR" -ge 0 ] && [ "$MENUITEMR" -le 99 ]; do
read -rp "$MENUITEMR [Please Select 0-99]: " -e  MENUITEMR
done

#################################
case $MENUITEMR in

0) # EXIT
echo -e "${NC}"
exit 
;;

1) # System Status
readStatus
enter2main
;;

2) # Install XAN MOD KERNEL
installXanModKernel
enter2main
;;

3) # Install JINWYP Kernel Tuner Script
jinwypScript
enter2main
;;

4) # Install Certificate USING ACME
acmeInstaller
enter2main
;;

5) # Enabling Firewall
firewallEnabler
enter2main
;;

6) # Input OLD and NEW Server Information
getOldServerData
getNewServerData
enter2main
;;

7) #  Input Domain and Email Address
getDomainInfo
getEmailInfo
enter2main
;;

8) # IPV6 [DIS/EN]ABLER
ipv6Enabler
enter2main
;;

9) #Edit SSH config file"
green "Editing sshd Config"
nano /etc/ssh/sshd_config
green "Restarting SSH Service"
systemctl restart sshd
enter2main
;;

10) # X-UI MIGRATION SCRIPT - MOVE FILES TO NEW SERVER
xuiMigrator
enter2main
;;

11) # Install VAXILU v2RAY X-UI Panel
vaxiluv2rayInstaller
enter2main
;;

12) # Install ProxyKingDEV v2RAY X-UI Panel
proxyKingV2rayInstaller
enter2main
;;
13) # Install NIDUKA AKALANKA ENGLISH X-UI Panel
nidukav2rayInstaller
enter2main
;;

14) # Install HAMED-AP V2RAY Panel
hamedAPv2rayInstaller
enter2main
;;

15) # Install MACK-A v2RAY AGENT Script [TRANSLATED to ENGLISH]
extremeDotV2RAInstaller
enter2main
;;

16) # Install HAMED-AP SSH Panel
sshPanelUMHamedAP
enter2main
;;

17) #Install ShodowSocksR Server
shadowSocksRPanel
enter2main
;;

18) # Change SSH Ports
changeSshApachePorts
enter2main
;;

19) # MISAKA
bash <(curl -Ls https://raw.githubusercontent.com/Misaka-blog/x-ui-msk/master/install.sh)
enter2main
;;

20) # Iran DAT FILES
irandatGeofiles
enter2main
;;

21) # Install Softether Server [OUTSIDE IRAN]
softEtherv4Install
enter2main
;;

22) #Install Softether Server [INSIDE IRAN]
softEtherv4Install
enter2main
;;

23) #Install Softether Secure NAT MODE
softEtherSecureNATinstall
enter2main
;;

24) #Softether Show Settings
softEtherInfoShow
enter2main
;;

25) #Softether Restart
restartSoftEtherServer
enter2main
;;

26) # SoftEther Install NOTE
softEtherNote
enter2main
;;

31) # Install XRAY and V2RAY
xrayv2rayInstall
enter2main
;;

32) # Restarting V2ray And Xray Services
xrayvrayRestart
enter2main
;;

33) # xray config
xrayconfigEdit
enter2main
;;

34) # xray config
v2rayconfigEdit
enter2main
;;

40) #ACME extract Cert to /root/
extractCert
enter2main
;;

53) # LOAD BALANCER INSTALL
loadbalancerInstall
enter2main
;;

54) # Install BADVPN-TUN2SOCKS & TUN2SOCKS
tuns2socksInstaller
enter2main
;;

55) # Port check
portCheckCustom
enter2main
;;

56) # Interface Check
interfaceCheckCustom
enter2main
;;

71) # Install ANGRISTAN OPEN VPN SERVER
openVpnAngristanInstall 
enter2main
;;

72) # Install ANGRISTAN WIREGUARD SERVER"
wireGuardAngristanInstall
enter2main
;;


74) # custom routing
customRouting
enter2main
;;

80) # SpeedTest Client to check the real SPEED
speedTestcli
enter2main
;;

81) #Show Current System Public IP
curl -4 myip.wtf/json
enter2main
;;

82) # Check Public IP by Socks 5 Port's Number
portCheckCustom
enter2main
;;

83) # Check Public IP by Interface's Name
interfaceCheckCustom
enter2main
;;

84) #Show Busy/Used Ports by System
checkRunningPorts
enter2main
;;

85) # Show Current IPTABLES ROUTING
showCurrentipTABLES
enter2main
;;

86) # GET BBR STATUS
getBbrStatus
enter2main
;;

87) # Set DNS Permanent
setDNSpermanent
enter2main
;;

98) #reboot
reboot
;;

99) #update
updateTheScript
;;


esac

}

firstStart
clear
mainMenuRun
echo -e "${NC}"
