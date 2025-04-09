#!/bin/bash

set -e

# === Config ===
VM_NAME="win11-virt"
ISO_PATH="$HOME/windows/isos/Win11_24H2_English_x64.iso"
VIRTIO_PATH="$HOME/windows/isos/virtio-win-0.1.271.iso"
UNATTEND_XML="$HOME/windows/autounattend.xml"
FLOPPY_IMAGE_PATH=~/windows/tmp/autounattend.vfd
DISK_PATH="$HOME/windows/vms/${VM_NAME}.qcow2"
DISK_SIZE="256G"
RAM_MB=32768
CPU_CORES=12

# === Install Requirements ===
# sudo apt update
# sudo apt install -y qemu-kvm libvirt-daemon-system libvirt-clients virt-manager ovmf genisoimage mtools

# === Create directories ===
mkdir -p ~/windows/vms
mkdir -p ~/windows/tmp

# === Create floppy image with autounattend.xml ===
rm -rf $FLOPPY_IMAGE_PATH
mkfs.vfat -C $FLOPPY_IMAGE_PATH 1440
mcopy -i $FLOPPY_IMAGE_PATH "$UNATTEND_XML" ::/autounattend.xml

# === Create VM disk ===
qemu-img create -f qcow2 "$DISK_PATH" "$DISK_SIZE"

# === Start and enable default network ===
if ! virsh net-info default | grep 'Active:' | grep -q 'yes'; then
    echo "🔌 Starting default network..."
    sudo virsh net-start default
    sudo virsh net-autostart default
else
    echo "✅ Default network is already active."
fi

VM_NAME="win11-virt"
ISO_PATH="$HOME/windows/isos/Win11_24H2_English_x64.iso"
VIRTIO_PATH="$HOME/windows/isos/virtio-win-0.1.271.iso"
UNATTEND_XML="$HOME/windows/autounattend.xml"
FLOPPY_IMAGE_PATH=~/windows/tmp/autounattend.vfd
DISK_PATH="$HOME/windows/vms/${VM_NAME}.qcow2"
DISK_SIZE="256G"
RAM_MB=32768
CPU_CORES=12

# === Define and start VM ===
# virt-install \
#   --name $VM_NAME \
#   --memory $RAM_MB \
#   --vcpus $CPU_CORES \
#   --cpu host-passthrough \
#   --os-variant win10 \
#   --hvm \
#   --boot cdrom,hd,menu=on \
#   --cdrom "$ISO_PATH" \
#   --disk path="$VIRTIO_PATH",device=cdrom \
#   --disk path="$DISK_PATH",format=qcow2,bus=scsi \
#   --disk path="$FLOPPY_IMAGE_PATH",device=floppy \
#   --controller type=scsi,model=virtio-scsi \
#   --graphics spice \
#   --video qxl \
#   --channel spicevmc \
#   --sound ich9 \
#   --controller type=usb,model=qemu-xhci \
#   --network network=default,model=virtio \
#   --noautoconsole

virt-install \
  --name $VM_NAME \
  --memory $RAM_MB \
  --vcpus $CPU_CORES \
  --cpu host-passthrough \
  --os-variant win10 \
  --hvm \
  --boot cdrom,hd,menu=on \
  --cdrom "$ISO_PATH" \
  --disk path="$VIRTIO_PATH",device=cdrom \
  --disk path="$DISK_PATH",format=qcow2,bus=scsi \
  --disk path="$FLOPPY_IMAGE_PATH",device=floppy \
  --controller type=scsi,model=virtio-scsi \
  --graphics spice \
  --video qxl \
  --channel spicevmc \
  --sound ich9 \
  --controller type=usb,model=qemu-xhci \
  --network network=default,model=virtio \
  --noautoconsole
