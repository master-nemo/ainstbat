@rem  PowerShell -ExecutionPolicy Unrestricted -Command "wget http://bit.do/atoolsa -OutFile aaa.bat"
REM pause

@rem all in zip
@rem (disable cause used bitdo short to latest ver) PowerShell -ExecutionPolicy Unrestricted -Command "wget https://gist.github.com/master-nemo/e68e238d40862f10ea9d04b77db57ee2/archive/decad130279c6ea96f7089f5837a26355fe0c47a.zip -OutFile a.zip"
REM PowerShell -ExecutionPolicy Unrestricted -Command "wget  -OutFile a.zip"
@rem unzip it:
REM powershell.exe -nologo -noprofile -command "& { Add-Type -A 'System.IO.Compression.FileSystem'; [IO.Compression.ZipFile]::ExtractToDirectory('a.zip', 'ichoco'); }"
REM cd ichoco\e68e238d40862f10ea9d04b77db57ee2-097e62c4011a3626460641d476af45f435694961
@rem install choco

REM #	choco
REM powershell -ExecutionPolicy Bypass -command "irm https://community.chocolatey.org/install.ps1 | iex"

powershell -ExecutionPolicy Bypass -command "Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))"
call %ProgramData%\chocolatey\bin\refreshenv

where chocolatey.exe >nul
IF ERRORLEVEL 1 (
	echo path not present. trying to add
 	setx /M PATH %PATH%;%ProgramData%\chocolatey\bin
	) 

@rem install base

choco install -y far 7zip.install notepadplusplus fsviewer
choco install -y googlechrome 
choco install -y git
choco install -y googlechrome 
REM choco install -y anydesk.install anydesk
choco install -y conemu 

echo to be: choco install -y skype libreoffice-fresh adobereader 
pause
choco install -y zoom libreoffice-fresh adobereader 


REM echo to be:  360ts 
REM pause
REM choco install -y 360ts 

REM echo --call userpack.bat
REM pause
REM call userpack.bat

REM echo --delmtrash.ps1
REM pause
PowerShell -ExecutionPolicy Unrestricted -PSConsoleFile delmtrash.psc1
REM call delmtrash.bat

