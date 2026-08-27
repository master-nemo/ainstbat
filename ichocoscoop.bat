@echo off
chcp 65001 >nul
cls

echo ============================================================
echo [1/4] Установка менеджеров пакетов (Chocolatey и Scoop)...
echo ============================================================

winget install --id chocolatey.chocolatey --silent --accept-source-agreements --accept-package-agreements --disable-interactivity

powershell -NoProfile -ExecutionPolicy Bypass -Command "Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force; [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-RestMethod -Uri https://scoop.sh | Invoke-Expression"

echo.
echo ============================================================
echo [2/4] Обновление переменных окружения (Перезапуск PATH)...
echo ============================================================
call "%ProgramData%\chocolatey\bin\refreshenv.cmd"

echo.
echo ============================================================
echo [3/4] Массовая установка программ через Chocolatey...
echo ============================================================
choco install -y adobereader googlechrome far 7zip.install gnuwin notepadplusplus conemu firefox opera git tortoisegit stduviewer clipdiary libreoffice-fresh pdfcreator choco-cleaner vlc k-litecodecpackbasic fsviewer

echo.
echo ============================================================
echo [4/4] Установка специфичных утилит через WinGet...
echo ============================================================

winget install --id marlocarlo.pstop --silent --accept-source-agreements --accept-package-agreements
winget install --id psmux.psnet --silent --accept-source-agreements --accept-package-agreements

call "%ProgramData%\chocolatey\bin\refreshenv.cmd"

echo.
echo ============================================================
echo done

pause

