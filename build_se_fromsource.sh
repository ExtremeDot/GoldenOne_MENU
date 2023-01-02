#!/bin/sh

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
                ;;
        2) # Quad9
                echo 'nameserver 9.9.9.9' > $DEST_RESOLV
                echo 'nameserver 149.112.112.112' >> $DEST_RESOLV
                ;;
        3) # Quad9 uncensored
                echo 'nameserver 9.9.9.10' > $DEST_RESOLV
                echo 'nameserver 149.112.112.10' >> $DEST_RESOLV
                ;;
        4) # FDN
                echo 'nameserver 80.67.169.40' > $DEST_RESOLV
                echo 'nameserver 80.67.169.12' >> $DEST_RESOLV
                ;;
        5) # DNS.WATCH
                echo 'nameserver 84.200.69.80' > $DEST_RESOLV
                echo 'nameserver 84.200.70.40' >> $DEST_RESOLV
                ;;
        6) # OpenDNS
                echo 'nameserver 208.67.222.222' > $DEST_RESOLV
                echo 'nameserver 208.67.220.220' >> $DEST_RESOLV
                ;;
        7) # Google
                echo 'nameserver 8.8.8.8' > $DEST_RESOLV
                echo 'nameserver 8.8.4.4' >> $DEST_RESOLV
                ;;
		8) # Yandex Basic
                echo 'nameserver 77.88.8.8' > $DEST_RESOLV
                echo 'nameserver 77.88.8.1' >> $DEST_RESOLV
                ;;
        9) # AdGuard DNS
                echo 'nameserver 94.140.14.14' > $DEST_RESOLV
                echo 'nameserver 94.140.15.15' >> $DEST_RESOLV
                ;;
        10) # NextDNS
                echo 'nameserver 45.90.28.167' > $DEST_RESOLV
                echo 'nameserver 45.90.30.167' >> $DEST_RESOLV
                ;;
        11) # Custom DNS
                echo "nameserver $DNS1" > $DEST_RESOLV
                if [[ $DNS2 != "" ]]; then
                        echo "nameserver $DNS2" >> $DEST_RESOLV
                fi
                ;;
        esac
        
        

# installing dnsmasq

systemctl stop systemd-resolved && sleep 1
sudo apt-get -y install dnsmasq
sleep 1
service dnsmasq restart
sleep 5

sudo apt-get -y install build-essential net-tools cmake gcc g++ make rpm pkg-config libncurses5-dev libssl-dev libsodium-dev libreadline-dev zlib1g-dev

mkdir /se_install && cd /se_install

# clone softether source
git clone https://github.com/SoftEtherVPN/SoftEtherVPN.git
cd SoftEtherVPN
git submodule init && git submodule update
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

mkdir -p /var/lock/subsys
chmod 755 /etc/init.d/vpnserver && /etc/init.d/vpnserver start
update-rc.d vpnserver defaults




echo "vpnserver start"
echo "vpncmd"

cat <<EOF > /etc/dnsmasq.conf
interface=tap_soft
dhcp-range=tap_soft,10.100.10.128,10.100.10.254,12h
dhcp-option=tap_soft,3,10.100.10.1
dhcp-option=option:dns-server,10.100.10.1,1.1.1.1
bind-interfaces
no-poll
no-resolv
bogus-priv
server=1.1.1.1
server=1.0.0.1

EOF
sleep 2
service dnsmasq restart
