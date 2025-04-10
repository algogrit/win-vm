#!/usr/bin/env bash

sudo apt install -y qemu-kvm libvirt-daemon-system libvirt-clients virt-manager ovmf genisoimage mtools
sudo apt install -y bridge-utils

# Loading and installing the network interface
./pre-setup/load-macvtap-modules.sh
./pre-setup/create-macvtap-net.sh
