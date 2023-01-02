#!/bin/sh

function isRoot() {
        if [ "$EUID" -ne 0 ]; then
                return 1
        fi
}

if ! isRoot; then
        echo "Sorry, you need to run this as root"
        exit 1
fi


# change DNS to adguard service
cat << EOF > /etc/resolv.conf
nameserver 94.140.14.14
nameserver 94.140.14.15
EOF

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
