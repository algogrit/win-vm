# Requires: Admin privileges
$NewName = "Aditi"

# --- Rename Computer ---
$currentName = (Get-ComputerInfo).CsName
if ($currentName -ne $NewName) {
    Write-Host "🔄 Renaming computer from '$currentName' to '$NewName'..."
    Rename-Computer -NewName $NewName -Force
    $needsReboot = $true
} else {
    Write-Host "✅ Computer already named '$NewName'"
}

# --- Enable Remote Desktop ---
$rdpKey = "HKLM:\System\CurrentControlSet\Control\Terminal Server"
$fDenyTS = Get-ItemPropertyValue -Path $rdpKey -Name "fDenyTSConnections"
if ($fDenyTS -ne 0) {
    Write-Host "🎮 Enabling Remote Desktop..."
    Set-ItemProperty -Path $rdpKey -Name "fDenyTSConnections" -Value 0
} else {
    Write-Host "✅ Remote Desktop already enabled"
}

# --- Enable NLA (optional, secure) ---
Set-ItemProperty -Path "$rdpKey\WinStations\RDP-Tcp" -Name "UserAuthentication" -Value 1

# --- Firewall rule for RDP ---
if (-not (Get-NetFirewallRule -DisplayGroup "Remote Desktop" -ErrorAction SilentlyContinue)) {
    Write-Host "🧱 Adding firewall rule for Remote Desktop..."
    Enable-NetFirewallRule -DisplayGroup "Remote Desktop"
} else {
    Write-Host "✅ Remote Desktop firewall rule already enabled"
}

# --- Install OpenSSH Server ---
$sshCapability = Get-WindowsCapability -Online | Where-Object { $_.Name -like "OpenSSH.Server*" }
if ($sshCapability.State -ne "Installed") {
    Write-Host "🔐 Installing OpenSSH Server..."
    Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
} else {
    Write-Host "✅ OpenSSH Server already installed"
}

# --- Start & enable sshd ---
if (-not (Get-Service -Name "sshd" -ErrorAction SilentlyContinue)) {
    Write-Host "❌ SSH service not found. Please ensure OpenSSH Server installed correctly."
} else {
    Write-Host "🚀 Starting and enabling SSH service..."
    Start-Service sshd
    Set-Service -Name sshd -StartupType Automatic
}

# --- Firewall rule for SSH ---
if (-not (Get-NetFirewallRule -Name "OpenSSH-Server-In-TCP" -ErrorAction SilentlyContinue)) {
    Write-Host "🧱 Adding firewall rule for SSH..."
    New-NetFirewallRule -Name "OpenSSH-Server-In-TCP" -DisplayName "OpenSSH Server (sshd)" `
        -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22
} else {
    Write-Host "✅ SSH firewall rule already exists"
}

# --- Reboot Reminder ---
if ($needsReboot) {
    Write-Host "`n🔁 You must reboot the system for the hostname change to take effect."
} else {
    Write-Host "`n🎉 All settings are already in place."
}
