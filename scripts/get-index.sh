#!/usr/bin/env bash

ISO_PATH="$HOME/windows/isos/Win11_24H2_English_x64.iso"

# sudo apt install wimtools

mkdir -p ~/mnt/winiso
sudo mount -o loop $ISO_PATH ~/mnt/winiso

wiminfo ~/isos/Win11.iso

ls ~/mnt/winiso/sources/install.*

wiminfo ~/mnt/winiso/sources/install.wim

# OR
# wiminfo ~/mnt/winiso/sources/install.esd

sudo umount ~/mnt/winiso

rm -rf ~/mnt/winiso
