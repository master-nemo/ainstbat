powershell -ExecutionPolicy Bypass -command "Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))"
call %ProgramData%\chocolatey\bin\refreshenv
rem cd %ProgramData%\chocolatey\bin

where chocolatey.exe >nul
IF ERRORLEVEL 1 (
	echo path not present. trying to add
 	setx /M PATH %PATH%;%ProgramData%\chocolatey\bin
	) 

choco install -y adobereader googlechrome far 7zip.install notepadplusplus fsviewer
choco install -y anydesk.install anydesk
rem choco install -y adobereader googlechrome far 7zip.install notepadplusplus conemu fsviewer
choco install -y skype zoom libreoffice-fresh 360ts 
