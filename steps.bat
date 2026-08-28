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
winget install --id chocolatey.chocolatey --silent --accept-source-agreements --accept-package-agreements --disable-interactivity >> "%LOG_FILE%" 2>&1

@rem 2. Установка Scoop через PowerShell
echo Scoop...
powershell -NoProfile -ExecutionPolicy Bypass -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-RestMethod -Uri 'https://scoop.sh' ^| Invoke-Expression" >> "%LOG_FILE%" 2>&1
