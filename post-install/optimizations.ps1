# From: https://sysguides.com/install-a-windows-11-virtual-machine-on-kvm#13-4-optimize-windows-11-performance

# PowerShell Script to Optimize Windows 11 VM Performance

# 1. Disable SuperFetch (SysMain)
Write-Output "Disabling SuperFetch (SysMain)..."
Stop-Service -Name "SysMain" -Force
Set-Service -Name "SysMain" -StartupType Disabled

# 2. Disable Windows Web Search
Write-Output "Disabling Windows Web Search..."
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "BingSearchEnabled" -Value 0
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "CortanaConsent" -Value 0

# 3. Disable useplatformclock
Write-Output "Disabling useplatformclock..."
bcdedit /set useplatformclock false

# 4. Disable Unnecessary Scheduled Tasks
Write-Output "Disabling Unnecessary Scheduled Tasks..."
$tasks = @(
    "\Microsoft\Windows\Customer Experience Improvement Program\Consolidator",
    "\Microsoft\Windows\Customer Experience Improvement Program\UsbCeip",
    "\Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector"
)
foreach ($task in $tasks) {
    Disable-ScheduledTask -TaskPath $task
}

# 5. Disable Unnecessary Startup Programs
Write-Output "Disabling Unnecessary Startup Programs..."
$startupApps = Get-CimInstance Win32_StartupCommand | Select-Object Name, Command, Location, User
foreach ($app in $startupApps) {
    Write-Output "Disabling $($app.Name)..."
    # Implement logic to disable the startup application
    # Note: Disabling startup apps may require additional steps depending on the app
}

# 6. Adjust Visual Effects for Best Performance
Write-Output "Adjusting Visual Effects for Best Performance..."
$performanceOptions = @"
Windows Registry Editor Version 5.00

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects]
"VisualFXSetting"=dword:00000002
"@
$performanceOptions | Out-File -FilePath "$env:TEMP\performanceOptions.reg"
Start-Process regedit.exe -ArgumentList "/s $env:TEMP\performanceOptions.reg" -Wait
Remove-Item "$env:TEMP\performanceOptions.reg"

Write-Output "Optimization complete. Please restart your computer for all changes to take effect."
