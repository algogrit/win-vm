#!/usr/bin/env bash

# CONFIGURATION
VM_NAME="win11-virt"
DISK_PATH="$HOME/windows/vms/${VM_NAME}.qcow2"
ISO_PATH="$HOME/windows/isos/Win11_24H2_English_x64.iso"
VIRTIO_PATH="$HOME/windows/isos/virtio-win-0.1.271.iso"

# CREATE DISK (256 GB dynamic)
qemu-img create -f qcow2 "$DISK_PATH" 256G

# START VM INSTALL
virt-install \
  --name $VM_NAME \
  --memory 32768 \
  --vcpus 12 \
  --cpu host-passthrough \
  --machine q35 \
  --boot uefi \
  --tpm emulator \
  --os-variant win10 \
  --hvm \
  --cdrom "$ISO_PATH" \
  --disk path="$DISK_PATH",format=qcow2,bus=virtio \
  --disk path="$VIRTIO_PATH",device=cdrom \
  --network network=default,model=virtio \
  --graphics spice \
  --video qxl \
  --sound ich9 \
  --controller type=usb,model=qemu-xhci \
  --features kvm_hidden=on \
  --check all=off \
  --noautoconsole
