#!/bin/bash
echo " Version 1.2"
echo "STRUCTURE: [INCOMING] will route to [DESTINATION]"
echo "[INCOMING] could be running OpenVPN , WireGuard or SoftEther Server is running on this machine!"
echo ""
echo "Available Interfaces to select for [INCOMING] "
echo ""
#echo $INT_LIST
ifconfig | grep flags | awk '{print $1}' | sed 's/:$//' | grep -Ev 'lo'
echo " "
echo " "
SERVER_NIC="$(ip -4 route ls | grep default | grep -Po '(?<=dev )(\S+)' | head -1)"
        until [[ ${INPUT_NIC} =~ ^[a-zA-Z0-9_-]+$ ]]; do
                read -rp "[INCOMING]: Enter interface name: " -e -i "${SERVER_NIC}" INPUT_NIC
        done
echo ""
echo ""

echo "[DESTINATION] , it could be running Clinet on This machine, like v2ray, sstp or any running client on this machine"
echo ""
echo "Available Interfaces to select for [DESTINATION] "
echo ""
ifconfig | grep flags | awk '{print $1}' | sed 's/:$//' | grep -Ev 'lo' | grep -Ev $INPUT_NIC
echo " "
echo " "
SERVER_NIC2="$(ip -4 route ls | grep default | grep -Po '(?<=dev )(\S+)' | grep -Ev $INPUT_NIC | head -1)"
        until [[ ${OUTPUT_NIC} =~ ^[a-zA-Z0-9_-]+$ ]]; do
                read -rp "[DESTINATION]: Enter interface name: " -e -i "${SERVER_NIC2}" OUTPUT_NIC
        done
clear
echo " "
DEF_TABLE=1000
read -e -i "$DEF_TABLE" -p "Enter the Value for Routing Table: " input
DEF_TABLE="${input:-$DEF_TABLE}"

echo "Selected Interfaces"
echo ""
# INCOMING INTERFACE
echo "[INCOMING]        : $INPUT_NIC"
INPUT_IP=$(ip -4 addr | grep $INPUT_NIC |sed -ne 's|^.* inet \([^/]*\)/.* scope global.*$|\1|p' | awk '{print $1}' | head -1)
INPUT_BASE_ADDRESS0=$(echo "${INPUT_IP}" | cut -d"." -f1-3)".0"
INPUT_BASE_ADDRESS=$(echo "${INPUT_BASE_ADDRESS0}/24")


# DESTINATION INTERFACE
echo "[DESTINATION]     : $OUTPUT_NIC"
OUTPUT_IP=$(ip -4 addr | grep $OUTPUT_NIC |sed -ne 's|^.* inet \([^/]*\)/.* scope global.*$|\1|p' | awk '{print $1}' | head -1)
OUTPUT_BASE_ADDRESS0=$(echo "${OUTPUT_IP}" | cut -d"." -f1-3)".0"
OUTPUT_BASE_ADDRESS=$(echo "${OUTPUT_BASE_ADDRESS0}/24")

# ROUTING TO CUSTOM TABLE
/sbin/ip route add $INPUT_BASE_ADDRESS dev $INPUT_NIC table $DEF_TABLE
sleep 2
/sbin/ip route add $OUTPUT_BASE_ADDRESS dev $OUTPUT_NIC table $DEF_TABLE
sleep 2
/sbin/ip route add default via $OUTPUT_IP dev $OUTPUT_NIC table $DEF_TABLE
sleep 2
/sbin/ip rule add iif $INPUT_NIC lookup $DEF_TABLE
sleep 2
/sbin/ip rule add iif $OUTPUT_NIC lookup $DEF_TABLE
sleep 2

# FLUSHING IP FORWARDING
/sbin/iptables -t nat -F
sleep 2
/sbin/iptables -t nat -A POSTROUTING -s $INPUT_BASE_ADDRESS -o $OUTPUT_NIC -j MASQUERADE
sleep 2
/sbin/iptables-save -t nat
/usr/sbin/iptables

touch /Golden1/route_$DEF_TABLE.sh
cat <<EOF > /Golden1/route_$DEF_TABLE.sh
#!/bin/bash
# ROUTING TO CUSTOM TABLE

IPBIN=/sbin/ip
IPTABLESBIN=/usr/sbin/iptables
IPTABLESAVEBIN=/usr/sbin/iptables-save

\$IPBIN route add $INPUT_BASE_ADDRESS dev $INPUT_NIC table $DEF_TABLE
\$IPBIN route add $OUTPUT_BASE_ADDRESS dev $OUTPUT_NIC table $DEF_TABLE
\$IPBIN route add default via $OUTPUT_IP dev $OUTPUT_NIC table $DEF_TABLE
\$IPBIN rule add iif $INPUT_NIC lookup $DEF_TABLE
\$IPBIN rule add iif $OUTPUT_NIC lookup $DEF_TABLE

# FLUSHING IP FORWARDING
\$IPTABLESBIN s -t nat -F
sleep 2
\$IPTABLESBIN -t nat -A POSTROUTING -s $INPUT_BASE_ADDRESS -o $OUTPUT_NIC -j MASQUERADE
sleep 2
\$IPTABLESAVEBIN -t nat

EOF

echo " The Routing Structure has saved on /Golden1/route_$DEF_TABLE.sh"
