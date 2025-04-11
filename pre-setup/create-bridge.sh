#!/bin/bash

set -e

BRIDGE_NAME="br1"
NETPLAN_FILE="/etc/netplan/99-$BRIDGE_NAME.yaml"

if ip link show "$BRIDGE_NAME" > /dev/null 2>&1; then
    echo "Bridge $BRIDGE_NAME already exists."
    exit 0
fi

echo "Creating bridge-only Netplan config..."

sudo tee "$NETPLAN_FILE" > /dev/null <<EOF
network:
  version: 2
  renderer: networkd
  bridges:
    $BRIDGE_NAME:
      dhcp4: yes
      optional: true
EOF

echo "Setting correct permissions..."
sudo chmod 600 "$NETPLAN_FILE"

echo "Applying Netplan..."
sudo netplan apply

echo "Bridge $BRIDGE_NAME created. Setting up NAT..."

# Enable IP forwarding
sudo sysctl -w net.ipv4.ip_forward=1
sudo sed -i '/^net.ipv4.ip_forward/d' /etc/sysctl.conf
echo 'net.ipv4.ip_forward=1' | sudo tee -a /etc/sysctl.conf

# Create NAT rule to masquerade VM traffic to internet
sudo iptables -t nat -C POSTROUTING -o wlp15s0 -j MASQUERADE 2>/dev/null || \
sudo iptables -t nat -A POSTROUTING -o wlp15s0 -j MASQUERADE

echo "NAT setup complete. You can now attach VMs to $BRIDGE_NAME."
