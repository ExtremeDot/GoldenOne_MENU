#!/bin/bash

# Reference and credits:
# - https://github.com/angristan/openvpn-install
# - https://www.digitalocean.com/community/tutorials/how-to-setup-a-multi-protocol-vpn-server-using-softether
# - https://gist.github.com/abegodong/


function isRoot() {
        if [ "$EUID" -ne 0 ]; then
                return 1
        fi
}

if ! isRoot; then
        echo "Sorry, you need to run this as root"
        exit 1
fi

sleep 2 && clear

SERVER_IP=$(ip -4 addr | sed -ne 's|^.* inet \([^/]*\)/.* scope global.*$|\1|p' | head -1)
if [[ -z $SERVER_IP ]]; then
# Detect public IPv6 address
SERVER_IP=$(ip -6 addr | sed -ne 's|^.* inet6 \([^/]*\)/.* scope global.*$|\1|p' | head -1)
fi
APPROVE_IP=${APPROVE_IP:-n}
if [[ $APPROVE_IP =~ n ]]; then
read -rp "IP address: " -e -i "$SERVER_IP" IP
fi
	

USER=`echo -e $(openssl rand -hex 1)"admin"$(openssl rand -hex 4)`
read -e -i "$USER" -p "Please enter your username: " input
USER="${input:-$USER}"
echo ""
SERVER_PASSWORD=`echo -e $(openssl rand -hex 1)"PAsS"$(openssl rand -hex 4)`
read -e -i "$SERVER_PASSWORD" -p "Please Set VPN Password: " input
SERVER_PASSWORD="${input:-$SERVER_PASSWORD}"
echo ""
SHARED_KEY=`shuf -i 12345678-99999999 -n 1`
read -e -i "$SHARED_KEY" -p "Set IPSec Shared Keys: " input
SHARED_KEY="${input:-$SHARED_KEY}"
clear
echo "IP: $SERVER_IP"
echo "USER: $USER"
echo "PASSWORD: $SERVER_PASSWORD"
echo "IP_SEC: $SHARED_KEY"





# CHANGING DNS
echo " CURRNET DNS LIST"
if grep -q "127.0.0.53" "/etc/resolv.conf"; then
                        RESOLVCONF='/run/systemd/resolve/resolv.conf'
                else
                        RESOLVCONF='/etc/resolv.conf'
fi


echo "`sed -ne 's/^nameserver[[:space:]]\+\([^[:space:]]\+\).*$/\1/p' $RESOLVCONF`"
echo ""
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
        echo "   11) Custom"
        until [[ $DNS =~ ^[0-9]+$ ]] && [ "$DNS" -ge 1 ] && [ "$DNS" -le 11 ]; do
                read -rp "DNS [1-10]: " -e -i 9 DNS
                
                if [[ $DNS == "11" ]]; then
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
		
        # DNS resolvers
		DEST_RESOLV=$RESOLVCONF
        case $DNS in
        
        1) # Cloudflare
                echo 'nameserver 1.0.0.1' > $DEST_RESOLV
                echo 'nameserver 1.1.1.1' >> $DEST_RESOLV
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
        11) # Custom DNS
                echo "nameserver $DNS1" > $DEST_RESOLV
		DNSMSQ_SERV=$DNS1
		DNSMSQ_SERV2=8.8.8.8
                if [[ $DNS2 != "" ]]; then
                        echo "nameserver $DNS2" >> $DEST_RESOLV
			DNSMSQ_SERV2=$DNS2
                fi
                ;;
        esac
        
        

# installing dnsmasq

systemctl stop systemd-resolved && sleep 1
sudo apt-get -y install dnsmasq
sleep 1
service dnsmasq restart
sleep 5

echo " INSTALLING PRE-REQ APPS"
sudo apt-get -y install build-essential net-tools cmake gcc g++ make rpm pkg-config libncurses5-dev libssl-dev libsodium-dev libreadline-dev zlib1g-dev

mkdir /se_install && cd /se_install

# clone softether source
echo " GET THE SOURCE"
git clone https://github.com/SoftEtherVPN/SoftEtherVPN.git
cd SoftEtherVPN
git submodule init && git submodule update
echo " BUILD THE SOURCE"
./configure
sleep 2
make -C build
sleep 5
# make -C build install


cd /se_install/SoftEtherVPN/build
make
mkdir -p /usr/local/vpnserver/
cp vpn* /usr/local/vpnserver
cp libcedar.so libmayaqua.so hamcore.se2 /usr/local/vpnserver/
cd /usr/local/vpnserver/
chmod 600 *
chmod 700 vpnserver
chmod 700 vpncmd

# SOFTETHER SETUP
echo "Setup SoftEther Server"
HUB="VPN"
HUB_PASSWORD=${SERVER_PASSWORD}
USER_PASSWORD=${SERVER_PASSWORD}
TARGET="/usr/local/"
cd ${TARGET}vpnserver

# INSTALLATION METHOD dnsmasq or securenat?
SETMOD=""
clear
echo ""
echo "Softether Installation Method?"
echo "   1) Default, i will setup from SoftEther Manager Program"
echo "   2) Local Bridge Mode using virtual tap by dnsmasq"
until [[ $SETMOD =~ ^[0-2]+$ ]] && [ "$SETMOD" -ge 2 ] && [ "$SETMOD" -le 2 ]; do
read -rp "SETMOD [1-2]: " -e -i 2 SETMOD

if [[ $SETMOD == "1" ]]; then
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
echo "vpnserver is configured as defualt"


### SET AS LOCAL BRIDGE MODE

elif [[ $SETMOD == "2" ]]; then
LOCALIP=10.10.9
echo "please enter the main ip address for virtual tap adapter"
echo "enter the ip range [x.x.x] , the 4th number will generate automatically."
echo "the result for [10.10.9] will be 10.10.9.[1-255] range."
read -e -i "$LOCALIP" -p "Please enter IP gateway for virtual tap, example[10.10.9]: " input
LOCALIP="${input:-$LOCALIP}"

# UPDATE vpnserver running mode to local bridge

cat <<EOF > /etc/init.d/vpnserver
#!/bin/sh
# chkconfig: 2345 99 01
# description: SoftEther VPN Server
DAEMON=/usr/local/vpnserver/vpnserver
LOCK=/var/lock/subsys/vpnserver
TAP_ADDR=$LOCALIP.1
TAP_NETWORK=$LOCALIP.0/24
SERVER_IP=$SERVER_IP
test -x \$DAEMON || exit 0
case "\$1" in
start)
\$DAEMON start
touch \$LOCK
sleep 2
/sbin/ifconfig tap_soft \$TAP_ADDR
iptables -t nat -F
iptables -t nat -A POSTROUTING -s \${TAP_NETWORK} -j SNAT --to-source \${SERVER_IP}
;;
stop)
\$DAEMON stop
rm \$LOCK
;;
restart)
\$DAEMON stop
sleep 3
\$DAEMON start
sleep 2
/sbin/ifconfig tap_soft \$TAP_ADDR
iptables -t nat -F
iptables -t nat -A POSTROUTING -s \${TAP_NETWORK} -j SNAT --to-source \${SERVER_IP}
;;
*)
echo "Usage: \$0 {start|stop|restart}"
exit 1
esac
exit 0

EOF
echo "vpnserver is configured with dnsmasq"

# DEFINE DHCP SERVER RANGE FOR DNSMASQ
IPRNG1=""
until [[ $IPRNG1 =~ ^((25[0-4]|2[0-4][0-9]|[01]?[0-9][0-9]?)){0}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$ && $IPRNG1 -gt 2 && $IPRNG1 -lt 201 ]] ; do
echo ""
echo "Define a number between 3-200 ."
read -rp "DHCP START IP: [Recommended = 10] " -e IPRNG1
done
IPRNG2=""
until [[ $IPRNG2 =~ ^((25[0-4]|2[0-4][0-9]|[01]?[0-9][0-9]?)){0}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$ && $IPRNG2 -gt $IPRNG1 ]] ; do
echo ""
echo "DHCP START IP RANGE= $IPRNG1"
END_IP_REC=$((30 + $IPRNG1))
if [ $END_IP_REC -gt 254 ]
then
END_IP_REC=254
fi
echo "Define +30 number from DHCP Start value at least."
echo "It relates to how much clients will connect to your server."
read -rp "DHCP END IP: [Recommended = $END_IP_REC ~ 254 ] " -e IPRNG2
done
sleep 5

cat <<EOF > /etc/dnsmasq.conf
interface=tap_soft
dhcp-range=tap_soft,$LOCALIP.$IPRNG1,10.100.10.$IPRNG2,12h
dhcp-option=tap_soft,3,$LOCALIP.1
dhcp-option=option:dns-server,$LOCALIP.$DNSMSQ_SERV
bind-interfaces
no-poll
no-resolv
bogus-priv
server=DNSMSQ_SERV
server=DNSMSQ_SERV2

EOF

sleep 2
echo ""

## FOR WRONG INPUT
else
echo "vpnserver file is not configured and exit"
exit
fi
done


mkdir -p /var/lock/subsys
chmod 755 /etc/init.d/vpnserver && /etc/init.d/vpnserver start
update-rc.d vpnserver defaults

## SETTING UP SERVER
${TARGET}vpnserver/vpncmd localhost /SERVER /CMD ServerPasswordSet ${SERVER_PASSWORD}
${TARGET}vpnserver/vpncmd localhost /SERVER /PASSWORD:${SERVER_PASSWORD} /CMD HubCreate ${HUB} /PASSWORD:${HUB_PASSWORD}
${TARGET}vpnserver/vpncmd localhost /SERVER /PASSWORD:${SERVER_PASSWORD} /HUB:${HUB} /CMD UserCreate ${USER} /GROUP:none /REALNAME:none /NOTE:none
${TARGET}vpnserver/vpncmd localhost /SERVER /PASSWORD:${SERVER_PASSWORD} /HUB:${HUB} /CMD UserPasswordSet ${USER} /PASSWORD:${USER_PASSWORD}
${TARGET}vpnserver/vpncmd localhost /SERVER /PASSWORD:${SERVER_PASSWORD} /CMD IPsecEnable /L2TP:yes /L2TPRAW:yes /ETHERIP:yes /PSK:${SHARED_KEY} /DEFAULTHUB:${HUB}
${TARGET}vpnserver/vpncmd localhost /SERVER /PASSWORD:${SERVER_PASSWORD} /CMD BridgeCreate ${HUB} /DEVICE:soft /TAP:yes

echo " restarting DNSMASQ"
sleep 5
service dnsmasq restart
service vpnserver restart
echo "+++ Installation finished +++"
echo "IP: $SERVER_IP"
echo "USER: $USER"
echo "PASSWORD: $SERVER_PASSWORD"
echo "IP_SEC: $SHARED_KEY"

