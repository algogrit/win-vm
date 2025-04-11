#!/usr/bin/env bash

set -e

# === Config ===
VM_NAME="aditi"
BASE_PATH=$HOME/windows

ISO_PATH="$BASE_PATH/isos/Win11_24H2_English_x64.iso"
VIRTIO_PATH="$BASE_PATH/isos/virtio-win-0.1.271.iso"

UNATTEND_XML="$BASE_PATH/autounattend.xml"
FLOPPY_IMAGE_PATH=$BASE_PATH/tmp/autounattend.vfd

POST_INSTALL_IMAGE_PATH=$BASE_PATH/tmp/post_install.iso
POST_INSTALL_SCRIPTS_PATH=$BASE_PATH/post-install

DISK_PATH="$BASE_PATH/vms/${VM_NAME}.qcow2"

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

# === Create image with post-install scripts ===
genisoimage -o $POST_INSTALL_IMAGE_PATH $POST_INSTALL_SCRIPTS_PATH

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

# === Define and start VM ===
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
  --disk path="$DISK_PATH",format=qcow2,bus=virtio \
  --disk path="$POST_INSTALL_IMAGE_PATH",device=cdrom \
  --disk path="$FLOPPY_IMAGE_PATH",device=floppy \
  --controller type=scsi,model=virtio-scsi \
  --graphics spice \
  --video qxl \
  --channel spicevmc \
  --sound ich9 \
  --controller type=usb,model=qemu-xhci \
  --network bridge=br1,model=virtio \
  # --network type=direct,source=wlp15s0,source_mode=bridge,model=virtio \
  # --network network=macvtap-net,model=virtio \
  --noautoconsole

# Install the drivers: `viostor\w11\amd64` & `NetKVM\w11\amd64` inside Windows Installer for recognizing the disk & getting network
  # - https://sysguides.com/install-a-windows-11-virtual-machine-on-kvm
# Once Windows is installed, go to the VirtIO CD drive and run: `virtio-win-guest-tools.exe`
