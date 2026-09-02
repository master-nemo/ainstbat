# ============================================================
# Administrator Rights Verification
# ============================================================
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Error "ERROR: Please run this script as ADMINISTRATOR."
    Pause
    exit
}

# Global preference to prevent external scripts from silently killing the session
$ErrorActionPreference = "Continue"

# ============================================================
# Chocolatey and Scoop Installation (Official Vendor Lines)
# ============================================================
if (Get-Command winget -ErrorAction SilentlyContinue) {
    winget install --id chocolatey.chocolatey --silent --accept-source-agreements --accept-package-agreements --disable-interactivity
} else {
    # Strictly official line from chocolatey.org
    Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    $ErrorActionPreference = "Continue"
}

# Strictly official lines from scoop.sh
if (!(Get-Command scoop -ErrorAction SilentlyContinue)) {
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force -ErrorAction Continue
    Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
}

$ErrorActionPreference = "Continue"

# ============================================================
# Path Synchronization
# ============================================================
$env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
if ($env:Path -notlike "*chocolatey\bin*") { $env:Path += ";C:\ProgramData\chocolatey\bin" }
if ($env:Path -notlike "*scoop\shims*") { $env:Path += ";$env:USERPROFILE\scoop\shims" }


# ============================================================
# Privacy Tweaks, OpenSSH and Registry Modifications
# ============================================================
Write-Output "Privacy Tweaks, OpenSSH and Registry Modifications"
# Disable Python App Execution Aliases redirecting to MS Store
Write-Output "Disable Python App Execution Aliases redirecting to MS Store"
$aliasesPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Appx\AppExecutionAlias\SystemAlias\Microsoft.PythonSoftwareFoundation.Python.3.7_qbz5n2kfra8p0\python.exe"
$aliasesPath3 = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Appx\AppExecutionAlias\SystemAlias\Microsoft.PythonSoftwareFoundation.Python.3.7_qbz5n2kfra8p0\python3.exe"
if (Test-Path $aliasesPath) {  Set-ItemProperty -Path $aliasesPath -Name "State" -Value 0 -Force }
if (Test-Path $aliasesPath3) { Set-ItemProperty -Path $aliasesPath3 -Name "State" -Value 0 -Force }

# System UI, Telemetry and Widgets optimization
Write-Output "System UI, Telemetry and Widgets optimization"
$regTweaks = @(
    @("HKCU:\Software\Microsoft\Windows\CurrentVersion\UserProfileEngagement", "ScoobeSystemSettingEnabled", 0, "DWord"),
    @("HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager", "SubscribedContent-310093Enabled", 0, "DWord"),
    @("HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager", "SubscribedContent-338389Enabled", 0, "DWord"),
    @("HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager", "SubscribedContent-353696Enabled", 0, "DWord"),
    @("HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager", "SubscribedContent-353694Enabled", 0, "DWord"),
    @("HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager", "RemindMeLaterWithScreenOn", 0, "DWord"),
    @("HKCU:\Software\Microsoft\Windows\CurrentVersion\Privacy", "TailoredExperiencesWithDiagnosticDataEnabled", 0, "DWord"),
    @("HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced", "TaskbarAl", 0, "DWord"),
    @("HKCU:\Software\Microsoft\Windows\CurrentVersion\Search", "SearchboxTaskbarMode", 0, "DWord"),
    @("HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced", "TaskbarDa", 0, "DWord"),
    @("HKCU:\Software\Microsoft\Windows\CurrentVersion\Search", "BingSearchEnabled", 0, "DWord"),
    @("HKCU:\Software\Microsoft\Windows\CurrentVersion\Search", "CortanaConsent", 0, "DWord"),
    @("HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager", "SilentInstalledAppsEnabled", 0, "DWord"),
    @("HKLM:\Software\Policies\Microsoft\Windows\CloudContent", "DisableWindowsConsumerFeatures", 1, "DWord"),
    @("HKLM:\SOFTWARE\Policies\Microsoft\Dsh", "AllowNewsAndInterests", 0, "DWord")
)

foreach ($tweak in $regTweaks) {
    $path = $tweak[0]
    $name = $tweak[1]
    $value = $tweak[2]
    $type = $tweak[3]
    if (-not (Test-Path $path)) { New-Item -Path $path -Force | Out-Null }
    # Set-ItemProperty -Path $path -Name $name -Value $value -PropertyType $type -Force
    Set-ItemProperty -Path $path -Name $name -Value $value -Type $type -Force -ErrorAction Continue
}

# Windows 11 Classic Context Menu
Write-Output "Windows 11 Classic Context Menu"
$menuPath = "HKCU:\Software\Classes\CLSID\{5a2121c1-95a2-4599-9596-333f4c267061}\InprocServer32"
if (-not (Test-Path $menuPath)) { New-Item -Path $menuPath -Force | Out-Null }
Set-ItemProperty -Path $menuPath -Name "(Default)" -Value "" -Force

# OneDrive Removal
Write-Output "OneDrive Removal"
Stop-Process -Name "OneDrive" -Force -ErrorAction SilentlyContinue
if (Test-Path "$env:SystemRoot\System32\OneDriveSetup.exe") { Start-Process "$env:SystemRoot\System32\OneDriveSetup.exe" -ArgumentList "/uninstall" -Wait }
if (Test-Path "$env:SystemRoot\SysWOW64\OneDriveSetup.exe") { Start-Process "$env:SystemRoot\SysWOW64\OneDriveSetup.exe" -ArgumentList "/uninstall" -Wait }

# Native OpenSSH Server Feature Configuration
Write-Output "Native OpenSSH Server Feature Configuration"
$sshService = Get-WindowsCapability -Online | Where-Object { $_.Name -like "OpenSSH.Server*" }
if ($sshService.State -ne "Installed") { Add-WindowsCapability -Online -Name $sshService.Name | Out-Null }
Set-Service -Name sshd -StartupType Automatic
$firewallRule = Get-NetFirewallRule -Name "OpenSSH-Server-In-TCP" -ErrorAction SilentlyContinue
if ($firewallRule) { Enable-NetFirewallRule -Name "OpenSSH-Server-In-TCP" | Out-Null }
else { New-NetFirewallRule -Name "OpenSSH-Server-In-TCP-Custom" -DisplayName "OpenSSH SSH Server (Custom)" -Direction Inbound -Action Allow -Protocol TCP -LocalPort 22 | Out-Null }
if ((Get-Service -Name sshd).Status -ne "Running") { Start-Service -Name sshd }

# Restart File Explorer to apply UI tweaks instantly
Write-Output "Restart File Explorer to apply UI tweaks instantly"
Stop-Process -Name "explorer" -Force

### # ============================================================
### # Install UV, Python 3.9 and Python Launcher
### # ============================================================
### Write-Output "Install UV, Python 3.9 and Python Launcher"
### $uvDir = "C:\Program Files\uv"
### if (-not (Test-Path $uvDir)) { New-Item -ItemType Directory -Path $uvDir -Force | Out-Null }
### 
### if (Get-Command winget -ErrorAction SilentlyContinue) {
###     winget install --id Python.Launcher --silent --accept-source-agreements --accept-package-agreements
### } else {
###     # Official direct standalone Python Launcher package url
###     $pyLauncherUrl = 'https://python.org'
###     Invoke-WebRequest -Uri $pyLauncherUrl -OutFile "$env:TEMP\py_setup.exe"
###     if (Test-Path "$env:TEMP\py_setup.exe") {
###         Start-Process "$env:TEMP\py_setup.exe" -ArgumentList "/quiet InstallLauncherAllUsers=1 PrependPath=1 Include_test=0 Include_pip=0 Include_doc=0 Include_dev=0 Include_exe=0 Include_lib=0" -Wait
###     }
### }
### 
### # Strictly official line from astral.sh documentation
### $env:UV_INSTALL_DIR = $uvDir
### powershell -ExecutionPolicy Bypass -c "irm https://astral.sh | iex"
### 
### # Register UV folder in Machine PATH environment variable
### $sysPath = [System.Environment]::GetEnvironmentVariable('Path', 'Machine')
### if ($sysPath -notlike '*C:\Program Files\uv*') {
    ###     [System.Environment]::SetEnvironmentVariable('Path', ($sysPath + ';C:\Program Files\uv'), 'Machine')
### }
### $env:Path += ";$uvDir"
### 
### # Install Python 3.9 via UV tool chain
### $uvExe = "$uvDir\uv.exe"
### if (Test-Path $uvExe) {
###     & $uvExe python install 3.9
### }
### 
### # Locate deployed python.exe path inside UV structure to link it with py.exe launcher
### $uvPythonDir = "C:\ProgramData\uv\python"
### $pyExePath = (Get-ChildItem -Path $uvPythonDir -Filter "python.exe" -Recurse | Select-Object -First 1).FullName
### 
### if ($pyExePath) {
###     $pyDirPath = Split-Path -Path $pyExePath -Parent
###     $hklmCorePath = "HKLM:\SOFTWARE\Python\PythonCore\3.9"
###     $hklmInstallPath = "HKLM:\SOFTWARE\Python\PythonCore\3.9\InstallPath"
###     
###     if (-not (Test-Path $hklmCorePath)) { New-Item -Path $hklmCorePath -Force | Out-Null }
###     if (-not (Test-Path $hklmInstallPath)) { New-Item -Path $hklmInstallPath -Force | Out-Null }
###     
###     Set-ItemProperty -Path $hklmCorePath -Name "DisplayName" -Value "Python 3.9 (uv Shared)" -Force
###     Set-ItemProperty -Path $hklmInstallPath -Name "(Default)" -Value $pyDirPath -Force
###     Set-ItemProperty -Path $hklmInstallPath -Name "ExecutablePath" -Value $pyExePath -Force
### }
### 
### # Run final checks
### # ---------------------------------------------------------------------------- #
### if (Get-Command py -ErrorAction SilentlyContinue) {  & py -3.9 --version }
### elseif ($pyExePath) { & $pyExePath --version }

# powershell -ExecutionPolicy ByPass -c "$env:UV_INSTALL_DIR='C:\Program Files\uv'; irm https://astral.sh/uv/install.ps1 | iex"
echo "Install UV, Python 3.9 and Python Launcher - v2" 
$env:UV_INSTALL_DIR='C:\dev\uv'; irm https://astral.sh/uv/install.ps1 | iex
[Environment]::SetEnvironmentVariable("Path", $env:Path + ";C:\dev\uv", [EnvironmentVariableTarget]::Machine)
$env:Path += ";C:\dev\uv"

uv python install 3.9
### 

# ---------------------------------------------------------------------------- #
# ============================================================
# Package Deployment via Chocolatey
# ============================================================
Write-Output "Package Deployment via Chocolatey"
if (Get-Command choco -ErrorAction SilentlyContinue) {
    $apps1 = "googlechrome psmux 7zip.install gnuwin notepadplusplus fsviewer vlc conemu far doublecmd"
    $apps2 = "clink nano micro git tortoisegit stduviewer clipdiary clawPDF"
    $apps3 = "k-litecodecpackbasic opera libreoffice-fresh adobereader sumatrapdf firefox choco-cleaner"

    choco install -y ($apps1 -split " ")
    choco install -y ($apps2 -split " ")
    choco install -y ($apps3 -split " ")
}

# ============================================================
# Package Deployment via WinGet
# ============================================================
Write-Output "Package Deployment via WinGet"
if (Get-Command winget -ErrorAction SilentlyContinue) {
    winget install --id marlocarlo.pstop --silent --accept-source-agreements --accept-package-agreements
    winget install --id psmux.psnet --silent --accept-source-agreements --accept-package-agreements
}

# ============================================================
# OpenSSH Server Installation and Configuration
# ============================================================
Write-Output "Configuring OpenSSH Server..."

# 1. Check if OpenSSH Server is already installed
$sshService = Get-WindowsCapability -Online | Where-Object { $_.Name -like "OpenSSH.Server*" }

if ($sshService.State -ne "Installed") {
    Write-Output "Installing OpenSSH Server Windows capability..."
    # Install OpenSSH Server native component
    Add-WindowsCapability -Online -Name $sshService.Name | Out-Null
} else {
    Write-Output "[OK] OpenSSH Server is already installed."
}

# 2. Configure SSH service to start automatically with Windows
Set-Service -Name sshd -StartupType Automatic

# 3. Ensure the built-in Windows Firewall rule for SSH (Port 22) is enabled
$firewallRule = Get-NetFirewallRule -Name "OpenSSH-Server-In-TCP" -ErrorAction SilentlyContinue

if ($firewallRule) {
    Write-Output "Enabling built-in Windows Firewall rule for SSH..."
    Enable-NetFirewallRule -Name "OpenSSH-Server-In-TCP" | Out-Null
} else {
    Write-Output "Built-in rule not found. Creating a custom Firewall rule for Port 22..."
    # Fallback: create custom rule if the default one is missing
    New-NetFirewallRule -Name "OpenSSH-Server-In-TCP-Custom" -DisplayName "OpenSSH SSH Server (Custom)" -Description "Inbound rule for OpenSSH Daemon" -Direction Inbound -Action Allow -Protocol TCP -LocalPort 22 | Out-Null
}

# 4. Start the SSH daemon right now
if ((Get-Service -Name sshd).Status -ne "Running") {
    Write-Output "Starting OpenSSH Server service..."
    Start-Service -Name sshd
}

Write-Output "[OK] OpenSSH Server is successfully configured and running."

# ============================================================
# Final Step: Execution of External Debloat Script
# ============================================================
try {
    $debloatScript = Invoke-RestMethod -Uri 'https://githubusercontent.com' -ErrorAction Stop
    Invoke-Expression $debloatScript
} catch {
    $mirrorScript = Invoke-RestMethod -Uri 'https://raphi.re'
    Invoke-Expression $mirrorScript
}

