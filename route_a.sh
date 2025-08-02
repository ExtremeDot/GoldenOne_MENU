#!/bin/bash
set -euo pipefail

# Version: 1.4
# Purpose: Custom routing of incoming traffic through a specified outgoing interface with NAT.
# Supports English and Persian messages; user chooses at start.

# Ensure running as root
if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root." >&2
  exit 1
fi

# Language selection: 1) English 2) فارسی
echo "Select language / زبان را انتخاب کنید:"
echo "1) English"
echo "2) فارسی"
read -rp "Choice [1]: " lang_choice
lang_choice=${lang_choice:-1}
if [[ "$lang_choice" == "2" ]]; then
  LANG_CODE=fa
else
  LANG_CODE=en
fi

# Message definitions
declare -A MSG_EN=(
  [no_iface]='No active interfaces found.'
  [incoming_prompt]='[INCOMING]: Enter interface name (default %s): '
  [dest_prompt]='[DESTINATION]: Enter interface name: '
  [empty_in]='Incoming interface name is empty.'
  [invalid_in]='Incoming interface "%s" is invalid.'
  [no_dest]='No other interface available for destination.'
  [same_iface]='Destination cannot be the same as incoming.'
  [invalid_out]='Destination interface "%s" is invalid.'
  [ip_missing]='Failed to obtain IPv4 address for one of the interfaces.'
  [selected]='✔ Interfaces selected:'
  [incoming]='[INCOMING]    : %s -> %s (%s)'
  [destination]='[DESTINATION] : %s -> %s (%s)'
  [table]='✔ Custom table: %s'
  [saved]='✔ Custom routing structure saved to %s'
  [routing_saved_file]='/Golden1/route_%s.sh'
  [need_root]='This script must be run as root.'
)

declare -A MSG_FA=(
  [no_iface]='هیچ اینترفیس فعالی پیدا نشد.'
  [incoming_prompt]='[ورودی]: نام اینترفیس را وارد کنید (پیش‌فرض %s): '
  [dest_prompt]='[مقصد]: نام اینترفیس را وارد کنید: '
  [empty_in]='نام اینترفیس ورودی خالی است.'
  [invalid_in]='اینترفیس ورودی "%s" معتبر نیست.'
  [no_dest]='اینترفیس خروجی دیگری برای انتخاب وجود ندارد.'
  [same_iface]='اینترفیس خروجی نمی‌تواند همان ورودی باشد.'
  [invalid_out]='اینترفیس خروجی "%s" معتبر نیست.'
  [ip_missing]='آدرس IPv4 برای یکی از اینترفیس‌ها دریافت نشد.'
  [selected]='✔ اینترفیس‌ها انتخاب شدند:'
  [incoming]='[ورودی]        : %s -> %s (%s)'
  [destination]='[مقصد]         : %s -> %s (%s)'
  [table]='✔ جدول سفارشی: %s'
  [saved]='✔ ساختار مسیریابی در %s ذخیره شد.'
  [routing_saved_file]='/Golden1/route_%s.sh'
)

# Helper to fetch localized message
get_msg() {
  local key=$1
  shift
  if [[ "$LANG_CODE" == "fa" ]]; then
    printf "${MSG_FA[$key]:-${MSG_EN[$key]}}" "$@"
  else
    printf "${MSG_EN[$key]}" "$@"
  fi
}

# Error print
error() {
  if [[ "$LANG_CODE" == "fa" ]]; then
    echo "خطا: $*" >&2
  else
    echo "Error: $*" >&2
  fi
}

# Gather interfaces
mapfile -t interfaces < <(ip -o link show | awk -F': ' '{print $2}' | grep -v lo)
if [[ ${#interfaces[@]} -eq 0 ]]; then
  error "$(get_msg no_iface)"
  exit 1
fi

# Select incoming interface (default from existing default route)
default_in=$(ip -4 route show default | awk '/default/ {for(i=1;i<=NF;i++) if($i=="dev") print $(i+1)}' | head -1)
while true; do
  echo
  if [[ "$LANG_CODE" == "fa" ]]; then
    echo "اینترفیس‌های ورودی موجود: ${interfaces[*]}"
  else
    echo "Available incoming interfaces: ${interfaces[*]}"
  fi
  # prompt with formatted default
  if [[ "$LANG_CODE" == "fa" ]]; then
    read -rp "$(printf "${MSG_FA[incoming_prompt]}" "$default_in")" INPUT_NIC
  else
    read -rp "$(printf "${MSG_EN[incoming_prompt]}" "$default_in")" INPUT_NIC
  fi
  INPUT_NIC=${INPUT_NIC:-$default_in}
  if [[ -z "$INPUT_NIC" ]]; then
    error "$(get_msg empty_in)"
    continue
  fi
  if ! ip link show "$INPUT_NIC" &>/dev/null; then
    error "$(printf "${MSG_EN[invalid_in]}" "$INPUT_NIC")"
    continue
  fi
  break
done

# Select destination interface (must not equal incoming)
while true; do
  dests=()
  for i in "${interfaces[@]}"; do
    [[ "$i" == "$INPUT_NIC" ]] && continue
    dests+=("$i")
  done
  if [[ ${#dests[@]} -eq 0 ]]; then
    error "$(get_msg no_dest)"
    exit 1
  fi
  echo
  if [[ "$LANG_CODE" == "fa" ]]; then
    echo "اینترفیس‌های مقصد موجود: ${dests[*]}"
  else
    echo "Available destination interfaces: ${dests[*]}"
  fi
  read -rp "$(get_msg dest_prompt)" OUTPUT_NIC
  if [[ "$OUTPUT_NIC" == "$INPUT_NIC" ]]; then
    error "$(get_msg same_iface)"
    continue
  fi
  if ! ip link show "$OUTPUT_NIC" &>/dev/null; then
    error "$(printf "${MSG_FA[invalid_out]}" "$OUTPUT_NIC")"
    continue
  fi
  break
done

# Get routing table number
DEF_TABLE=1000
read -e -i "$DEF_TABLE" -p "Enter the routing table number [${DEF_TABLE}]: " input_table
DEF_TABLE=${input_table:-$DEF_TABLE}

# Extract IPv4 addresses
get_ip() {
  local iface=$1
  ip -4 -o addr show dev "$iface" | awk '{print $4}' | cut -d/ -f1 | head -1
}

INPUT_IP=$(get_ip "$INPUT_NIC")
OUTPUT_IP=$(get_ip "$OUTPUT_NIC")
if [[ -z "$INPUT_IP" || -z "$OUTPUT_IP" ]]; then
  error "$(get_msg ip_missing)"
  exit 1
fi

INPUT_BASE_ADDRESS=$(echo "$INPUT_IP" | awk -F. '{print $1"."$2"."$3".0/24"}')
OUTPUT_BASE_ADDRESS=$(echo "$OUTPUT_IP" | awk -F. '{print $1"."$2"."$3".0/24"}')

if [[ "$LANG_CODE" == "fa" ]]; then
  echo
  echo "$(get_msg selected)"
  printf "$(get_msg incoming)\n" "$INPUT_NIC" "$INPUT_IP" "$INPUT_BASE_ADDRESS"
  printf "$(get_msg destination)\n" "$OUTPUT_NIC" "$OUTPUT_IP" "$OUTPUT_BASE_ADDRESS"
  printf "$(get_msg table)\n" "$DEF_TABLE"
else
  echo
  echo "$(get_msg selected)"
  printf "$(get_msg incoming)\n" "$INPUT_NIC" "$INPUT_IP" "$INPUT_BASE_ADDRESS"
  printf "$(get_msg destination)\n" "$OUTPUT_NIC" "$OUTPUT_IP" "$OUTPUT_BASE_ADDRESS"
  printf "$(get_msg table)\n" "$DEF_TABLE"
fi

# Enable IPv4 forwarding
sysctl -w net.ipv4.ip_forward=1 >/dev/null

# Apply routing rules to custom table
ip route add "$INPUT_BASE_ADDRESS" dev "$INPUT_NIC" table "$DEF_TABLE"
sleep 1
ip route add "$OUTPUT_BASE_ADDRESS" dev "$OUTPUT_NIC" table "$DEF_TABLE"
sleep 1
ip route add default via "$OUTPUT_IP" dev "$OUTPUT_NIC" table "$DEF_TABLE"
sleep 1

# Add ip rules
ip rule add iif "$INPUT_NIC" lookup "$DEF_TABLE"
sleep 1
ip rule add iif "$OUTPUT_NIC" lookup "$DEF_TABLE"
sleep 1

# Setup NAT
iptables -t nat -F
sleep 1
source_net=${INPUT_BASE_ADDRESS%/*}
iptables -t nat -A POSTROUTING -s "$source_net" -o "$OUTPUT_NIC" -j MASQUERADE
sleep 1

# Persist reproduction script
mkdir -p /Golden1
cat <<EOF > /Golden1/route_${DEF_TABLE}.sh
#!/bin/bash
set -euo pipefail

# Reapply rules for table $DEF_TABLE
ip route add "$INPUT_BASE_ADDRESS" dev "$INPUT_NIC" table "$DEF_TABLE"
ip route add "$OUTPUT_BASE_ADDRESS" dev "$OUTPUT_NIC" table "$DEF_TABLE"
ip route add default via "$OUTPUT_IP" dev "$OUTPUT_NIC" table "$DEF_TABLE"
ip rule add iif "$INPUT_NIC" lookup "$DEF_TABLE"
ip rule add iif "$OUTPUT_NIC" lookup "$DEF_TABLE"

iptables -t nat -F
iptables -t nat -A POSTROUTING -s "${INPUT_BASE_ADDRESS%/*}" -o "$OUTPUT_NIC" -j MASQUERADE
EOF
chmod +x /Golden1/route_${DEF_TABLE}.sh

# Final message
if [[ "$LANG_CODE" == "fa" ]]; then
  printf "$(get_msg saved)\n" "/Golden1/route_${DEF_TABLE}.sh"
else
  printf "$(get_msg saved)\n" "/Golden1/route_${DEF_TABLE}.sh"
fi
