#test 

v2ray_ip=10.192.10.1
tableN=1000
v2ray_address=10.192.10.0/24
v2ray_dev=t2s_v2ray

wg_ip=10.66.66.1
wg_address=10.66.66.0/24
wg_dev=wg0

tap_ip=10.10.70.1
tap_address=10.10.70.0/24
tap_dev=tap_soft

public_dev=ens160
public_ip=[VPS]

# V2RAY CLIENT
apt install -y shadowsocks-libev iptables-persistent curl unzip
bash <(curl -L https://raw.githubusercontent.com/v2fly/fhs-install-v2ray/master/install-release.sh)
nano /usr/local/etc/v2ray/config.json
/usr/local/bin/v2ray run -config /usr/local/etc/v2ray/config.json

# RUN v2RAY as Service
systemctl enable v2ray && sleep 5
systemctl start v2ray && sleep 5

# SPEEDTEST
curl --socks5 socks5://localhost:10808 -L https://speed.hetzner.de/1GB.bin > /tmp/test.file


# INSTALLING TUNE2S
mkdir -p /tun2s && cd /tun2s
wget https://github.com/xjasonlyu/tun2socks/releases/download/v2.4.1/tun2socks-linux-amd64.zip
unzip tun2socks-linux-amd64.zip
mv tun2socks-linux-amd64 /bin/tun2socks

# RUN VIRTUAL ADAPTER
/sbin/ip tuntap add mode tun dev $v2ray_dev
/sbin/ip addr add $v2ray_ip dev $v2ray_dev
/sbin/ip link set dev $v2ray_dev up

# TUNNELING TUNE2S
tun2socks -device $v2ray_dev -proxy socks5://127.0.0.1:10808


# ROUTING

/sbin/ip route add $tap_address dev $tap_dev table $tableN

/sbin/ip route add $v2ray_address dev $v2ray_dev table $tableN
/sbin/ip route add default via $v2ray_ip dev $v2ray_dev table $tableN
/sbin/ip rule add iif $v2ray_dev lookup $tableN
/sbin/ip rule add iif $tap_dev lookup $tableN
/sbin/iptables -t nat -F 
sleep 1
/sbin/iptables -t nat -A POSTROUTING -s $tap_address -o $v2ray_dev -j MASQUERADE


sleep 2
/sbin/iptables-save -t nat


/sbin/ip rule add iif $wg_dev lookup $tableM
/sbin/iptables -t nat -A POSTROUTING -s $wg_address -o $v2ray_dev -j MASQUERADE
/sbin/ip route add $wg_address dev $wg_dev table $tableM
