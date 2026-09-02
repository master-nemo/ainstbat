@rem 1. ПРОВЕРКА ПРАВ АДМИНИСТРАТОРА
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

@rem 1. Chocolatey via WinGet
echo Chocolatey via WinGet...

@REM where winget >nul 2>nul
@REM if %errorLevel% == 0 (
@REM     echo Installing Chocolatey via WinGet...
@REM     winget install --id chocolatey.chocolatey --silent --accept-source-agreements --accept-package-agreements --disable-interactivity >> "%LOG_FILE%" 2>&1
@REM ) else (
@REM     echo [!] WinGet not found. Installing Chocolatey natively via PowerShell...
@REM     powershell -NoProfile -ExecutionPolicy Bypass -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org'))" 
@REM )

where winget >nul 2>nul
if %errorLevel% == 0 (
    echo Installing Chocolatey via WinGet...
    winget install --id chocolatey.chocolatey --silent --accept-source-agreements --accept-package-agreements --disable-interactivity >> "%LOG_FILE%" 2>&1
) else (
    echo [!] WinGet not found. Installing Chocolatey natively via PowerShell...
    powershell -NoProfile -ExecutionPolicy Bypass -Command "[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))" 
    @REM powershell -NoProfile -ExecutionPolicy Bypass -Command "Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))" 
)

echo xxxxxxxxxxxxx
call %ProgramData%\chocolatey\bin\refreshenv
echo yyyyyyyyyyyyy

choco -?
echo zzzzzzzzzzzzz
@REM echo ===(& choco -?)===

@REM @rem 2. Установка Scoop через PowerShell
@REM echo Scoop...
@REM :: (no pipe ver of std way: Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
@REM powershell -NoProfile -ExecutionPolicy Bypass -Command "[Net.ServicePointManager]::SecurityProtocol = 3072; [scriptblock]::Create((Invoke-RestMethod https://get.scoop.sh)).Invoke()"


@REM $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
@REM echo ===(& scoop -?)===



pause
