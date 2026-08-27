@echo off
chcp 65001 >nul

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

echo.
echo ============================================================
echo [2/5] ensure (PATH)
echo ============================================================

if exist "%ProgramData%\chocolatey\bin\refreshenv.cmd" (call "%ProgramData%\chocolatey\bin\refreshenv.cmd")

where choco.exe >nul 2>nul
if errorlevel 1 (
    echo [!] no choco in session.
    echo force set path via PowerShell API...
    
    @rem Безопасный метод добавления в реестр БЕЗ лимита в 1024 символа (замена опасного setx)
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

@rem Запуск оптимизированного PowerShell-блока (Edge не трогаем, OneDrive удаляется)
REM powershell -NoProfile -ExecutionPolicy Bypass -Command "^
    REM $apps = @('*3dbuilder*', '*windowscommunicationsapps*', '*officehub*', '*people*', '*windowsphone*', '*bingsports*', '*bingweather*', '*xboxapp*'); ^
    REM foreach ($app in $apps) { ^
        REM Get-AppxPackage -AllUsers $app | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue; ^
        REM Get-AppXProvisionedPackage -Online | Where-Object {$_.DisplayName -like $app} | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue; ^
    REM }^
REM "

powershell -NoProfile -ExecutionPolicy Bypass -Command "$apps = @('*3dbuilder*', '*windowscommunicationsapps*', '*officehub*', '*people*', '*windowsphone*', '*bingsports*', '*bingweather*', '*xboxapp*'); foreach ($app in $apps) { Get-AppxPackage -AllUsers $app | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue; Get-AppXProvisionedPackage -Online | Where-Object {$_.DisplayName -like $app} | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue }"

@rem 1. Отключение экрана приветствия Давайте познакомимся с настройками... и запрет передачи персональных данных
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\UserProfileEngagement" /v "ScoobeSystemSettingEnabled" /t REG_DWORD /d 0 /f >nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-310093Enabled" /t REG_DWORD /d 0 /f >nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-338389Enabled" /t REG_DWORD /d 0 /f >nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-353696Enabled" /t REG_DWORD /d 0 /f >nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-353694Enabled" /t REG_DWORD /d 0 /f >nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "RemindMeLaterWithScreenOn" /t REG_DWORD /d 0 /f >nul

@rem Телеметрия персонализации (галочки в запрет)
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Privacy" /v "TailoredExperiencesWithDiagnosticDataEnabled" /t REG_DWORD /d 0 /f >nul

@rem 2. Перенос Меню Пуск в левый угол (для Windows 11)
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "TaskbarAl" /t REG_DWORD /d 0 /f >nul

@rem 3. Полное скрытие строки/иконки поиска из панели задач
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v "SearchboxTaskbarMode" /t REG_DWORD /d 0 /f >nul

@rem 4.  Полное отключение Виджетов (Новости, погода) на панели задач
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "TaskbarDa" /t REG_DWORD /d 0 /f >nul

@rem 5.  Отключение веб-поиска Bing в меню Пуск (ускоряет поиск и убирает мусор)
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v "BingSearchEnabled" /t REG_DWORD /d 0 /f >nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v "CortanaConsent" /t REG_DWORD /d 0 /f >nul

@rem 6. НОВОЕ: Запрет автоустановки сторонних приложений и игр (Candy Crush, партнерский софт)
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SilentInstalledAppsEnabled" /t REG_DWORD /d 0 /f >nul
reg add "HKLM\Software\Policies\Microsoft\Windows\CloudContent" /v "DisableWindowsConsumerFeatures" /t REG_DWORD /d 1 /f >nul

@rem 7. НОВОЕ: Возврат классического контекстного меню (Windows 10 style) для Windows 11
reg add "HKCU\Software\Classes\CLSID\{5a2121c1-95a2-4599-9596-333f4c267061}\InprocServer32" /ve /t REG_SZ /d "" /f >nul

@rem 8. Удаление OneDrive из системы (если он остался в фоне)
taskkill /f /im OneDrive.exe >nul 2>&1
if exist "%SystemRoot%\System32\OneDriveSetup.exe" start "" /wait "%SystemRoot%\System32\OneDriveSetup.exe" /uninstall
if exist "%SystemRoot%\SysWOW64\OneDriveSetup.exe" start "" /wait "%SystemRoot%\SysWOW64\OneDriveSetup.exe" /uninstall

@rem Перезапускаем проводник, чтобы применить настройки интерфейса мгновенно
taskkill /f /im explorer.exe >nul 2>&1
start explorer.exe

echo Очистка и конфигурация интерфейса завершены!
echo.
pause

echo ============================================================

echo ============================================================
echo + uv py 
echo ============================================================
echo ============================================================


setlocal enabledelayedexpansion

@rem 3. ГЛОБАЛЬНАЯ УСТАНОВКА UV ДЛЯ ВСЕХ ПОЛЬЗОВАТЕЛЕЙ
echo Установка утилиты UV глобально для всех пользователей...
set "UV_DIR=C:\Program Files\uv"
if not exist "%UV_DIR%" mkdir "%UV_DIR%"

@rem Скачивание и установка uv в общую папку
powershell -NoProfile -ExecutionPolicy Bypass -Command "$env:UV_INSTALL_DIR='C:\Program Files\uv'; [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-RestMethod -Uri 'https://astral.sh' | Invoke-Expression"

@rem Добавление папки uv в системный PATH (если её там еще нет)
REM set "PATH_TO_ADD=%UV_DIR%"
REM powershell -NoProfile -ExecutionPolicy Bypass -Command "$sysPath = [Environment]::GetEnvironmentVariable('Path', 'Machine'); if ($sysPath -notlike '*%PATH_TO_ADD%*') { [Environment]::SetEnvironmentVariable('Path', $sysPath + ';%PATH_TO_ADD%', 'Machine') }"
powershell -NoProfile -Command "$sysPath = [System.Environment]::GetEnvironmentVariable('Path', 'Machine'); if ($sysPath -notlike '*C:\Program Files\uv*') { [System.Environment]::SetEnvironmentVariable('Path', $sysPath + ';C:\Program Files\uv', 'Machine') }"

@rem Обновляем PATH в текущей сессии батника
set "PATH=%PATH%;%UV_DIR%"

echo.
echo --------------------------------------------------
echo.

@rem 4. УСТАНОВКА ПОСЛЕДНЕГО PYTHON 3.9.* ЧЕРЕЗ UV
echo [3/4] + Python 3.9.* via UV...
@rem Принудительно ставим в общую директорию Program Data, чтобы было доступно всем
set "UV_PYTHON_INSTALL_DIR=C:\ProgramData\uv\python"
if not exist "%UV_PYTHON_INSTALL_DIR%" mkdir "%UV_PYTHON_INSTALL_DIR%"

"%UV_DIR%\uv.exe" python install 3.9

echo.
echo --------------------------------------------------
echo.

@rem 5. ИНТЕГРАЦИЯ С PY.EXE (РЕГИСТРАЦИЯ В РЕЕСТРЕ)
echo [4/4] Python 3.9 -> py.exe...

@rem Находим точный путь к установленному python.exe внутри папки uv
for /f "delims=" %%i in ('dir "%UV_PYTHON_INSTALL_DIR%\*python.exe" /s /b 2^>nul') do (
    set "PY_EXE_PATH=%%i"
    goto :found_python
)

:found_python
if "%PY_EXE_PATH%"=="" (
    echo [!] Ошибка: Не удалось найти скачанный python.exe в директории %UV_PYTHON_INSTALL_DIR%
    goto :end
)

@rem Получаем только папку, где лежит python.exe
for %%F in ("%PY_EXE_PATH%") do set "PY_DIR_PATH=%%~dpF"
@rem Убираем обратный слэш на конце для корректности путей реестра
if "%PY_DIR_PATH:~-1%"=="\" set "PY_DIR_PATH=%PY_DIR_PATH:~0,-1%"

echo Найден Python по адресу: %PY_EXE_PATH%
echo Регистрируем в HKLM для py.exe...

@rem Прописываем ветки реестра Core, чтобы py.exe распознал версию 3.9
reg add "HKLM\SOFTWARE\Python\PythonCore\3.9" /v "DisplayName" /t REG_SZ /d "Python 3.9 (uv Shared)" /f >nul
reg add "HKLM\SOFTWARE\Python\PythonCore\3.9\InstallPath" /t REG_SZ /d "%PY_DIR_PATH%" /f >nul
reg add "HKLM\SOFTWARE\Python\PythonCore\3.9\InstallPath" /v "ExecutablePath" /t REG_SZ /d "%PY_EXE_PATH%" /f >nul

echo [+] Успешно! Проверяем вызов через py.exe:
py -3.9 --version

:end
echo.
echo Все операции завершены успешно.
pause
