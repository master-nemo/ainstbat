@echo off
chcp 65001 >nul

net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [!] ERROR: Please run this script as ADMINISTRATOR.
    pause
    exit /b
)

set "LOG_FILE=%USERPROFILE%\Desktop\install_report.txt"
echo Initialization: %date% %time% > "%LOG_FILE%"

echo ============================================================
echo [1/6] Chocolatey and Scoop
echo ============================================================

echo Chocolatey via WinGet...
winget install --id chocolatey.chocolatey --silent --accept-source-agreements --accept-package-agreements --disable-interactivity >> "%LOG_FILE%" 2>&1

echo Scoop...
powershell -NoProfile -ExecutionPolicy Bypass -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; (Invoke-RestMethod -Uri 'https://scoop.sh').Invoke()" >> "%LOG_FILE%" 2>&1

echo.
echo ============================================================
echo [2/6] Ensure PATH
echo ============================================================

if exist "%ProgramData%\chocolatey\bin\refreshenv.cmd" (call "%ProgramData%\chocolatey\bin\refreshenv.cmd")

where choco.exe >nul 2>nul
if errorlevel 1 (
    echo [!] No choco in session. Setting path via PowerShell...
    powershell -NoProfile -Command "$oldPath=[System.Environment]::GetEnvironmentVariable('Path','Machine'); if($oldPath -notlike '*chocolatey\bin*'){$( [System.Environment]::SetEnvironmentVariable('Path',$oldPath+';C:\ProgramData\chocolatey\bin','Machine') )}"
    if exist "%ProgramData%\chocolatey\bin\refreshenv.cmd" call "%ProgramData%\chocolatey\bin\refreshenv.cmd"
) else (
    echo [OK] Chocolatey environment initialized.
)

echo.
echo ============================================================
echo [3/6] Install apps via Chocolatey
echo ============================================================
echo Installing apps, please wait...

set "APPS_1=adobereader googlechrome far 7zip.install gnuwin notepadplusplus conemu firefox clink"
set "APPS_2=opera git tortoisegit stduviewer clipdiary libreoffice-fresh pdfcreator"
set "APPS_3=choco-cleaner vlc k-litecodecpackbasic fsviewer doublecmd"

choco install -y %APPS_1%
if errorlevel 1 echo [WARN] Group 1 install error >> "%LOG_FILE%"

choco install -y %APPS_2%
if errorlevel 1 echo [WARN] Group 2 install error >> "%LOG_FILE%"

choco install -y %APPS_3%
if errorlevel 1 echo [WARN] Group 3 install error >> "%LOG_FILE%"

echo.
echo ============================================================
echo [4/6] Install via WinGet
echo ============================================================

if exist "%ProgramData%\chocolatey\bin\refreshenv.cmd" call "%ProgramData%\chocolatey\bin\refreshenv.cmd"

winget install --id marlocarlo.pstop --silent --accept-source-agreements --accept-package-agreements >> "%LOG_FILE%" 2>&1
winget install --id psmux.psnet --silent --accept-source-agreements --accept-package-agreements >> "%LOG_FILE%" 2>&1

echo.
echo ============================================================
echo [5/6] Remove Bloatware and Tweaks
echo ============================================================
echo Cleaning system...

powershell -NoProfile -ExecutionPolicy Bypass -Command "$apps=@('*3dbuilder*','*windowscommunicationsapps*','*officehub*','*people*','*windowsphone*','*bingsports*','*bingweather*','*xboxapp*'); foreach($app in $apps){Get-AppxPackage -AllUsers $app | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue; Get-AppXProvisionedPackage -Online | Where-Object {$_.DisplayName -like $app} | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue}"

reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\UserProfileEngagement" /v "ScoobeSystemSettingEnabled" /t REG_DWORD /d 0 /f >nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-310093Enabled" /t REG_DWORD /d 0 /f >nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-338389Enabled" /t REG_DWORD /d 0 /f >nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-353696Enabled" /t REG_DWORD /d 0 /f >nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-353694Enabled" /t REG_DWORD /d 0 /f >nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "RemindMeLaterWithScreenOn" /t REG_DWORD /d 0 /f >nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Privacy" /v "TailoredExperiencesWithDiagnosticDataEnabled" /t REG_DWORD /d 0 /f >nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "TaskbarAl" /t REG_DWORD /d 0 /f >nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v "SearchboxTaskbarMode" /t REG_DWORD /d 0 /f >nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "TaskbarDa" /t REG_DWORD /d 0 /f >nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v "BingSearchEnabled" /t REG_DWORD /d 0 /f >nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v "CortanaConsent" /t REG_DWORD /d 0 /f >nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SilentInstalledAppsEnabled" /t REG_DWORD /d 0 /f >nul
reg add "HKLM\Software\Policies\Microsoft\Windows\CloudContent" /v "DisableWindowsConsumerFeatures" /t REG_DWORD /d 1 /f >nul
reg add "HKCU\Software\Classes\CLSID\{5a2121c1-95a2-4599-9596-333f4c267061}\InprocServer32" /ve /t REG_SZ /d "" /f >nul

taskkill /f /im OneDrive.exe >nul 2>&1
if exist "%SystemRoot%\System32\OneDriveSetup.exe" start "" /wait "%SystemRoot%\System32\OneDriveSetup.exe" /uninstall
if exist "%SystemRoot%\SysWOW64\OneDriveSetup.exe" start "" /wait "%SystemRoot%\SysWOW64\OneDriveSetup.exe" /uninstall

taskkill /f /im explorer.exe >nul 2>&1
start explorer.exe

echo.
echo ============================================================
echo [6/6] Install UV and Python 3.9 with py.exe Launcher
echo ============================================================

set "UV_DIR=C:\Program Files\uv"
if not exist "%UV_DIR%" mkdir "%UV_DIR%"

echo Installing official Python Launcher (py.exe) via WinGet...
winget install --id Python.Launcher --silent --accept-source-agreements --accept-package-agreements >> "%LOG_FILE%" 2>&1

echo Installing global UV for all users...
powershell -NoProfile -ExecutionPolicy Bypass -Command "$env:UV_INSTALL_DIR='C:\Program Files\uv'; [Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12; (Invoke-RestMethod -Uri 'https://astral.sh').Invoke()" >> "%LOG_FILE%" 2>&1

echo Registering UV in System PATH...
powershell -NoProfile -Command "$sysPath=[System.Environment]::GetEnvironmentVariable('Path','Machine'); if($sysPath -notlike '*C:\Program Files\uv*'){$([System.Environment]::SetEnvironmentVariable('Path',$sysPath+';C:\Program Files\uv','Machine'))}"

set "PATH=%PATH%;%UV_DIR%"

echo Installing latest Python 3.9.* via UV...
set "UV_PYTHON_INSTALL_DIR=C:\ProgramData\uv\python"
if not exist "%UV_PYTHON_INSTALL_DIR%" mkdir "%UV_PYTHON_INSTALL_DIR%"
"%UV_DIR%\uv.exe" python install 3.9

echo Registering UV Python in HKLM for py.exe launcher...
set "PY_EXE_PATH="
for /f "delims=" %%i in ('dir "C:\ProgramData\uv\python\*python.exe" /s /b 2^>nul') do (
    set "PY_EXE_PATH=%%i"
    goto :found_python
)

:found_python
if "%PY_EXE_PATH%"=="" (
    echo [!] Error: Python.exe not found in %UV_PYTHON_INSTALL_DIR%
    goto :end
)

for %%F in ("%PY_EXE_PATH%") do set "PY_DIR_PATH=%%~dpF"
if "%PY_DIR_PATH:~-1%"=="\" set "PY_DIR_PATH=%PY_DIR_PATH:~0,-1%"

reg add "HKLM\SOFTWARE\Python\PythonCore\3.9" /v "DisplayName" /t REG_SZ /d "Python 3.9 (uv Shared)" /f >nul
reg add "HKLM\SOFTWARE\Python\PythonCore\3.9\InstallPath" /t REG_SZ /d "%PY_DIR_PATH%" /f >nul
reg add "HKLM\SOFTWARE\Python\PythonCore\3.9\InstallPath" /v "ExecutablePath" /t REG_SZ /d "%PY_EXE_PATH%" /f >nul

echo [+] Verification of py.exe launcher:
py -3.9 --version

:end
echo.
echo ============================================================
echo All operations completed successfully!
echo Log file saved to Desktop as install_report.txt
echo ============================================================
pause
