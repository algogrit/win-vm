#!/bin/bash

set -e

# --- Config ---
WIN_ISO=~/isos/Win11_24H2_English_x64.iso
VIRTIO_ISO=~/isos/virtio-win.iso
UNATTEND_XML=~/windows/autounattend.xml
VM_NAME=win11-vfio
DISK_PATH=/var/lib/libvirt/images/${VM_NAME}.qcow2
GPU_IDS="10de:2782,10de:22bc"  # Replace with your actual GPU and audio IDs

echo "==> Installing dependencies..."
apt update
apt install -y qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils virt-manager ovmf cloud-image-utils

echo "==> Enabling IOMMU..."
sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="/GRUB_CMDLINE_LINUX_DEFAULT="amd_iommu=on iommu=pt /' /etc/default/grub
update-grub

echo "==> Blacklisting NVIDIA drivers and binding VFIO..."
cat <<EOF >/etc/modprobe.d/vfio.conf
options vfio-pci ids=${GPU_IDS}
EOF

cat <<EOF >/etc/modprobe.d/blacklist-nvidia.conf
blacklist nouveau
blacklist nvidia
blacklist nvidiafb
EOF

update-initramfs -u

echo "==> Creating VM disk..."
qemu-img create -f qcow2 ${DISK_PATH} 256G

echo "==> Creating VM with GPU passthrough..."
virt-install \
  --name ${VM_NAME} \
  --os-variant win11 \
  --virt-type kvm \
  --memory 32768 \
  --vcpus 12 \
  --cpu host-passthrough \
  --hvm \
  --boot uefi \
  --features kvm_hidden=on \
  --disk path=${DISK_PATH},format=qcow2,bus=virtio \
  --cdrom ${WIN_ISO} \
  --disk ${VIRTIO_ISO},device=cdrom \
  --disk ${UNATTEND_XML},device=floppy \
  --graphics none \
  --network network=default,model=virtio \
  --soundhw ich9 \
  --host-device 0000:01:00.0 \
  --host-device 0000:01:00.1 \
  --check all=off \
  --noautoconsole

echo "==> Done. Reboot host and launch VM from Virt-Manager."
