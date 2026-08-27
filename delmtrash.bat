@echo off
chcp 65001 >nul

:: 1. ПРОВЕРКА ПРАВ АДМИНИСТРАТОРА
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [!] ОШИБКА: Этот скрипт необходимо запускать ОТ ИМЕНИ АДМИНИСТРАТОРА.
    echo Перезапустите батник правой кнопкой мыши -> Запуск от имени администратора.
    pause
    exit /b
)

echo ============================================================
echo remove Bloatware...
echo ============================================================
echo Отключение рекламы, экрана приветствия, поиск влево и скрытие поиска...

:: Запуск оптимизированного PowerShell-блока (Edge не трогаем, OneDrive удаляется)
powershell -NoProfile -ExecutionPolicy Bypass -Command "^
    $apps = @('*3dbuilder*', '*windowscommunicationsapps*', '*officehub*', '*people*', '*windowsphone*', '*bingsports*', '*bingweather*', '*xboxapp*'); ^
    foreach ($app in $apps) { ^
        Get-AppxPackage -AllUsers $app | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue; ^
        Get-AppXProvisionedPackage -Online | Where-Object {$_.DisplayName -like $app} | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue; ^
    }^
"

:: 1. Отключение экрана приветствия «Давайте познакомимся с настройками...» и запрет передачи персональных данных
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\UserProfileEngagement" /v "ScoobeSystemSettingEnabled" /t REG_DWORD /d 0 /f >nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-310093Enabled" /t REG_DWORD /d 0 /f >nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-338389Enabled" /t REG_DWORD /d 0 /f >nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-353696Enabled" /t REG_DWORD /d 0 /f >nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-353694Enabled" /t REG_DWORD /d 0 /f >nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "RemindMeLaterWithScreenOn" /t REG_DWORD /d 0 /f >nul

:: Телеметрия персонализации (галочки в запрет)
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Privacy" /v "TailoredExperiencesWithDiagnosticDataEnabled" /t REG_DWORD /d 0 /f >nul

:: 2. Перенос Меню Пуск в левый угол (для Windows 11)
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "TaskbarAl" /t REG_DWORD /d 0 /f >nul

:: 3. Полное скрытие строки/иконки поиска из панели задач
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v "SearchboxTaskbarMode" /t REG_DWORD /d 0 /f >nul

:: 4. Удаление OneDrive из системы (если он остался в фоне)
taskkill /f /im OneDrive.exe >nul 2>&1
if exist "%SystemRoot%\System32\OneDriveSetup.exe" start "" /wait "%SystemRoot%\System32\OneDriveSetup.exe" /uninstall
if exist "%SystemRoot%\SysWOW64\OneDriveSetup.exe" start "" /wait "%SystemRoot%\SysWOW64\OneDriveSetup.exe" /uninstall

:: Перезапускаем проводник, чтобы применить настройки интерфейса мгновенно
taskkill /f /im explorer.exe >nul 2>&1
start explorer.exe

echo Очистка и конфигурация интерфейса завершены!



:: old ----
REM powershell -ExecutionPolicy Bypass -command "Get-AppxPackage -allusers Microsoft.549981C3F5F10 | Remove-AppxPackage"

REM powershell -ExecutionPolicy Bypass -command "Get-AppxPackage *3dbuilder* | Remove-AppxPackage"
REM powershell -ExecutionPolicy Bypass -command "Get-AppxPackage *windowscommunicationsapps* | Remove-AppxPackage"
REM powershell -ExecutionPolicy Bypass -command "Get-AppxPackage *officehub* | Remove-AppxPackage"
REM powershell -ExecutionPolicy Bypass -command "Get-AppxPackage *people* | Remove-AppxPackage"


REM powershell -ExecutionPolicy Bypass -command "Get-AppxPackage *windowsphone* | Remove-AppxPackage"
REM @rem powershell -ExecutionPolicy Bypass -command "Get-AppxPackage *photos* | Remove-AppxPackage"
REM @rem powershell -ExecutionPolicy Bypass -command "Get-AppxPackage *windowsstore* | Remove-AppxPackage"
REM powershell -ExecutionPolicy Bypass -command "Get-AppxPackage *bingsports* | Remove-AppxPackage"
REM @rem powershell -ExecutionPolicy Bypass -command "Get-AppxPackage *soundrecorder* | Remove-AppxPackage"
REM powershell -ExecutionPolicy Bypass -command "Get-AppxPackage *bingweather* | Remove-AppxPackage"
REM powershell -ExecutionPolicy Bypass -command "Get-AppxPackage *xboxapp* | Remove-AppxPackage"

REM @rem # Uninstalling for New Users #Even though youТve uninstalled all the apps for all the users, every time you create a new user, the default apps will be reinstalled for that user. You can prevent this default action by executing the following command in the Powershell.

REM @rem -can delete notepad- powershell -ExecutionPolicy Bypass -command "Get-AppXProvisionedPackage -online | Remove-AppxProvisionedPackage -online"
