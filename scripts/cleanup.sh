#!/usr/bin/env bash

VM_NAME="win11-virt"
DISK_PATH="$HOME/windows/vms/${VM_NAME}.qcow2"

virsh destroy win11-virt

virsh undefine win11-virt --remove-all-storage

rm -rf $DISK_PATH

cp -r bkp/windows/isos/* windows/isos/
