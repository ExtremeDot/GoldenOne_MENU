#!/bin/sh
# installing dnsmasq
systemctl stop systemd-resolved && sleep 5
sudo apt install dnsmasq
sleep 5
service dnsmasq restart
sleep 5

mkdir /se_install && cd /se_install
sudo apt -y install build-essential net-tools cmake gcc g++ make rpm pkg-config libncurses5-dev libssl-dev libsodium-dev libreadline-dev zlib1g-dev

# clone softether source
git clone https://github.com/SoftEtherVPN/SoftEtherVPN.git
cd SoftEtherVPN
git submodule init && git submodule update
./configure
sleep 2
make -C build
sleep 5
make -C build install

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
