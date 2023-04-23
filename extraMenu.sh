#!/bin/bash
#EXTREME DOT Multibalance Menu
scriptVersion=0.14

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
# installing dnsutils
if [ $(dpkg-query -W -f='${Status}' dnsutils  2>/dev/null | grep -c "ok installed") -eq 0 ];
then
yellow "Installing dnsutils"
apt install -y dnsutils
else
green "dnsutils has installed"
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

### DNS
function setDNSpermanent() {
clear
echo " CURRNET DNS LIST"
if grep -q "127.0.0.53" "/etc/resolv.conf"; then
                        RESOLVCONF='/run/systemd/resolve/resolv.conf'
                else
                        RESOLVCONF='/etc/resolv.conf'
fi
echo "$RESOLVCONF "

echo "`sed -ne 's/^nameserver[[:space:]]\+\([^[:space:]]\+\).*$/\1/p' $RESOLVCONF`"
echo 
        echo "What DNS resolvers do you want to use with the VPN?"
        echo "   1) Cloudflare (Anycast: worldwide)"
        echo "   2) Quad9 (Anycast: worldwide)"
        echo "   3) Quad9 uncensored (Anycast: worldwide)"
        echo "   4) FDN (France)"
        echo "   5) DNS.WATCH (Germany)"
        echo "   6) OpenDNS (Anycast: worldwide)"
        echo "   7) Google (Anycast: worldwide)"
        echo "   8) Yandex Basic (Russia)"
        echo "   9) AdGuard DNS (Anycast: worldwide)"
        echo "   10) NextDNS (Anycast: worldwide)"
        echo "   11) SKIP, No change"
	echo "   12) Custom"
        until [[ $DNS =~ ^[0-9]+$ ]] && [ "$DNS" -ge 1 ] && [ "$DNS" -le 12 ]; do
                read -rp "DNS [1-12]: " -e -i 9 DNS
                
                if [[ $DNS == "12" ]]; then
                        until [[ $DNS1 =~ ^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$ ]]; do
                                read -rp "Primary DNS: " -e DNS1
                        done
                        until [[ $DNS2 =~ ^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$ ]]; do
                                read -rp "Secondary DNS (optional): " -e DNS2
                                if [[ $DNS2 == "" ]]; then
                                        break
                                fi
                        done
                fi
        done
		
apt install -y resolvconf
sudo systemctl start resolvconf.service
sudo systemctl enable resolvconf.service

DEST_RESOLV="/etc/resolvconf/resolv.conf.d/head"
case $DNS in
        
        1) # Cloudflare
                echo 'nameserver 1.1.1.1' > $DEST_RESOLV
                echo 'nameserver 1.0.0.1' >> $DEST_RESOLV
		DNSMSQ_SERV=1.1.1.1
		DNSMSQ_SERV2=1.0.0.1
                ;;
        2) # Quad9
                echo 'nameserver 9.9.9.9' > $DEST_RESOLV
                echo 'nameserver 149.112.112.112' >> $DEST_RESOLV
		DNSMSQ_SERV=9.9.9.9
		DNSMSQ_SERV2=149.112.112.112
                ;;
        3) # Quad9 uncensored
                echo 'nameserver 9.9.9.10' > $DEST_RESOLV
                echo 'nameserver 149.112.112.10' >> $DEST_RESOLV
		DNSMSQ_SERV=9.9.9.10
		DNSMSQ_SERV2=149.112.112.10
                ;;
        4) # FDN
                echo 'nameserver 80.67.169.40' > $DEST_RESOLV
                echo 'nameserver 80.67.169.12' >> $DEST_RESOLV
		DNSMSQ_SERV=80.67.169.40
		DNSMSQ_SERV2=80.67.169.12
                ;;
        5) # DNS.WATCH
                echo 'nameserver 84.200.69.80' > $DEST_RESOLV
                echo 'nameserver 84.200.70.40' >> $DEST_RESOLV
		DNSMSQ_SERV=84.200.69.80
		DNSMSQ_SERV2=84.200.70.40
                ;;
        6) # OpenDNS
                echo 'nameserver 208.67.222.222' > $DEST_RESOLV
                echo 'nameserver 208.67.220.220' >> $DEST_RESOLV
		DNSMSQ_SERV=208.67.222.222
		DNSMSQ_SERV2=208.67.220.220
                ;;
        7) # Google
                echo 'nameserver 8.8.8.8' > $DEST_RESOLV
                echo 'nameserver 8.8.4.4' >> $DEST_RESOLV
		DNSMSQ_SERV=8.8.8.8
		DNSMSQ_SERV2=8.8.4.4
                ;;
	8) # Yandex Basic
                echo 'nameserver 77.88.8.8' > $DEST_RESOLV
                echo 'nameserver 77.88.8.1' >> $DEST_RESOLV
		DNSMSQ_SERV=77.88.8.8
		DNSMSQ_SERV2=77.88.8.1
                ;;
        9) # AdGuard DNS
                echo 'nameserver 94.140.14.14' > $DEST_RESOLV
                echo 'nameserver 94.140.15.15' >> $DEST_RESOLV
		DNSMSQ_SERV=94.140.14.14
		DNSMSQ_SERV2=94.140.15.15
                ;;
        10) # NextDNS
                echo 'nameserver 45.90.28.167' > $DEST_RESOLV
                echo 'nameserver 45.90.30.167' >> $DEST_RESOLV
		DNSMSQ_SERV=45.90.28.167
		DNSMSQ_SERV2=45.90.30.167
                ;;
	11) # NO CHNAGE
        	DNSMSQ_SERV=8.8.8.8
		DNSMSQ_SERV2=8.8.4.4        
                ;;
        12) # Custom DNS
                echo "nameserver $DNS1" > $DEST_RESOLV
		DNSMSQ_SERV=$DNS1
		DNSMSQ_SERV2=8.8.8.8
                if [[ $DNS2 != "" ]]; then
                        echo "nameserver $DNS2" >> $DEST_RESOLV
			DNSMSQ_SERV2=$DNS2
                fi
                ;;
        esac

sudo systemctl restart resolvconf.service
sudo systemctl restart systemd-resolved.service
echo " Do reboot to take effects."
echo
echo "you can change the configs from /etc/resolvconf/resolv.conf.d/head file"
echo
}

# LOADING PACKAGES
function firstStart() {
clear
isRoot
colorScript
installTools
}

function updateTheScript() {
mkdir -p /tmp/extdotmenu1
cd /tmp/extdotmenu1
echo "nameserver 8.8.8.8" > /etc/resolv.conf
echo "nameserver 1.1.1.1" >> /etc/resolv.conf
wget https://raw.githubusercontent.com/ExtremeDot/GoldenOne_MENU/main/extraMenu.sh
chmod +x /tmp/extdotmenu1/extraMenu.sh
mv /tmp/extdotmenu1/extraMenu.sh /bin/eMenu
chmod +x /bin/eMenu
bash /bin/eMenu ; exit
}

####################### CLOUDFLARE MENU
function enter2CLmain() {
read -p "Press enter to back to Cloudflare menu"
cloudflaremenu
}

function cloudflaremenu() {
clear
CLFscriptVersion=1.00
# CLF STATUS
if [ $(dpkg-query -W -f='${Status}' cloudflare-warp 2>/dev/null | grep -c "ok installed") -eq 0 ];
then
red "cloudflare-warp not found, please install it first"
CLSTATUS=FALSE
else
CLSTATUS=TRUE
green "cloudflare-warp has installed"
fi
## MENU
echo -e "${GREEN}"
clear
blue "EXTREME DOT - Cloudflare MENU =================================================[Version $CLFscriptVersion]"
echo
echo "1) Cloudflare Warp+ Client Details                2) Install Cloudflare Warp+"
echo "3) Register and Enable New Account                4) Set New Licence Key"
echo "5) Connect                                        6) Disconnect"
echo "7) Connection Full Stat                           8) Check IP Location of CloudFlare Client"
red "9) Delete Cloudflare account"
echo
blue "--- Cloudflare Mods ------------------------------------------------------------------------"
echo "11) WARP"
echo "12) DOH"
echo "13) DOT"
echo "14) WARP + DOH"
echo "15) WARP + DOT"
echo "16) PROXY                                        17) Set Proxy port"
echo
blue "--- Cloudflare Warp Info -------------------------------------------------------------------"
if [ $CLSTATUS == "TRUE" ]; then
echo "CloudFlare Warp $(warp-cli status)" | head -c -2
echo "Connection Details: ==================="
warp-cli warp-stats
else 
echo
red "CloudFlare Warp Not Installed! ."
echo
fi
blue "--- Cloudflare Warp Info -------------------------------------------------------------------"
echo 
yellow  "Please Enter the Number ============================== ENTER 0  Back to Main-Menu =========="
echo -e "${GREEN}"
CLMENUITEMR=""
until [[ $CLMENUITEMR =~ ^[0-9]+$ ]] && [ "$CLMENUITEMR" -ge 0 ] && [ "$CLMENUITEMR" -le 99 ]; do
read -rp "$CLMENUITEMR [Please Select 0-99]: " -e  CLMENUITEMR
done

#################################
case $CLMENUITEMR in

0) # EXIT
clear
mainMenuRun
;;

1) # Cloudflare Warp+ Client Details
clear
if [ $CLSTATUS == "TRUE" ]; then
warp-cli account
else
red "cloudflare-warp not found, please install it first"
fi
enter2CLmain
;;


2) # Install Cloudflare Warp+
clear
if [ $CLSTATUS == "TRUE" ]; then
yellow "Cloudflare has installed allready."
else
echo "Insatlling CloudFlare Warp+"
apt --fix-broken install
apt-get install desktop-file-utils nftables dirmngr gnupg gnupg-l10n gnupg-utils gnupg2 gpg gpg-agent gpg-wks-client gpg-wks-server gpgconf gpgsm libassuan0 libksba8 libnpth0 libnspr4 libnss3 libnss3-tools pinentry-curses
#apt install cloudflare-warp
###
echo "----------------------------------------------------------------------------"
echo " Enter the package link of cloudflare for your OS, default is for Debian11"
echo " check the site and paste latest link"
echo " -----"
apt --fix-broken install -y
echo " https://pkg.cloudflareclient.com/packages/cloudflare-warp"
mkdir -p /ExtremeDOT/
echo 
DLLINK=https://pkg.cloudflareclient.com/uploads/cloudflare_warp_2023_3_258_1_amd64_f876b846af.deb
DLFILE=/ExtremeDOT/cloudflare_warp.deb
read -e -i "$DLLINK" -p "Cloudflare Deb package address: " input
DLLINK="${input:-$DLLINK}"
echo "nameserver 8.8.8.8" > /etc/resolv.conf
sleep 2
curl -L $DLLINK --output $DLFILE
sleep 2
if [ -f "$DLFILE" ];
  then
    echo "Deab package file has downloaded."
    dpkg -i $DLFILE
    sleep 2
  else
    echo "Installation files are not downloaded, EXIT "
    sleep 5
    echo " check Network and Source files and retry again."
fi

#warp-cli register
#warp-cli enable-always-on
#warp-cli enable-connectivity-checks
fi
enter2CLmain
;;

3) #Register and Enable New Account 
warp-cli register
warp-cli enable-always-on
warp-cli enable-connectivity-checks
enter2CLmain
;;

4) # Set New Licence Key
clear
if [ $CLSTATUS == "TRUE" ]; then
CL_KEY=''
read -e -i "$CL_KEY" -p "Enter Cloudflare Warp+ Account License KEY: " input
CL_KEY="${input:-$CL_KEY}"
warp-cli set-license $CL_KEY
else
red "cloudflare-warp not found, please install it first"
fi
enter2CLmain
;;

8) # Get Cloudflare Network
if [ $CLSTATUS == "TRUE" ]; then
echo
echo "==========================================================="
echo
curl -4 myip.wtf/json --interface CloudflareWARP -m 10 
echo
echo "==========================================================="
else
red "cloudflare-warp not found, please install it first"
fi
enter2CLmain
;;

5) # Cloudflare Connect
clear
if [ $CLSTATUS == "TRUE" ]; then
warp-cli connect
else
red "cloudflare-warp not found, please install it first"
fi
enter2CLmain
;;

6) # Cloudflare Disconnect
clear
if [ $CLSTATUS == "TRUE" ]; then
warp-cli disconnect
else
red "cloudflare-warp not found, please install it first"
fi
enter2CLmain
;;

7) # Cloudflare Full stats
clear
if [ $CLSTATUS == "TRUE" ]; then
warp-cli warp-stats
else
red "cloudflare-warp not found, please install it first"
fi
enter2CLmain
;;

9) #Delete Cloudflare account
clear
if [ $CLSTATUS == "TRUE" ]; then
warp-cli delete
else
red "cloudflare-warp not found, please install it first"
fi
enter2CLmain
;;

11) #WARP
if [ $CLSTATUS == "TRUE" ]; then
warp-cli set-mode warp
else
red "cloudflare-warp not found, please install it first"
fi
enter2CLmain
;;

12) #DOH
if [ $CLSTATUS == "TRUE" ]; then
warp-cli set-mode doh
else
red "cloudflare-warp not found, please install it first"
fi
enter2CLmain
;;

13) #DOT
if [ $CLSTATUS == "TRUE" ]; then
warp-cli set-mode dot
else
red "cloudflare-warp not found, please install it first"
fi
enter2CLmain
;;

14) #WARP + DOH
if [ $CLSTATUS == "TRUE" ]; then
warp-cli set-mode warp+doh
else
red "cloudflare-warp not found, please install it first"
fi
enter2CLmain
;;

15) #WARP + DOT
if [ $CLSTATUS == "TRUE" ]; then
warp-cli set-mode warp+dot
else
red "cloudflare-warp not found, please install it first"
fi
enter2CLmain
;;

16) #PROXY
if [ $CLSTATUS == "TRUE" ]; then
warp-cli set-mode proxy
else
red "cloudflare-warp not found, please install it first"
fi
enter2CLmain
;;

17) # SET PORT PROXY
if [ $CLSTATUS == "TRUE" ]; then
echo
CL_ProxyPort=''
read -e -i "$CL_ProxyPort" -p "Enter port for proxy set [1000-50000]: " input
CL_ProxyPort="${input:-$CL_ProxyPort}"
warp-cli set-proxy-port $CL_ProxyPort
else
red "cloudflare-warp not found, please install it first"
fi
enter2CLmain
;;
esac
}

#####################

# MENU RETURN
function enter2main() {
read -p "Press enter to back to menu"
mainMenuRun
}

# READ STATUS
function readStatus() {
clear
echo
green "Show System Status ============================================================================="
green "Kernel Info -----"
echo -e "${YELLOW} Current Installed Kernel= `cat /proc/version | sed 's/.(.*//'`"
echo
VPSSERVER_NIC=$(ip -4 route ls | grep default | grep -Po '(?<=dev )(\S+)' | head -1)
green "Network IP Info -----"
echo -e "${YELLOW} Current IPV4= `ifconfig $VPSSERVER_NIC | grep inet | grep netmask | grep -o -P '(?<=inet ).*(?=  netmask)'`"
echo -e "${YELLOW} Current IPV6= [`ifconfig $VPSSERVER_NIC | grep inet6 | grep global | grep -o -P '(?<=inet6 ).*(?=  prefixlen)'`]"
echo
green "Kernel BBR Info -----"
echo -e "${YELLOW} BBR Status= `sysctl -n net.ipv4.tcp_congestion_control` - `lsmod | grep bbr`" 
echo
green "Current DNS status -----"
cat /etc/resolv.conf
echo -e "${GREEN}"
}

## KERNEL
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

## SOCKS PORT
clear
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

## INTERFACE CHECK
clear
function interfaceIpCheck() {
green "Listing Interfaces"
ifconfig | grep flags | awk '{print $1}' | sed 's/:$//' | grep -Ev 'lo'
green ""
interfaceName="$(ip -4 route ls | grep default | grep -Po '(?<=dev )(\S+)' | head -1)"
read -e -i "$interfaceName" -p "Please Enter the Network Interface name to check its IP: " input
interfaceName="${input:-$interfaceName}"

curl --interface $interfaceName https://myip.wtf/json
}

## showCurrentipTABLES
function showCurrentipTABLES() {
clear
iptables-save -t nat
}

## interfaceCheckCustom
clear
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


## checkRunningPorts
function checkRunningPorts() {
clear
lsof -i -P -n | grep LIST
}

function getSystemStatus() {
clear
echo -e "${YELLOW}Current Installed Kernel= `cat /proc/version | sed 's/.(.*//'`"
echo -e "${YELLOW}Current IPV4= `ifconfig eth0 | grep inet | grep netmask | grep -o -P '(?<=inet ).*(?=  netmask)'`"
echo -e "${YELLOW}Current IPV6= [`ifconfig eth0 | grep inet6 | grep global | grep -o -P '(?<=inet6 ).*(?=  prefixlen)'`]"
}

function getBbrStatus() {
clear
green " check if bbr is running"
sysctl -n net.ipv4.tcp_congestion_control
sleep 1
lsmod | grep bbr
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

function softEtherMenu() {
if test -f "/Golden1/SoftEther/softether2023.sh";
then
bash /Golden1/SoftEther/softether2023.sh
else
mkdir -p /Golden1/SoftEther/
cd /Golden1/SoftEther/
curl -O https://raw.githubusercontent.com/ExtremeDot/GoldenOne_MENU/main/softether2023.sh
chmod +x /Golden1/SoftEther/softether2023.sh
bash /Golden1/SoftEther/softether2023.sh
fi

}

function mainMenuRun() {
#MAIN MENU SCRIPt
echo "nameserver 8.8.8.8" > /etc/resolv.conf
echo -e "${GREEN}"
yellow "=== EXTREME DOT - Multi VPN Installer MENU ============================================[Version $scriptVersion]"
blue "--- Initial Setup -----------------------------------------------------------------------------------"
echo "1) System Status & Show Status                         6) Show Busy/Used Ports by System"
echo "2) JINWYP Kernel Tuner Script                          7) Show Current IPTABLES ROUTING"
echo "3) Edit SSH config file                                8) Check Public IP by Socks5 Port's Number"
echo "4) GET BBR STATUS                                      9) Check Public IP by Interface's Name"
echo "5) All Network Interfaces                              10) Set DNS Setting Permanently"
blue "--- VPN Protocoles Menu -----------------------------------------------------------------------------"
echo "11) CloudFlare WARP+"
echo "12) WireGuard"
echo "13) OpenVPN"
echo "14) SoftEther"
echo "15) V2RAY, XRAY"
blue "--- MultiBalance Menu -------------------------------------------------------------------------------"

echo
echo "0)  EXIT                                             98) Reboot Linux      99) Update eMenu Script"
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

2) # Install JINWYP Kernel Tuner Script
jinwypScript
enter2main
;;

3) #Edit SSH config file"
green "Editing sshd Config"
nano /etc/ssh/sshd_config
green "Restarting SSH Service"
systemctl restart sshd
enter2main
;;

4) #GET BBR STATUS
getBbrStatus
enter2main
;;

5) # All Network Interfaces
clear
echo "------------------------------------------"
echo "---Network List"
ifconfig | grep flags | awk '{print $1}' | sed 's/:$//'
echo
echo "------------------------------------------"

enter2main
;;

6) # Show Busy/Used Ports by System
checkRunningPorts
enter2main
;;

7) # Show Current IPTABLES ROUTING
showCurrentipTABLES
enter2main
;;

8) #Check Public IP by Socks5 Port's Number
portCheckCustom
enter2main
;;
9) #Check Public IP by Interface's Name
interfaceCheckCustom
enter2main
;;

10)
setDNSpermanent
enter2main
;;


11)
cloudflaremenu
enter2main
;;

12)
wireGuardAngristanInstall
enter2main
;;

14)
softEtherMenu
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
