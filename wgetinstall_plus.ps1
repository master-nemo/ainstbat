$progressPreference = 'silentlyContinue'
Write-Information "Downloading WinGet and its dependencies..."
Invoke-WebRequest -Uri https://aka.ms/getwinget -OutFile Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle
Invoke-WebRequest -Uri https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx -OutFile Microsoft.VCLibs.x64.14.00.Desktop.appx
Invoke-WebRequest -Uri https://github.com/microsoft/microsoft-ui-xaml/releases/download/v2.8.6/Microsoft.UI.Xaml.2.8.x64.appx -OutFile Microsoft.UI.Xaml.2.8.x64.appx
Add-AppxPackage Microsoft.VCLibs.x64.14.00.Desktop.appx
Add-AppxPackage Microsoft.UI.Xaml.2.8.x64.appx
Add-AppxPackage Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle
#~~

#### ------------- remove search bar from windows 10 taskbar

# Function to restart Explorer
function Restart-Explorer {
    param (
        [Parameter(Mandatory=$false)]
        [Switch]$Force
    )

    $explorerProcess = Get-Process explorer -ErrorAction SilentlyContinue

    if ($explorerProcess) {
        Write-Host "Stopping Explorer process..."
        Stop-Process -Name explorer -Force:$Force
        Start-Sleep -Seconds 2

        Write-Host "Restarting Explorer process..."
        Start-Process explorer.exe
    }
    else {
        Write-Host "Explorer process not found."
    }
}

# Function to hide the search bar
function Hide-TaskBarSearch {
    param (
        [Parameter(Mandatory=$false)]
        [Switch]$WhatIf
    )

    try {
        Set-ItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search' `
            -Name 'SearchBoxTaskbarMode' `
            -Value 0 `
            -Type DWord `
            -Force:$false

        if ($WhatIf) {
            Write-Host "Would hide the taskbar search bar."
        }
        else {
            Write-Host "Hiding the taskbar search bar..."

            # Restart Explorer to apply changes
            Restart-Explorer

            Write-Host "Taskbar search bar hidden successfully."
        }
    }
    catch {
        Write-Host "Failed to hide the taskbar search bar."
        Write-Host $_.Exception.Message
    }
}

# Function to show the search bar
function Show-TaskBarSearch {
    param (
        [Parameter(Mandatory=$false)]
        [Switch]$WhatIf
    )

    try {
        Set-ItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search' `
            -Name 'SearchBoxTaskbarMode' `
            -Value 2 `
            -Type DWord `
            -Force:$false

        if ($WhatIf) {
            Write-Host "Would show the taskbar search bar."
        }
        else {
            Write-Host "Showing the taskbar search bar..."

            # Restart Explorer to apply changes
            Restart-Explorer

            Write-Host "Taskbar search bar shown successfully."
        }
    }
    catch {
        Write-Host "Failed to show the taskbar search bar."
        Write-Host $_.Exception.Message
    }
}

# Example usage
Hide-TaskBarSearch -WhatIf
# Hide-TaskBarSearch
# Show-TaskBarSearch

#### -------------

#### -------------
#cmd.exe /c start cmd.exe /k "md c:\1 && cd c:\1 && echo y | winget install clink python.python.3.9  && start ."
#cmd.exe /c start cmd.exe /k "md c:\1 && cd c:\1 && echo y | winget install clink && start ."
#cmd.exe /c start cmd.exe /k "md c:\1 && cd c:\1 && echo y | winget install clink && start ."
#& start cmd /k "cd c:\1"


