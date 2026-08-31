# ==============================================================================
# Скрипт-посредник для скачивания и запуска основного пакета
# Вызов: irm https://raw.githubusercontent.com/master-nemo/ainstbat/refs/heads/main/a1.ps1 | iex
# Вызов: irm clck.ru/3VTU4Q | iex
# Вызов: irm clck.ru/3VTVpT | iex
# Вызов: irm goo.su/IL2OdTp | iex
# ==============================================================================
$ErrorActionPreference = "Stop"
$zipUrl = "https://github.com/master-nemo/ainstbat/archive/refs/heads/main.zip" 

# Write-Host "============================================================" -ForegroundColor Cyan
# Write-Host "[Посредник] Проверка сетевого подключения..." -ForegroundColor Cyan
# Write-Host "============================================================" -ForegroundColor Cyan

# # 1. Нативная проверка сети (до 20 секунд ожидания)
# $online = $false
# for ($i = 1; $i -le 4; $i++) {
    # if (Test-Connection -ComputerName 1.1.1.1 -Count 1 -Quiet) { $online = $true; break }
    # Write-Host "[!] Сеть недоступна. Попытка $i из 4. Ожидание..." -ForegroundColor Yellow
    # Start-Sleep -Seconds 5
# }
# if (-not $online) { Write-Error "Интернет-соединение отсутствует! Выход."; exit }
# Write-Host "[OK] Интернет активен.`n" -ForegroundColor Green

# 2. Подготовка целевой директории C:\1\instbat (устойчивая к повторным запускам)
$targetDir = "C:\1\instbat"
if (Test-Path $targetDir) {
    Write-Host "[!] Обнаружена старая папка. Очистка директории..." -ForegroundColor Yellow
    Remove-Item -Path $targetDir -Recurse -Force -ErrorAction SilentlyContinue
}
$null = New-Item -ItemType Directory -Path $targetDir -Force

# Переходим в созданную рабочую папку
Set-Location -Path $targetDir

# 3. Скачивание ZIP-архива по адресу URL1
Write-Host "[*] Скачивание архива из репозитория..." -ForegroundColor Cyan
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Переменная с адресом вашего ZIP (замените URL1 на реальную ссылку при деплое)
$zipFile = Join-Path $targetDir "_gist.zip"

Invoke-WebRequest -Uri $zipUrl -OutFile $zipFile

# 4. Распаковка архива (встроенным методом, заменяющим старый ZipFile)
Write-Host "[*] Распаковка компонентов..." -ForegroundColor Cyan
Expand-Archive -Path $zipFile -DestinationPath $targetDir -Force
# Примечание: сам файл _gist.zip НЕ удаляется, как вы просили, и остается в папке

# # 5. Рекурсивный поиск и запуск главного файла asetall.bat
# Write-Host "[*] Поиск и запуск главного сценария asetall.bat..." -ForegroundColor Cyan
# $batFile = Get-ChildItem -Path $targetDir -Filter "asetall.bat" -Recurse | Select-Object -First 1

# if ($batFile) {
#     $batDir = $batFile.DirectoryName
#     Write-Host "[OK] Скрипт найден в: $batDir" -ForegroundColor Green
    
#     # Переходим в подпапку, где лежит сам bat, чтобы его внутренние относительные пути не ломались
#     Set-Location -Path $batDir
    
#     # Запускаем классический bat-файл в контексте текущего окна CMD
#     Start-Process -FilePath "cmd.exe" -ArgumentList "/c call `"$($batFile.FullName)`"" -Wait
# } else {
#     Write-Error "Критическая ошибка: Файл asetall.bat не найден внутри распакованного архива!"
# }


# 5. Рекурсивный поиск и запуск главного файла steps.bat
Write-Host "[*] Поиск и запуск главного сценария steps.bat..." -ForegroundColor Cyan
$batFile = Get-ChildItem -Path $targetDir -Filter "steps.bat" -Recurse | Select-Object -First 1

if ($batFile) {
    $batDir = $batFile.DirectoryName
    Write-Host "[OK] Скрипт найден в: $batDir" -ForegroundColor Green
    
    # Переходим в подпапку, где лежит сам bat, чтобы его внутренние относительные пути не ломались
    Set-Location -Path $batDir
    
    # Запускаем классический bat-файл в контексте текущего окна CMD
    Start-Process -FilePath "cmd.exe" -ArgumentList "/c call `"$($batFile.FullName)`"" -Wait
} else {
    Write-Error "Критическая ошибка: Файл steps.bat не найден внутри распакованного архива!"
}

