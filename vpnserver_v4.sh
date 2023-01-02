#!/bin/sh
# chkconfig: 2345 99 01
# description: SoftEther VPN Server
DAEMON=/usr/local/vpnserver/vpnserver
LOCK=/var/lock/subsys/vpnserver
TAP_ADDR=10.90.10.1
TAP_NETWORK=10.90.10.0/24
SERVER_IP=[SERVER_IP]
test -x $DAEMON || exit 0
case "$1" in
start)
$DAEMON start
touch $LOCK
sleep 1
/sbin/ifconfig tap_soft $TAP_ADDR
iptables -t nat -F
iptables -t nat -A POSTROUTING -s ${TAP_NETWORK} -j SNAT --to-source ${SERVER_IP}
;;
stop)
$DAEMON stop
rm $LOCK
;;
restart)
$DAEMON stop
sleep 3
$DAEMON start
sleep 1
/sbin/ifconfig tap_soft $TAP_ADDR
iptables -t nat -F
iptables -t nat -A POSTROUTING -s ${TAP_NETWORK} -j SNAT --to-source ${SERVER_IP}
;;
*)
echo "Usage: $0 {start|stop|restart}"
exit 1
esac
exit 0
