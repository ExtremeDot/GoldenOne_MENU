#!/bin/sh
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
