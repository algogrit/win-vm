#!/usr/bin/env bash

VM_NAME="aditi"
DISK_PATH="$HOME/windows/vms/${VM_NAME}.qcow2"

virsh destroy $VM_NAME

virsh undefine $VM_NAME --remove-all-storage

rm -rf $DISK_PATH

cp -r bkp/windows/isos/* windows/isos/
