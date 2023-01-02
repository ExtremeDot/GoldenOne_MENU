#!/bin/bash
# Softether VPN Bridge with dnsmasq for Ubuntu
# References:and credits
# - https://gist.github.com/AyushSachdev/edc23605438f1cccdd50
# - https://www.digitalocean.com/community/articles/how-to-setup-a-multi-protocol-vpn-server-using-softether
# - http://blog.lincoln.hk/blog/2013/05/17/softether-on-vps-using-local-bridge/
# - https://gist.github.com/abegodong/ # Original Script

#disabling linux firewall
sudo ufw disable

# changing DNS to google
echo "nameserver 8.8.8.8" > /etc/resolv.conf

# restarting resolv service to change effects
systemctl restart systemd-resolved && sleep 2

# updating the machine
apt-get update && apt-get -qq upgrade

# installing pre-required
apt-get -y install wget build-essential net-tools openssl

sleep 2 && clear

echo "ALL available IPs"
echo ""
ifconfig  | grep inet | awk -F' ' '{print $2}'
echo ""
SERVER_IP=`ip r | grep default | awk -F' ' '{prinifc	t $9}'`
read -e -i "$SERVER_IP" -p "Please enter your VPS IP: " input
SERVER_IP="${input:-$SERVER_IP}"
echo ""

USER=USER=`echo -e $(openssl rand -hex 1)"admin"$(openssl rand -hex 4)`
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


echo ""
echo "+++ Now sit back and wait until the installation finished +++"
HUB="VPN"
HUB_PASSWORD=${SERVER_PASSWORD}
USER_PASSWORD=${SERVER_PASSWORD}
TARGET="/usr/local/"

echo "installing dnsmasq, wait for 15 seconds"
systemctl stop systemd-resolved && sleep 10
apt-get -y install wget dnsmasq expect && sleep 2
systemctl restart systemd-resolved && sleep 10

# download the latest stable softether files
wget https://github.com/SoftEtherVPN/SoftEtherVPN/releases/download/5.02.5180/SoftEtherVPN-5.02.5180.tar.xz

# extract it 
tar xzvf SoftEtherVPN-5.02.5180.tar.xz -C $TARGET
rm -rf SoftEtherVPN-5.02.5180.tar.xz

cd ${TARGET}vpnserver
expect -c 'spawn make; expect number:; send 1\r; expect number:; send 1\r; expect number:; send 1\r; interact'
find ${TARGET}vpnserver -type f -print0 | xargs -0 chmod 600
chmod 700 ${TARGET}vpnserver/vpnserver ${TARGET}vpnserver/vpncmd
mkdir -p /var/lock/subsys
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.d/ipv4_forwarding.conf
sysctl --system
curl -O https://github.com/ExtremeDot/golden_one/blob/main/vpnserver_v5.sh --output /tmp/
mv /tmp/vpnserver_v5.sh /etc/init.d/vpnserver
sed -i "s/\[SERVER_IP\]/${SERVER_IP}/g" /etc/init.d/vpnserver
chmod 755 /etc/init.d/vpnserver && /etc/init.d/vpnserver start
update-rc.d vpnserver defaults
${TARGET}vpnserver/vpncmd localhost /SERVER /CMD ServerPasswordSet ${SERVER_PASSWORD}
${TARGET}vpnserver/vpncmd localhost /SERVER /PASSWORD:${SERVER_PASSWORD} /CMD HubCreate ${HUB} /PASSWORD:${HUB_PASSWORD}
${TARGET}vpnserver/vpncmd localhost /SERVER /PASSWORD:${SERVER_PASSWORD} /HUB:${HUB} /CMD UserCreate ${USER} /GROUP:none /REALNAME:none /NOTE:none
${TARGET}vpnserver/vpncmd localhost /SERVER /PASSWORD:${SERVER_PASSWORD} /HUB:${HUB} /CMD UserPasswordSet ${USER} /PASSWORD:${USER_PASSWORD}
${TARGET}vpnserver/vpncmd localhost /SERVER /PASSWORD:${SERVER_PASSWORD} /CMD IPsecEnable /L2TP:yes /L2TPRAW:yes /ETHERIP:yes /PSK:${SHARED_KEY} /DEFAULTHUB:${HUB}
${TARGET}vpnserver/vpncmd localhost /SERVER /PASSWORD:${SERVER_PASSWORD} /CMD BridgeCreate ${HUB} /DEVICE:soft /TAP:yes

cat <<EOF >> /etc/dnsmasq.conf
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
service dnsmasq restart
service vpnserver restart
echo "+++ Installation finished +++"
echo "IP: $SERVER_IP"
echo "USER: $USER"
echo "PASSWORD: $SERVER_PASSWORD"
echo "IP_SEC: $SHARED_KEY"
