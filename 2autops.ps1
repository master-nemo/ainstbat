try {
iwr https://vk.cc/cM5qDT -OutFile 1clip.txt
} catch {}

	# wget https://gist.github.com/master-nemo/e68e238d40862f10ea9d04b77db57ee2/archive/422e786971f59c96b6e13b79a0bcf09716118962.zip -OutFile a.zip
	###  === unzip it:
	# & { Add-Type -A 'System.IO.Compression.FileSystem'; [IO.Compression.ZipFile]::ExtractToDirectory('a.zip', 'ichoco'); }
	# cd ichoco\e68e238d40862f10ea9d04b77db57ee2-097e62c4011a3626460641d476af45f435694961
	# install choco

#	choco
	# irm https://community.chocolatey.org/install.ps1 | iex

Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
# %ProgramData%\chocolatey\bin\refreshenv

# install base

choco install -y far 7zip.install notepadplusplus fsviewer conemu clink
choco install -y git
# choco install -y anydesk.install anydesk

try {
	if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
		Write-Host "winget not found try install"
		$progressPreference = 'silentlyContinue'
		Write-Host "Installing WinGet PowerShell module from PSGallery..."
		Install-PackageProvider -Name NuGet -Force | Out-Null
		Install-Module -Name Microsoft.WinGet.Client -Force -Repository PSGallery | Out-Null
		Write-Host "Using Repair-WinGetPackageManager cmdlet to bootstrap WinGet..."
		Repair-WinGetPackageManager -AllUsers
		Write-Host "Done."
	} else {
		Write-Host "winget found"	
	}
} 
catch {    Write-Host "Произошла ошибка, но скрипт продолжит работу." }

irm https://astral.sh/uv/install.ps1 | iex

choco install -y googlechrome 

echo to be: choco install -y skype libreoffice-fresh adobereader 
pause
choco install -y zoom libreoffice-fresh adobereader 

