#!/usr/bin/env bash

IFACE="wlp15s0"
NET_NAME="macvtap-net"

# Check if interface exists
if ! ip link show "$IFACE" &>/dev/null; then
  echo "Error: Interface $IFACE not found"
  exit 1
fi

# Check if network already defined
if virsh net-info "$NET_NAME" &>/dev/null; then
  echo "Libvirt network '$NET_NAME' already exists."
  exit 0
fi

# Create macvtap XML config
cat > /tmp/"$NET_NAME".xml <<EOF
<network>
  <name>${NET_NAME}</name>
  <forward mode='bridge'/>
  <bridge name='${IFACE}'/>
  <virtualport type='macvtap'/>
</network>
EOF

# Define and start the network
virsh net-define /tmp/"$NET_NAME".xml
virsh net-autostart "$NET_NAME"
virsh net-start "$NET_NAME"

echo "✅ Network '$NET_NAME' created and started."
