@echo off
chcp 65001 >nul
cls

:: 1. ПРОВЕРКА ПРАВ АДМИНИСТРАТОРА
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [!] ОШИБКА: Этот скрипт необходимо запускать ОТ ИМЕНИ АДМИНИСТРАТОРА.
    echo Перезапустите батник правой кнопкой мыши -> Запуск от имени администратора.
    pause
    exit /b
)

echo ============================================================
echo + uv py 
echo ============================================================
echo ============================================================

@echo off
setlocal enabledelayedexpansion

:: 3. ГЛОБАЛЬНАЯ УСТАНОВКА UV ДЛЯ ВСЕХ ПОЛЬЗОВАТЕЛЕЙ
echo Установка утилиты UV глобально для всех пользователей...
set "UV_DIR=C:\Program Files\uv"
if not exist "%UV_DIR%" mkdir "%UV_DIR%"

:: Скачивание и установка uv в общую папку
powershell -NoProfile -ExecutionPolicy Bypass -Command "$env:UV_INSTALL_DIR='%UV_DIR%'; [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; irm https://astral.sh/uv/install.ps1 | iex"

:: Добавление папки uv в системный PATH (если её там еще нет)
set "PATH_TO_ADD=%UV_DIR%"
powershell -NoProfile -ExecutionPolicy Bypass -Command "$sysPath = [Environment]::GetEnvironmentVariable('Path', 'Machine'); if ($sysPath -notlike '*%PATH_TO_ADD%*') { [Environment]::SetEnvironmentVariable('Path', $sysPath + ';%PATH_TO_ADD%', 'Machine') }"

:: Обновляем PATH в текущей сессии батника
set "PATH=%PATH%;%UV_DIR%"

echo.
echo --------------------------------------------------
echo.

:: 4. УСТАНОВКА ПОСЛЕДНЕГО PYTHON 3.9.* ЧЕРЕЗ UV
echo [3/4] + Python 3.9.* via UV...
:: Принудительно ставим в общую директорию Program Data, чтобы было доступно всем
set "UV_PYTHON_INSTALL_DIR=C:\ProgramData\uv\python"
if not exist "%UV_PYTHON_INSTALL_DIR%" mkdir "%UV_PYTHON_INSTALL_DIR%"

"%UV_DIR%\uv.exe" python install 3.9

echo.
echo --------------------------------------------------
echo.

:: 5. ИНТЕГРАЦИЯ С PY.EXE (РЕГИСТРАЦИЯ В РЕЕСТРЕ)
echo [4/4] Python 3.9 -> py.exe...

:: Находим точный путь к установленному python.exe внутри папки uv
for /f "delims=" %%i in ('dir "%UV_PYTHON_INSTALL_DIR%\*python.exe" /s /b 2^>nul') do (
    set "PY_EXE_PATH=%%i"
    goto :found_python
)

:found_python
if "%PY_EXE_PATH%"=="" (
    echo [!] Ошибка: Не удалось найти скачанный python.exe в директории %UV_PYTHON_INSTALL_DIR%
    goto :end
)

:: Получаем только папку, где лежит python.exe
for %%F in ("%PY_EXE_PATH%") do set "PY_DIR_PATH=%%~dpF"
:: Убираем обратный слэш на конце для корректности путей реестра
if "%PY_DIR_PATH:~-1%"=="\" set "PY_DIR_PATH=%PY_DIR_PATH:~0,-1%"

echo Найден Python по адресу: %PY_EXE_PATH%
echo Регистрируем в HKLM для py.exe...

:: Прописываем ветки реестра Core, чтобы py.exe распознал версию 3.9
reg add "HKLM\SOFTWARE\Python\PythonCore\3.9" /v "DisplayName" /t REG_SZ /d "Python 3.9 (uv Shared)" /f >nul
reg add "HKLM\SOFTWARE\Python\PythonCore\3.9\InstallPath" /t REG_SZ /d "%PY_DIR_PATH%" /f >nul
reg add "HKLM\SOFTWARE\Python\PythonCore\3.9\InstallPath" /v "ExecutablePath" /t REG_SZ /d "%PY_EXE_PATH%" /f >nul

echo [+] Успешно! Проверяем вызов через py.exe:
py -3.9 --version

:end
echo.
echo Все операции завершены успешно.
pause
