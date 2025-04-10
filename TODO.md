# TODO

## 1. Include VirtIO drivers in the disc

Great call — including **VirtIO drivers** directly in your custom Windows ISO will ensure:

✅ Disk detection (via `viostor`)
✅ Network detection (via `NetKVM`)
✅ Balloon driver, QEMU guest agent, etc. — all ready to go during setup

---

## 💽 How to Add VirtIO Drivers into Your Windows ISO

### 🧰 Requirements:
1. **Your base Windows ISO**
2. **VirtIO ISO from Fedora**
   Download: [https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/](https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/)

Example filename:
```
virtio-win-0.1.240.iso
```

---

## 📦 Merge Steps (Ubuntu)

### 1. Mount ISOs

```bash
mkdir -p /mnt/win /mnt/virtio
sudo mount -o loop Windows.iso /mnt/win
sudo mount -o loop virtio-win-0.1.240.iso /mnt/virtio
```

### 2. Copy Windows ISO Contents to Work Dir

```bash
mkdir -p ~/win-custom-iso
rsync -avh --exclude="*.iso" /mnt/win/ ~/win-custom-iso/
```

### 3. Merge VirtIO Drivers into ISO

```bash
mkdir -p ~/win-custom-iso/virtio
rsync -avh /mnt/virtio/ ~/win-custom-iso/virtio/
```

> Tip: Don’t place VirtIO files at the root, use a subfolder like `/virtio` to keep it tidy.

### 4. Add `autounattend.xml` and `setup/` folder

```bash
cp autounattend.xml ~/win-custom-iso/
mkdir -p ~/win-custom-iso/setup
cp init-remote-config.ps1 ~/win-custom-iso/setup/
```

### 5. Unmount

```bash
sudo umount /mnt/win
sudo umount /mnt/virtio
```

---

## 🔥 Build Final Bootable ISO

```bash
genisoimage -o Windows-Custom-With-VirtIO.iso \
  -b boot/etfsboot.com -no-emul-boot -boot-load-size 8 -hide boot.catalog \
  -udf -J -joliet-long -rational-rock -volid "WinVirt" \
  ~/win-custom-iso
```

> You now have: `Windows-Custom-With-VirtIO.iso`
> Bootable, unattended, and with drivers ready to install.

---

## 💡 Bonus (Optional Integration)

To **auto-load drivers during install**, update your `autounattend.xml` to include this under `WindowsPE` pass:

```xml
<settings pass="windowsPE">
  <component name="Microsoft-Windows-PnpCustomizationsWinPE" ...>
    <DriverPaths>
      <PathAndCredentials wcm:action="add" wcm:key="1">
        <Path>e:\virtio\viostor\w10\amd64</Path>
      </PathAndCredentials>
      <PathAndCredentials wcm:action="add" wcm:key="2">
        <Path>e:\virtio\netkvm\w10\amd64</Path>
      </PathAndCredentials>
    </DriverPaths>
  </component>
</settings>
```

(Adjust paths based on the OS version you’re installing — for Windows 11, use `w11` or fallback to `w10`.)

---

## 2. Include Post Install scripts in the ISO

### 🧰 Tools You'll Use on Ubuntu

You’ll need:
```bash
sudo apt install genisoimage wimtools
```

## 🗂️ Step-by-Step: Create a Bootable ISO with Custom Setup

Let’s say your original Windows ISO is called:

```
Windows.iso
```

### 1. 🗃 Mount the Original ISO

```bash
mkdir -p /mnt/winiso
sudo mount -o loop Windows.iso /mnt/winiso
```

### 2. 📦 Copy All Files to a Working Directory

```bash
mkdir -p ~/win-custom-iso
rsync -avh --exclude="*.iso" /mnt/winiso/ ~/win-custom-iso/
sudo umount /mnt/winiso
```

### 3. 🧾 Add Your Custom Files

Assuming you have:

- Your `autounattend.xml`
- Your `setup/init-remote-config.ps1`

```bash
cp autounattend.xml ~/win-custom-iso/
mkdir -p ~/win-custom-iso/setup
cp init-remote-config.ps1 ~/win-custom-iso/setup/
```

### 4. 🔥 (Optional) Patch Boot Files (For UEFI/BIOS Compatibility)

Sometimes UEFI boot fails without `etfsboot.com`. You can extract these boot files from the original ISO or use [boot files from `oscdimg`](https://learn.microsoft.com/en-us/windows-hardware/manufacture/desktop/oscdimg-command-line-options).

But for a basic BIOS bootable ISO:

```bash
genisoimage -o Windows-Custom.iso \
  -b boot/etfsboot.com -no-emul-boot -boot-load-size 8 -hide boot.catalog \
  -udf -J -joliet-long -rational-rock -volid "WinCustom" \
  ~/win-custom-iso
```

> If you want UEFI+BIOS bootable, let me know — that requires `isohybrid` or `xorriso`.

---

### ✅ Result

You now have:
```bash
Windows-Custom.iso
```
Ready to boot in your VM via `virt-install` or any hypervisor, with the `setup` script executing automatically at first login 🎯

---

## 3. Automate the setup to include the MAS activation, optimzations and RDP & SSH enabling

This XML will:
- Run the PowerShell script on first login
- Hide the console window
- Only run once (via registry cleanup)

```xml
<unattend xmlns="urn:schemas-microsoft-com:unattend">
  <settings pass="oobeSystem">
    <component name="Microsoft-Windows-Shell-Setup" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
      <AutoLogon>
        <Password>
          <Value>q</Value>
          <PlainText>true</PlainText>
        </Password>
        <Username>om</Username>
        <Enabled>true</Enabled>
        <LogonCount>1</LogonCount>
      </AutoLogon>
      <FirstLogonCommands>
        <SynchronousCommand wcm:action="add">
          <CommandLine>powershell -ExecutionPolicy Bypass -WindowStyle Hidden -File %SystemDrive%\setup\init-remote-config.ps1</CommandLine>
          <Description>Init Remote Access Config</Description>
          <Order>1</Order>
        </SynchronousCommand>
      </FirstLogonCommands>
      <UserAccounts>
        <AdministratorPassword>
          <Value>q</Value>
          <PlainText>true</PlainText>
        </AdministratorPassword>
        <LocalAccounts>
          <LocalAccount wcm:action="add">
            <Name>om</Name>
            <Group>Administrators</Group>
            <Password>
              <Value>q</Value>
              <PlainText>true</PlainText>
            </Password>
          </LocalAccount>
        </LocalAccounts>
      </UserAccounts>
      <TimeZone>India Standard Time</TimeZone>
    </component>
  </settings>
</unattend>
```
