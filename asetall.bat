@REM @echo off
chcp 65001 >nul

net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [!] ОШИБКА: Этот скрипт необходимо запускать ОТ ИМЕНИ АДМИНИСТРАТОРА.
    echo Перезапустите батник правой кнопкой мыши -> Запуск от имени администратора.
    pause
    exit /b
)

set "LOG_FILE=%USERPROFILE%\Desktop\install_report.txt"
echo Инициализация установки: %date% %time% > "%LOG_FILE%"

echo ============================================================
echo [1/5] (Chocolatey и Scoop)
echo ============================================================

echo Chocolatey via WinGet...
winget install --id chocolatey.chocolatey --silent --accept-source-agreements --accept-package-agreements --disable-interactivity >> "%LOG_FILE%" 2>&1

echo Scoop...
powershell -NoProfile -ExecutionPolicy Bypass -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; (Invoke-RestMethod -Uri 'https://scoop.sh').Invoke()" 

echo.
echo ============================================================
echo [2/5] ensure (PATH)
echo ============================================================

if exist "%ProgramData%\chocolatey\bin\refreshenv.cmd" (call "%ProgramData%\chocolatey\bin\refreshenv.cmd")

where choco.exe >nul 2>nul
if errorlevel 1 (
    echo [!] no choco in session.
    echo force set path via PowerShell API...
    
    powershell -NoProfile -Command "$oldPath = [Environment]::GetEnvironmentVariable('Path', 'Machine'); if ($oldPath -notlike '*chocolatey\bin*') { [Environment]::SetEnvironmentVariable('Path', $oldPath + ';C:\ProgramData\chocolatey\bin', 'Machine') }"
    
    if exist "%ProgramData%\chocolatey\bin\refreshenv.cmd" call "%ProgramData%\chocolatey\bin\refreshenv.cmd"
) else ( echo [OK] Окружение Chocolatey успешно инициализировано. )

echo.
echo ============================================================
echo [3/5] install apps via Chocolatey
echo ============================================================
echo (log see in log)...
echo.


set "CHOCO_APPS_1=adobereader googlechrome far 7zip.install gnuwin notepadplusplus conemu firefox clink"
set "CHOCO_APPS_2=opera git tortoisegit stduviewer clipdiary libreoffice-fresh pdfcreator"
set "CHOCO_APPS_3=choco-cleaner vlc k-litecodecpackbasic fsviewer doublecmd"

echo install group 1: %CHOCO_APPS_1%
choco install -y %CHOCO_APPS_1%
if errorlevel 1 echo [ВНИМАНИЕ] Ошибка при установке некоторых программ из Группы 1. Скрипт продолжает работу. >> "%LOG_FILE%"

echo.
echo install group 2: %CHOCO_APPS_2%
choco install -y %CHOCO_APPS_2%
if errorlevel 1 echo [ВНИМАНИЕ] Ошибка при установке некоторых программ из Группы 2. Скрипт продолжает работу. >> "%LOG_FILE%"

echo.
echo install group 3: %CHOCO_APPS_3%
choco install -y %CHOCO_APPS_3%
if errorlevel 1 echo [ВНИМАНИЕ] Ошибка при установке некоторых программ из Группы 3. Скрипт продолжает работу. >> "%LOG_FILE%"

echo.
echo ============================================================
echo [4/5] install via WinGet
echo ============================================================

if exist "%ProgramData%\chocolatey\bin\refreshenv.cmd" call "%ProgramData%\chocolatey\bin\refreshenv.cmd"

echo Установка marlocarlo.pstop...
winget install --id marlocarlo.pstop --silent --accept-source-agreements --accept-package-agreements >> "%LOG_FILE%" 2>&1
if errorlevel 1 echo [ОШИБКА] Не удалось установить marlocarlo.pstop через WinGet >> "%LOG_FILE%"

echo Установка psmux.psnet...
winget install --id psmux.psnet --silent --accept-source-agreements --accept-package-agreements >> "%LOG_FILE%" 2>&1
if errorlevel 1 echo [ОШИБКА] Не удалось установить psmux.psnet через WinGet >> "%LOG_FILE%"

echo.
echo ============================================================
echo [5/5] prep
echo ============================================================

if exist "%ProgramData%\chocolatey\bin\refreshenv.cmd" call "%ProgramData%\chocolatey\bin\refreshenv.cmd"

echo.
echo done!
echo log see in :DESKTOP install_report.txt
pause

echo ============================================================
echo ============================================================
echo remove Bloatware...
echo ============================================================
echo Отключение рекламы, экрана приветствия, поиск влево и скрытие поиска...

powershell -NoProfile -ExecutionPolicy Bypass -Command '$apps = @("*3dbuilder*", "*windowscommunicationsapps*", "*officehub*", "*people*", "*windowsphone*", "*bingsports*", "*bingweather*", "*xboxapp*"); foreach ($app in $apps) { Get-AppxPackage -AllUsers $app | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue; Get-AppXProvisionedPackage -Online | Where-Object {$_.DisplayName -like $app} | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue }'

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

echo Очистка и конфигурация интерфейса завершены!
echo.
pause

echo ============================================================


:end
echo.
echo Все операции завершены успешно.
pause
