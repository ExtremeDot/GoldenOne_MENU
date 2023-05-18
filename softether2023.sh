#!/bin/bash

# Define version info
SCRIPT_NAME="Softether VPN Server Installer Script By ExtremeDot"
SCRIPT_VERSION="1.22"
SECUREMODESTAT=0
clear
# Define color sets for different types of messages
RED='\033[0;31m'
YELLOW='\033[0;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color
vpnServerPathFile=/etc/init.d/vpnserver
function color_echo() {
    COLOR=$1
    shift
    echo -e "${COLOR}$@${NC}"
}

# Function to display a progress bar with time remaining and a custom message
function time_remaining_progress_bar() {
  local duration=$1
  local message=$2
  local elapsed=0
  local width=50
  echo
  echo -e "${YELLOW}$message${NC}"

  while [ $elapsed -le $duration ]; do
    local progress=$((elapsed * 100 / duration))
    local completed=$((elapsed * width / duration))
    local remaining=$((width - completed))

    # Build the progress bar string
    local fill=""
    local empty=""
    for ((i = 0; i < completed; i++)); do
      fill="${fill}#"
    done

    for ((i = 0; i < remaining; i++)); do
      empty="${empty}-"
    done

    # Calculate time remaining
    local time_remaining=$((duration - elapsed))
	
    # Print the colored progress bar, progress percentage, custom message, and time remaining on the same line
    printf "\r[${fill}${empty}] \e[32m%d%%\e[0m - %s: \e[33m%ds\e[0m" "$progress" " " "$time_remaining"

    # Increment elapsed time
    sleep 1
    elapsed=$((elapsed + 1))
  done

  # Print finished message on a new line
  printf "\nFinished\n"
}

# Function 01: Check if script is running as root
function 01_isRoot() {
    if [ "$EUID" -ne 0 ]; then
        return 1
    fi
}

# Function 02: Set target directory and create it if it does not exist
function 02_setTarget() {
    TARGET="/usr/local/"
    DOWNLOAD_FOLDER="/Golden1/SoftEther/"

    if [ ! -d "$TARGET" ]; then
        echo -e "${YELLOW}Target directory does not exist, creating it...${NC}"
        mkdir -p $TARGET
        echo -e "${GREEN}Target directory created.${NC}"
    fi
    
    if [ ! -d "$DOWNLOAD_FOLDER" ]; then
        echo -e "${YELLOW} SoftEthe directory does not exist, creating it...${NC}"
        mkdir -p $DOWNLOAD_FOLDER
        echo -e "${GREEN} SoftEther directory created.${NC}"
    fi
}

# Function 03: Clean SoftEther installation
function 03_cleanInstall() {
    read -p "Do you want to remove previous SoftEther VPN Server configurations? (y/n) " choice
    case "$choice" in 
        y|Y )
            echo -e "${YELLOW}Removing previous SoftEther VPN Server configurations...${NC}"
	    systemctl daemon-reload
	    sleep 2
	    systemctl stop vpnserver.service
	    sleep 2
            /etc/init.d/vpnserver stop >/dev/null 2>&1
            rm -rf /usr/local/vpnserver/ >/dev/null 2>&1
            rm -f /etc/init.d/vpnserver >/dev/null 2>&1
            rm -f /etc/systemd/system/vpnserver.service >/dev/null 2>&1
            echo -e "${GREEN}Previous SoftEther VPN Server configurations removed.${NC}"
            ;;
        n|N )
            echo -e "${YELLOW}Skipping removal of previous SoftEther VPN Server configurations.${NC}"
            ;;
        * )
            echo -e "${RED}Invalid input. Exiting.${NC}"
            exit 1
            ;;
    esac
}

# Function 04: Check and install prerequisite apps
function 04_checkPrereq() {
    echo -e "${YELLOW}Checking and installing prerequisite apps...${NC}"
    apt install --fix-broken
    apt-get update
    apt-get -y upgrade
    apt-get -y install build-essential
    apt-get -y install net-tools
    apt-get -y install cmake gcc g++ make rpm pkg-config libncurses5-dev libssl-dev libsodium-dev libreadline-dev zlib1g-dev
    apt-get -y install expect && sleep 2
    echo -e "${GREEN}Prerequisite apps installed.${NC}"
}

# Function 05: Ask for default values
function 05_askDefaults() {
clear
echo "========================================================="
echo "Initial Setup Data "
echo
    SERVER_IP=$(ip -4 addr | sed -ne 's|^.* inet \([^/]*\)/.* scope global.*$|\1|p' | head -1)
    if [[ -z $SERVER_IP ]]; then
        # Detect public IPv6 address
        SERVER_IP=$(ip -6 addr | sed -ne 's|^.* inet6 \([^/]*\)/.* scope global.*$|\1|p' | head -1)
    fi

    read -rp "IP address: " -e -i "$SERVER_IP" IP
    SERVER_IP="${IP:-$SERVER_IP}"
    echo "--------- "

    USER=$(echo -e $(openssl rand -hex 1)"admin"$(openssl rand -hex 4))
    read -e -i "$USER" -p "Please enter your username: " input
    USER="${input:-$USER}"
    echo "--------- "

    SERVER_PASSWORD=$(echo -e $(openssl rand -hex 1)"PAsS"$(openssl rand -hex 4))
    read -e -i "$SERVER_PASSWORD" -p "Please Set VPN Password: " input
    SERVER_PASSWORD="${input:-$SERVER_PASSWORD}"
    echo "--------- "

    SHARED_KEY=$(shuf -i 12345678-99999999 -n 1)
    read -e -i "$SHARED_KEY" -p "Set IPSec Shared Keys: " input
    SHARED_KEY="${input:-$SHARED_KEY}"
    echo "========================================================="
    echo "DNSMASQ ---------"
#    clear
#    echo -e "${BLUE}Default values:${NC}"
#    echo "IP: $SERVER_IP"
#    echo "USER: $USER"
#    echo "PASSWORD: $SERVER_PASSWORD"
#    echo "IP_SEC: $SHARED_KEY"
#    sleep 2
}

function 06_dnsmasqInstall() {
    # Install dnsmasq
    echo "Installing dnsmasq..."
    sudo apt-get update > /dev/null 2>&1
    sudo apt-get -y install dnsmasq > /dev/null 2>&1

    # Configure dnsmasq
    echo "Configuring dnsmasq..."
    sudo bash -c 'echo "port=5353" >> /etc/dnsmasq.conf'

    # Restart dnsmasq
    echo "Restarting dnsmasq..."
    sudo systemctl restart dnsmasq > /dev/null 2>&1

    echo "dnsmasq installation and configuration complete."
}




function 07_SoftEtherVPN_Installer() {
    DOWNLOAD_FOLDER="/Golden1/SoftEther/"
    echo
    color_echo $BLUE "========================================================================"
    color_echo $YELLOW "Always check the GitHUB or Official Site for latest releases"
    color_echo $BLUE "GITHUB:           https://github.com/SoftEtherVPN/SoftEtherVPN_Stable"
    color_echo $BLUE "OFFICIAL Site:    https://www.softether-download.com/en.aspx"
    color_echo $BLUE ""

    while true; do
        color_echo $GREEN "Select the SoftEther VPN server download link:"
	echo
        color_echo $YELLOW "1. Use v4.41-9787-beta version (Release Date: 2023-03-14)"
        color_echo $YELLOW "2. Use custom version"
        color_echo $RED "3. Exit"
        color_echo $GREEN " "
        read -p "Enter your choice [1, 2 or 3]: " choice

        case $choice in
             1)
                DLLINK="https://www.softether-download.com/files/softether/v4.41-9787-rtm-2023.03.14-tree/Linux/SoftEther_VPN_Server/64bit_-_Intel_x64_or_AMD64/softether-vpnserver-v4.41-9787-rtm-2023.03.14-linux-x64-64bit.tar.gz"
                break
                ;;
             2)
                color_echo $YELLOW "Enter 0 or Hit Enter with empty value to back previuos Menu!"
				read -p "Enter the SoftEther VPN server download link: " DLLINK
                if [[ -z "$DLLINK" || "$DLLINK" == "0" ]]; then
                    color_echo $YELLOW "Returning to previous menu..."
                    continue
                else
                    color_echo $YELLOW "Custom download link set to: $DLLINK"
                    #continue
		    break
                fi
                ;;
             3)
                color_echo $YELLOW "Exiting..."
                exit 0
                ;;
             *)
                color_echo $RED "Invalid choice, please try again."
                continue
                ;;
        esac
    done

    DLFILE="${DOWNLOAD_FOLDER}Soft.tar.gz"
    echo "remove previous data if exsits"
    if [ -f "$DLFILE" ];
    then
    rm -f $DLFILE
    fi

    # Download SoftEther installation files
    color_echo $GREEN "Downloading SoftEther installation files..."
    curl -L $DLLINK --output $DLFILE
    sleep 2

    # Check if installation files are downloaded
    if [ -f "$DLFILE" ];
    then
        color_echo $GREEN "Installation files are downloaded."
        tar xzvf $DLFILE -C $TARGET
        sleep 2
        rm -rf $DOWNLOAD_FOLDER/softether-vpnserver-v*
        sleep 2
    else
        color_echo $RED "Installation files are not downloaded, EXIT "
        color_echo $RED "Check network and source files and retry again."
		# Call the function with a duration of 10 seconds and a custom message
		time_remaining_progress_bar 10 "Failed to download files, exit."
        exit 0
    fi
    sleep 5
    EXTRACT_FLDR="/usr/local/vpnserver"
    FILESVPNR=("hamcore.se2" "Makefile" ".install.sh" )
    FOUND_ALL_FILES=false
    
    while [ "$FOUND_ALL_FILES" = false ]
    do
    	MISSING_FILES=()
	for file in "${FILESVPNR[@]}"
	do
		if [ ! -f "$EXTRACT_FLDR/$file" ]; then
			MISSING_FILES+=("$file")
		fi
	done
	
    if [ ${#MISSING_FILES[@]} -eq 0 ]; then
        FOUND_ALL_FILES=true
        echo "All files are available in $EXTRACT_FLDR"
    else
    	echo "Error: The following files are missing in $EXTRACT_FLDR: ${MISSING_FILES[*]}"
	time_remaining_progress_bar 10 "Waiting to Extracting file get finished..."
    fi
    done
    # Install SoftEther
    color_echo $BLUE "Installing SoftEther..."
    HUB="VPN"
    HUB_PASSWORD=${SERVER_PASSWORD}
    USER_PASSWORD=${SERVER_PASSWORD}
    cd ${TARGET}vpnserver
    expect -c 'spawn make; expect number:; send 1\r; expect number:; send 1\r; expect number:; send 1\r; interact'
    find ${TARGET}vpnserver -type f -print0 | xargs -0 chmod 600
    chmod 700 ${TARGET}vpnserver/vpnserver ${TARGET}vpnserver/vpncmd
    mkdir -p /var/lock/subsys

    color_echo $GREEN "SoftEther installation complete."
}

# Function to prompt user to select DNS resolvers
function 08_selectDNS() {

# Save current DNS resolv config
echo " CURRNET DNS LIST"
if grep -q "127.0.0.53" "/etc/resolv.conf"; then
                        RESOLVCONF='/run/systemd/resolve/resolv.conf'
                else
                        RESOLVCONF='/etc/resolv.conf'
fi
color_echo $YELLOW "Current DNS is set to:  $RESOLVCONF"

  # Prompt user to select DNS resolvers
  echo 
  echo "What DNS resolvers do you want to use with the SoftEther VPN Server?"
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
    read -rp "DNS [1-12]: " -e -i 1 DNS

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

  # Set DNS resolvers
  case $DNS in
    1) # Cloudflare
      DNSMSQ_SERV=1.1.1.1
      DNSMSQ_SERV2=1.0.0.1
      ;;
    2) # Quad9
      DNSMSQ_SERV=9.9.9.9
      DNSMSQ_SERV2=149.112.112.112
      ;;
    3) # Quad9 uncensored
      DNSMSQ_SERV=9.9.9.10
      DNSMSQ_SERV2=149.112.112.10
      ;;
    4) # FDN
      DNSMSQ_SERV=80.67.169.40
      DNSMSQ_SERV2=80.67.169.12
      ;;
    5) # DNS.WATCH
      DNSMSQ_SERV=84.200.69.80
      DNSMSQ_SERV2=84.200.70.40
      ;;
    6) # OpenDNS
      DNSMSQ_SERV=208.67.222.222
      DNSMSQ_SERV2=208.67.220.220
      ;;
    7) # Google
      DNSMSQ_SERV=8.8.8.8
      DNSMSQ_SERV2=8.8.4.4
      ;;
    8) # Yandex Basic
      DNSMSQ_SERV=77.88.8.8
      DNSMSQ_SERV2=77.88.8.1
      ;;
    9) # AdGuard DNS
      DNSMSQ_SERV=94.140.14.14
      DNSMSQ_SERV2=94.140.15.15
      ;;
    10) # NextDNS
      DNSMSQ_SERV=45.90.28.0
      DNSMSQ_SERV2=45.90.30.0
      ;;
    11) # SKIP
      echo "No changes were made to DNS settings."
      exit
      ;;
    12) # Custom
      DNSMSQ_SERV=$DNS1
      DNSMSQ_SERV2=$DNS2
      ;;
  esac
}

# Function to set up DNS
function 09_dnsVpnApply() {
  # Get current DNS settings
  echo "`sed -ne 's/^nameserver[[:space:]]\+\([^[:space:]]\+\).*$/\1/p' $RESOLVCONF`"
  echo ""

  select_dns

  # Set DNS resolvers
  DEST_RESOLV=$RESOLVCONF
  echo "nameserver $DNSMSQ_SERV" > $DEST_RESOLV
  if [[ $DNSMSQ_SERV2 != "" ]]; then
    echo "nameserver $DNSMSQ_SERV2" >> $DEST_RESOLV
  fi

  # Restart dnsmasq
  if [ -x /etc/init.d/dnsmasq ]; then
    /etc/init.d/dnsmasq restart
  fi
}


# Function to prompt user to select SoftEther installation method
function 10_SoftEtherInstallMode() {
  SETMOD=""
  clear
  echo ""
  echo "Softether Installation Method?"
  echo "   1) SecureNAT , I will set up from SoftEther Manager Program [Not Recommended]"
  echo "   2) Local Bridge Mode using virtual tap by dnsmasq"
  until [[ $SETMOD =~ ^[0-2]+$ ]] && [ "$SETMOD" -ge 1 ] && [ "$SETMOD" -le 2 ]; do
    read -rp "SETMOD [1-2]: " -e -i 1 SETMOD
  done

  # Set SoftEther installation method
  case $SETMOD in
    1) # Default
      echo "SoftEther will be set up from the SoftEther Manager Program."
	  11_secureSoftEtherInstallMode
      ;;
    2) # Local Bridge Mode using virtual tap by dnsmasq
      echo "SoftEther will be set up in Local Bridge Mode using virtual tap by dnsmasq."
      # Call function
	  12_dnsMsqSoftEtherInstallMode
	  13_dnsmasqConfigGenerator

      ;;
  esac
}

# 11-secureSoftEtherInstallMode
function 11_secureSoftEtherInstallMode() {
SECUREMODESTAT=1
echo "Setting up SoftEther in SECURE-NAT mode..."

# Add vpnserver init script for SECURE-NAT mode
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

  # Make the init script executable
  chmod +x /etc/init.d/vpnserver

  # Start the vpnserver service
  /etc/init.d/vpnserver start

  echo "SoftEther set up in SECURE-NAT mode."
}

function 12_dnsMsqSoftEtherInstallMode() {

DNSMSQMODE=1
# Set the default value for IPTABLES_BIN
IPTABLES_BIN=/usr/sbin/iptables

# Check if the iptables binary exists
if [ -x "$IPTABLES_BIN" ]; then
    # Set the default value for IPTABLES_BIN
    IPTABLES_BIN=$IPTABLES_BIN
else
    # If the binary does not exist, print an error message and exit
	if ! command -v iptables &> /dev/null; then
    echo "iptables is not installed. Attempting to install..."
    # Install iptables
    sudo apt-get update
    sudo apt-get install -y iptables
    # Check if iptables was installed successfully
    if ! command -v iptables &> /dev/null; then
        echo "Failed to install iptables. Aborting."
        exit 1
    fi
fi
fi


# Set the default value for IP_BIN
IP_BIN=/sbin/ip

# Check if the ip binary exists
if [ -x "$IP_BIN" ]; then
    # Set the default value for IP_BIN
    IP_BIN=$IP_BIN
else
    if ! command -v $IP_BIN &> /dev/null; then
    echo "ip is not installed. Attempting to install..."
    # Install ip
    sudo apt-get update
    sudo apt-get install -y iproute2
    # Check if ip was installed successfully
    if ! command -v $IP_BIN &> /dev/null; then
        echo "Failed to install ip. Aborting."
		whereis ip
        read -p "Enter the path to the IP tool binary [/sbin/ip]: " IP_BIN_PATH
		IP_BIN_PATH=${IP_BIN_PATH:-/sbin/ip}
		IP_BIN=${IP_BIN_PATH}
    fi
fi

fi


# Ask user for input
read -p "Enter the path to the VPN server binary [/usr/local/vpnserver/vpnserver]: " VPN_SERVER_PATH
VPN_SERVER_PATH=${VPN_SERVER_PATH:-/usr/local/vpnserver/vpnserver}

read -p "Enter the path to the lock file [/var/lock/subsys/vpnserver]: " LOCK_FILE_PATH
LOCK_FILE_PATH=${LOCK_FILE_PATH:-/var/lock/subsys/vpnserver}

read -p "Enter the name of the TAP interface [tap_ext]: " TAP_INTERFACE
TAP_INTERFACE=${TAP_INTERFACE:-tap_ext}

TAP_INTERFACECMD="${TAP_INTERFACE#tap_}"

read -p "Enter the IP address range for the TAP interface [10.10.129.0/24]: " TAP_NETWORK
TAP_NETWORK=${TAP_NETWORK:-10.10.129.0/24}

read -p "Enter the gateway IP address for the TAP interface [10.10.129.1]: " TAP_GATEWAY
TAP_GATEWAY=${TAP_GATEWAY:-10.10.129.1}

read -p "Enter the static IP address for the TAP interface [10.10.129.52/24]: " TAP_STATIC
TAP_STATIC=${TAP_STATIC:-10.10.129.52/24}

function configure_multi_hop_vpn() {
  read -p "Is this a multi-hop VPN setup? [y/n]: " is_multi_hop

  if [[ $is_multi_hop == 'y' ]]; then
    read -p "How many other VPN hops do you have? " num_hops

    for ((i=1; i<=num_hops; i++)); do
      read -p "Enter a description for VPN Hop $i (e.g. WireGuard, OpenVPN): " hop_desc
      read -p "Enter the network for $hop_desc (e.g. 10.8.0.0/24): " hop_network
      eval "VPN_HOP_${i}_DESC=$hop_desc"
      eval "VPN_HOP_${i}_NETWORK=$hop_network"
      eval "${hop_desc}_NETWORK=$hop_network"
    done

    echo ""
    read -p "Enter VPN table name (default: 800): " vpn_table_name
    vpn_table_name=${vpn_table_name:-800}

    # Print all the variables with color codes
    echo ""
    color_echo $BLUE "VPN Configuration:"
    for ((i=1; i<=num_hops; i++)); do
      eval "desc=\$VPN_HOP_${i}_DESC"
      eval "network=\$VPN_HOP_${i}_NETWORK"
      eval "${desc}_NETWORK_VARNAME=${desc}_NETWORK"
      color_echo $GREEN "VPN Hop $i"
      color_echo $GREEN "VPN Name     : $desc"
      color_echo $GREEN "VPN Network  : $network"
      color_echo $GREEN "${desc}_NETWORK_VARNAME: ${desc}_NETWORK"
    done
    color_echo $GREEN "VPN Table Name: $vpn_table_name"
  else
    echo "This is not a multi-hop VPN setup."
  fi
}


# Set the VPN table number
VPN_TABLE=${vpn_table_name}


function domestic_vpnserver_file_creation() {
# Generate script file
cat > $vpnServerPathFile <<EOF
#!/bin/bash

# Set the path to the VPN server binary
DAEMON=${VPN_SERVER_PATH}

# Set the path to the lock file
LOCK_FILE=${LOCK_FILE_PATH}

# Set the path to the IP tool binary
IP_BIN=${IP_BIN}
IPTABLES_BIN=${IPTABLES_BIN}

# Set the name of the TAP interface
TAP_INTERFACE=${TAP_INTERFACE}

# Set the VPN table number
VPN_TABLE=${vpn_table_name}

# Set the IP address range for the TAP interface
TAP_NETWORK=${TAP_NETWORK}

# Set the gateway IP address for the TAP interface
TAP_GATEWAY=${TAP_GATEWAY}

# Set the static IP address for the TAP interface
TAP_STATIC=${TAP_STATIC}

# Set the Multi Hop VPN Serevrs
EOF

# Append variables for each VPN hop to the script file
if [[ $is_multi_hop == 'y' ]]; then
for ((i=1; i<=num_hops; i++)); do
eval "desc=\$VPN_HOP_${i}_DESC"
eval "network=\$VPN_HOP_${i}_NETWORK"
echo "${desc}_NETWORK=${network}" >> $vpnServerPathFile
echo "" >> $vpnServerPathFile
done
fi


cat >> $vpnServerPathFile <<EOF
# Check if the VPN server binary exists
if [ ! -x "\$DAEMON" ]; then
echo "Error: \$DAEMON not found or not executable"
exit 1
fi

case "\$1" in

# Start the VPN server and configure the network settings
start)
echo "Setting up IP tables"
\$DAEMON start
touch \$LOCK_FILE
sleep 1
\$IP_BIN addr add \$TAP_STATIC brd + dev \$TAP_INTERFACE
sleep 3
EOF

# Append variables for each VPN hop to the script file
if [[ $is_multi_hop == 'y' ]]; then
for ((i=1; i<=num_hops; i++)); do
eval "desc=\$VPN_HOP_${i}_DESC"
eval "network=\$VPN_HOP_${i}_NETWORK"
cat >> $vpnServerPathFile <<EOF
# Check if the routing rule for ${desc} already exists before adding it
if ! \$IP_BIN rule show | grep -q "from \$${desc}_NETWORK lookup \$VPN_TABLE"; then
\$IP_BIN rule add from \$${desc}_NETWORK lookup \$VPN_TABLE
fi

EOF
done
fi

cat >> $vpnServerPathFile <<EOF
sleep 1
\$IP_BIN route add default via \$TAP_GATEWAY dev \$TAP_INTERFACE proto static table \$VPN_TABLE
sleep 1
\$IPTABLES_BIN -t nat -F
sleep 1
EOF

# Append variables for each VPN hop to the script file
if [[ $is_multi_hop == 'y' ]]; then
for ((i=1; i<=num_hops; i++)); do
eval "desc=\$VPN_HOP_${i}_DESC"
eval "network=\$VPN_HOP_${i}_NETWORK"
cat >> $vpnServerPathFile <<EOF
# Multi-Hops - Routing ${desc} to Use $TAP_INTERFACE network
\$IPTABLES_BIN -t nat -A POSTROUTING -s \$${desc}_NETWORK -o \$TAP_INTERFACE -j MASQUERADE
sleep 1

EOF
done
fi

cat >> $vpnServerPathFile <<EOF
# Enable IP forwarding
echo 1 > /proc/sys/net/ipv4/ip_forward
# Add iptables rules to allow traffic through
\$IPTABLES_BIN -A FORWARD -o \$TAP_INTERFACE -j ACCEPT
\$IPTABLES_BIN -A FORWARD -i \$TAP_INTERFACE -j ACCEPT
;;

# Stop the VPN server and remove the lock file
stop)
\$DAEMON stop
rm \$LOCK_FILE
;;

# Restart the VPN server and configure the network settings
restart)
\$DAEMON stop
sleep 1
\$DAEMON start
sleep 1
#\$IP_BIN addr add \$TAP_STATIC brd + dev \$TAP_INTERFACE
;;

# Display usage information
*)
echo "Usage: \$0 {start|stop|restart}"
exit 1
esac
exit 0

EOF
}

function freeNet_vpnserver_file_creation() {
# Generate script file
cat > $vpnServerPathFile <<EOF
#!/bin/bash

# Set the path to the VPN server binary
DAEMON=${VPN_SERVER_PATH}

# Set the path to the lock file
LOCK_FILE=${LOCK_FILE_PATH}

# Set the path to the IP tool binary
IP_BIN=${IP_BIN}
IPTABLES_BIN=${IPTABLES_BIN}
IFCONFIG_BIN=/sbin/ifconfig
DNSMASQ_BIN=/etc/init.d/dnsmasq

# GET the name of the Default interface
SERVER_NIC=$(ip -4 route ls | grep default | grep -Po '(?<=dev )(\S+)' | head -1)

# Set the name of the TAP interface
TAP_INTERFACE=${TAP_INTERFACE}

# Set the IP address range for the TAP interface
TAP_NETWORK=${TAP_NETWORK}

# Set the gateway IP address for the TAP interface
TAP_GATEWAY=${TAP_GATEWAY}

# Check if the VPN server binary exists
if [ ! -x "\$DAEMON" ]; then
    echo "Error: \$DAEMON not found or not executable"
    exit 1
fi

case "\$1" in

# Start the VPN server and configure the network settings
start)
echo "Setting up IP tables"
\$DAEMON start
touch \$LOCK_FILE
sleep 3
#\$IP_BIN addr add \$TAP_GATEWAY brd + dev \$TAP_INTERFACE
\$IFCONFIG_BIN \$TAP_INTERFACE \$TAP_GATEWAY
sleep 3
\$DNSMASQ_BIN restart
sleep 1
\$IPTABLES_BIN -t nat -A POSTROUTING -s \$TAP_NETWORK -o \$SERVER_NIC -j MASQUERADE
# Enable IP forwarding
echo 1 > /proc/sys/net/ipv4/ip_forward
# Add iptables rules to allow traffic through
\$IPTABLES_BIN -A FORWARD -o \$TAP_INTERFACE -j ACCEPT
\$IPTABLES_BIN -A FORWARD -i \$TAP_INTERFACE -j ACCEPT
;;

# Stop the VPN server and remove the lock file
stop)

\$DAEMON stop
rm \$LOCK_FILE
\$IPTABLES_BIN -t nat -D POSTROUTING -s \$TAP_NETWORK -o \$SERVER_NIC -j MASQUERADE
;;

# Restart the VPN server and configure the network settings
restart)
\$DAEMON stop
\$IPTABLES_BIN -t nat -D POSTROUTING -s \$TAP_NETWORK -o \$SERVER_NIC -j MASQUERADE
sleep 1
\$DAEMON start
\$IPTABLES_BIN -t nat -A POSTROUTING -s \$TAP_NETWORK -o \$SERVER_NIC -j MASQUERADE
sleep 1
#\$IP_BIN addr add \$TAP_GATEWAY brd + dev \$TAP_INTERFACE
#\$IFCONFIG_BIN \$TAP_INTERFACE \$TAP_GATEWAY
;;

# Display usage information
*)
echo "Usage: \$0 {start|stop|restart}"
exit 1
esac
exit 0
EOF

}

function create_vpnserver_monitor_service() {
  # Create the service file
  sudo tee /etc/systemd/system/vpnserver-monitor.service > /dev/null <<EOF
[Unit]
Description=VPN Server Monitor
After=network.target

[Service]
Type=simple
ExecStart=/bin/bash -c 'while true; do if ! ping -c 1 ${TAP_GATEWAY} >/dev/null; then /etc/init.d/vpnserver stop && sleep 10 && /etc/init.d/vpnserver start; fi; sleep 300; done'
Restart=always

[Install]
WantedBy=multi-user.target
EOF

  # Reload systemd
  sudo systemctl daemon-reload

  # Enable the service
  sudo systemctl enable vpnserver-monitor.service

  # Start the service
  sudo systemctl start vpnserver-monitor.service
}


function domesticMode() {
  echo "You have chosen DOMESTIC mode. This mode is recommended if you are located in a country with limited internet access, such as Iran or China."
  configure_multi_hop_vpn
  domestic_vpnserver_file_creation
  create_vpnserver_monitor_service
  
}

function freenetMode() {
  echo "You have chosen FREENET mode. This mode is recommended if you have access to data centers with no internet access limitations, such as Hetzner, Digital Ocean, Amazon, Microsoft, and so on."
  freeNet_vpnserver_file_creation
  
}

while true; do
  echo ""
  echo "Please choose the type of your VPS install mode:"
  echo "1. DOMESTIC, Like IRAN or CHINA VPS located"
  echo "2. FREENET , International DataCenteres (e.g. Hetzner, Digital Ocean, Amazon, Azure)"
  read -p "Enter your choice [1-2]: " choice

  case $choice in
    1)
      domesticMode
      break
      ;;
    2)
      freenetMode
      break
      ;;
    *)
      echo "Invalid choice. Please enter a valid option."
      ;;
  esac
done
}


function 13_dnsmasqConfigGenerator() {

echo "DNSStubListener=no" >> /etc/systemd/resolved.conf

  # Clear existing iptables rules
iptables -t nat -F
iptables -t nat -A POSTROUTING -s \${TAP_NETWORK} -j SNAT --to-source \${SERVER_IP}
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -s $TAP_NETWORK -m state --state NEW -j ACCEPT
iptables -A OUTPUT -s $TAP_NETWORK -m state --state NEW -j ACCEPT
iptables -A FORWARD -s $TAP_NETWORK -m state --state NEW -j ACCEPT

sleep 2

  # Save iptables rules
  sudo service netfilter-persistent save

  echo "vpnserver is configured with dnsmasq"

  # Define DHCP server range for dnsmasq
  IPRNG1=""
  until [[ $IPRNG1 =~ ^((25[0-4]|2[0-4][0-9]|[01]?[0-9][0-9]?)){0}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$ && $IPRNG1 -gt 2 && $IPRNG1 -lt 201 ]] ; do
    echo ""
    echo "Define a number between 3-200."
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

  # Extract the TAP_GATEBASE value by removing the last number after the third dot
  TAP_GATEBASE=$(echo $TAP_GATEWAY | sed 's/\.[0-9]*$//')

  # Write dnsmasq configuration data to /etc/dnsmasq.conf
  sudo tee /etc/dnsmasq.conf > /dev/null <<EOT
port=5353
interface=$TAP_INTERFACE
dhcp-range=$TAP_INTERFACE,$TAP_GATEBASE.$IPRNG1,$TAP_GATEBASE.$IPRNG2,24h
dhcp-option=$TAP_INTERFACE,3,$TAP_GATEBASE.1
dhcp-option=option:dns-server,$TAP_GATEBASE.1,$DNSMSQ_SERV
server=$DNSMSQ_SERV
server=$DNSMSQ_SERV2
bind-interfaces
no-poll
no-resolv
bogus-priv
listen-address=$TAP_GATEWAY
dhcp-authoritative
enable-ra
expand-hosts
strict-order
dhcp-no-override
domain-needed
bogus-priv
stop-dns-rebind
rebind-localhost-ok
dns-forward-max=300
dhcp-option=252,"\n"
cache-size=10000
neg-ttl=80000
local-ttl=3600
dhcp-option=23,64
dhcp-option=vendor:MSFT,2,1i
dhcp-option=44,$TAP_GATEWAY
dhcp-option=45,$TAP_GATEWAY
dhcp-option=46,8
dhcp-option=47
EOT

  echo "dnsmasq configuration file generated successfully at /etc/dnsmasq.conf"
}

function 14_runVPNServer1st() {
sysctl -f
sysctl --system
mkdir -p /var/lock/subsys
chmod 755 /etc/init.d/vpnserver
/etc/init.d/vpnserver start
update-rc.d vpnserver defaults

}

function firstTimeConfiguratorY() {
# CUSTOMIZED SETUP
## SETTING UP SERVER
echo "== Auto Configuration ========================"
echo "Server IP= $SERVER_IP"
echo "Traget Folder= $TARGET"
echo "HUB Name= $HUB"
echo "User Name= $USER"
echo "HUB PASSWORD= $HUB_PASSWORD"
echo "SERVER PASSWORD= $SERVER_PASSWORD"
echo "Shared KEY= $SHARED_KEY"
echo "=============================================="
${TARGET}vpnserver/vpncmd localhost /SERVER /CMD ServerPasswordSet ${SERVER_PASSWORD}
${TARGET}vpnserver/vpncmd localhost /SERVER /PASSWORD:${SERVER_PASSWORD} /CMD HubCreate ${HUB} /PASSWORD:${HUB_PASSWORD}
${TARGET}vpnserver/vpncmd localhost /SERVER /PASSWORD:${SERVER_PASSWORD} /HUB:${HUB} /CMD UserCreate ${USER} /GROUP:none /REALNAME:none /NOTE:none
${TARGET}vpnserver/vpncmd localhost /SERVER /PASSWORD:${SERVER_PASSWORD} /HUB:${HUB} /CMD UserPasswordSet ${USER} /PASSWORD:${USER_PASSWORD}
${TARGET}vpnserver/vpncmd localhost /SERVER /PASSWORD:${SERVER_PASSWORD} /CMD IPsecEnable /L2TP:yes /L2TPRAW:yes /ETHERIP:yes /PSK:${SHARED_KEY} /DEFAULTHUB:${HUB}
${TARGET}vpnserver/vpncmd localhost /SERVER /PASSWORD:${SERVER_PASSWORD} /CMD BridgeCreate ${HUB} /DEVICE:${TAP_INTERFACECMD} /TAP:yes
${TARGET}vpnserver/vpncmd localhost /SERVER /PASSWORD:${SERVER_PASSWORD} /CMD ServerCipherSet AES128-SHA256
${TARGET}vpnserver/vpncmd localhost /SERVER /PASSWORD:${SERVER_PASSWORD} /CMD ServerCertRegenerate ${SERVER_IP}
${TARGET}vpnserver/vpncmd localhost /SERVER /PASSWORD:${SERVER_PASSWORD} /CMD VpnOverIcmpDnsEnable /ICMP:yes /DNS:yes

if [ "$SECUREMODESTAT" = "1" ]; then
echo "Enabling Secure NAT"
${TARGET}vpnserver/vpncmd localhost /SERVER /PASSWORD:${SERVER_PASSWORD} /HUB:VPN /CMD SecureNatEnable
else
echo "Disabling Secure NAT"
${TARGET}vpnserver/vpncmd localhost /SERVER /PASSWORD:${SERVER_PASSWORD} /HUB:VPN /CMD SecureNatDisable
fi
}	

function 15_firstTimeConfigurator() {
echo ""
echo "Do you want to run optimized First RUN Setup Script?"
echo "It will set the initial setup for yor server."
echo ""
while true; do
    read -rp "GoldenOne - First RUN Setup? [y/n] " yn
    case $yn in
        [Yy]|[Yy][Ee][Ss]) firstTimeConfiguratorY ; break;;
        [Nn]|[Nn][Oo]) echo "Nothing has changed on SoftEther Server."; break;;
        *) echo "Please enter y or n.";;
    esac
done


echo " restarting DNSMASQ"
sleep 3
service dnsmasq restart
service vpnserver restart
echo ""
echo "+++ Installation finished +++"

touch /bin/seshow
cat <<EOF > /bin/seshow
clear
echo "SoftEther - GoldenOne Script Data"
echo " "
echo "IP:       $SERVER_IP"
echo "USER:     $USER"
echo "PASSWORD: $SERVER_PASSWORD"
echo "IP_SEC:   $SHARED_KEY"
echo " "
EOF

chmod +x /bin/seshow
echo "to Show Login Information, run "seshow" command."
echo " "
echo "IP: $SERVER_IP"
echo "USER: $USER"
echo "PASSWORD: $SERVER_PASSWORD"
echo "IP_SEC: $SHARED_KEY"
echo ""
echo "to Show Login Information, run "seshow" command."
# CRONTAB 
crontab -l | { cat; echo "@reboot /etc/init.d/vpnserver start" ; } | crontab -
crontab -l | { cat; echo "@reboot sleep 15 && service dnsmasq restart" ; } | crontab -
}

# Check if script is running as root
if ! 01_isRoot; then
    echo -e "${RED}Sorry, you need to run this as root.${NC}"
	time_remaining_progress_bar 2 "Root access has failed, exit."
    exit 1
fi

echo -e "${GREEN}Script is running as root.${NC}"

# Function to display the main menu
function SE_main_menu() {
    clear
    color_echo $BLUE "===================================================="
    color_echo $BLUE " $SCRIPT_NAME "
    color_echo $BLUE " Version: $SCRIPT_VERSION "
    color_echo $BLUE "===================================================="
    echo
    color_echo $YELLOW "1) Auto Installer SoftEther VPNServer"
    color_echo $YELLOW "2) Start VPNServer"
    color_echo $YELLOW "3) Stop VPNServer"
    color_echo $YELLOW "4) Edit vpnserver file"
    color_echo $YELLOW "5) Edit dnsmasq config"
    color_echo $YELLOW "6) Restart dnsmasq"
    color_echo $YELLOW "7) Generate vpnserver file"
    color_echo $YELLOW "8) Generate dnsmasq config file"
    color_echo $YELLOW "9) Read Softether Administration Info"
    color_echo $YELLOW "0) Exit and Back to extraMenu script"

    echo
    read -p "Please enter your choice: " choice
    case $choice in
        1) auto_installer;;
        2) start_vpnserver;;
        3) stop_vpnserver;;
        4) edit_vpnserver_file;;
        5) edit_dnsmasq_config;;
        6) restart_dnsmasq;;
        7) generate_vpnserver_file;;
        8) customInstallDNSMASQ;;
        9) read_admin_info;;
        0) clear && exit;;
        *) echo "Invalid option. Press enter to continue..."
           read enterKey;;
    esac
}

# Function to install SoftEther VPN Server
function auto_installer() {
    color_echo $GREEN "Starting SoftEther VPN Server installation..."
	# Check if script is running as root
if ! 01_isRoot; then
    echo -e "${RED}Sorry, you need to run this as root.${NC}"
	time_remaining_progress_bar 2 "Root access has failed, exit."
    exit 1
fi

echo -e "${GREEN}Script is running as root.${NC}"
02_setTarget
03_cleanInstall
04_checkPrereq
05_askDefaults
06_dnsmasqInstall
07_SoftEtherVPN_Installer
08_selectDNS
09_dnsVpnApply
10_SoftEtherInstallMode
#13_dnsmasqConfigGenerator
14_runVPNServer1st
15_firstTimeConfigurator
read -p "Press enter to continue..."
SE_main_menu
}

# Function to start VPN server
function start_vpnserver() {
    sudo /etc/init.d/vpnserver start
    read -p "Press enter to continue..."
    SE_main_menu
}

# Function to stop VPN server
function stop_vpnserver() {
    sudo /etc/init.d/vpnserver stop
    read -p "Press enter to continue..."
    SE_main_menu
}

# Function to edit vpnserver file
function edit_vpnserver_file() {
    sudo nano /etc/init.d/vpnserver
    read -p "Press enter to continue..."
    SE_main_menu
}

# Function to edit dnsmasq config
function edit_dnsmasq_config() {
    sudo nano /etc/dnsmasq.conf
    read -p "Press enter to continue..."
    SE_main_menu
}

# Function to restart dnsmasq
function restart_dnsmasq() {
    sudo systemctl restart dnsmasq
    read -p "Press enter to continue..."
    SE_main_menu
}

# Function to generate vpnserver file
function generate_vpnserver_file() {
    10_SoftEtherInstallMode
    read -p "Press enter to continue..."
    SE_main_menu
}

# Function to generate dnsmasq config file
function customInstallDNSMASQ() {
    SERVER_IP=$(ip -4 addr | sed -ne 's|^.* inet \([^/]*\)/.* scope global.*$|\1|p' | head -1)
    if [[ -z $SERVER_IP ]]; then
        # Detect public IPv6 address
        SERVER_IP=$(ip -6 addr | sed -ne 's|^.* inet6 \([^/]*\)/.* scope global.*$|\1|p' | head -1)
    fi

    read -rp "IP address: " -e -i "$SERVER_IP" IP
    SERVER_IP="${IP:-$SERVER_IP}"
    echo " "
	
read -p "Enter the IP address range for the TAP interface [10.10.129.0/24]: " TAP_NETWORK
TAP_NETWORK=${TAP_NETWORK:-10.10.129.0/24}

read -p "Enter the gateway IP address for the TAP interface [10.10.129.1]: " TAP_GATEWAY
TAP_GATEWAY=${TAP_GATEWAY:-10.10.129.1}

read -p "Enter the name of the TAP interface [tap_ext]: " TAP_INTERFACE
TAP_INTERFACE=${TAP_INTERFACE:-tap_ext}

08_selectDNS
13_dnsmasqConfigGenerator

    color_echo $GREEN "dnsmasq config file generated!"
    read -p "Press enter to continue..."
    SE_main_menu
}

# Function to read Softether Administration Info
function read_admin_info() {
    echo
    color_echo $GREEN "SoftEther VPN Server Administration Information:"
    echo "------------------------"
    /bin/seshow
    echo "------------------------"
    sudo /usr/local/vpnserver/vpncmd localhost /server /adminhub:DEFAULT /cmd ServerStatusGet
    read -p "Press enter to continue..."
    SE_main_menu
}

SE_main_menu
