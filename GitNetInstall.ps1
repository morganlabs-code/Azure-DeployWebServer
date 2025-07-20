# Ensure script runs as Administrator
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
    [Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Warning "Run this script as Administrator!"
    exit 1
}

function Install-Git {
    Write-Host "`n[+] Installing Git for Windows (latest)..."

    try {
        $releaseInfo = Invoke-RestMethod -Uri "https://api.github.com/repos/git-for-windows/git/releases/latest" `
                                        -Headers @{ "User-Agent" = "PowerShell" }

        $asset = $releaseInfo.assets | Where-Object { $_.name -like "*64-bit.exe" } | Select-Object -First 1
        if (-not $asset) {
            throw "Could not find a 64-bit Git installer in latest release."
        }

        $gitUrl = $asset.browser_download_url
        $gitInstaller = "$env:USERPROFILE\Downloads\GitInstaller.exe"

        Write-Host "    Downloading Git from:`n    $gitUrl"
        Start-BitsTransfer -Source $gitUrl -Destination $gitInstaller

        Write-Host "    Running Git installer silently..."
        Start-Process -FilePath $gitInstaller -ArgumentList "/VERYSILENT /NORESTART" -Wait

        Write-Host "    Git installation complete."
        Remove-Item $gitInstaller -Force
    }
    catch {
        Write-Error "    Git install failed: $_"
    }

    if (Get-Command git -ErrorAction SilentlyContinue) {
        git --version
    } else {
        Write-Warning "    Git not found in PATH. Restart PowerShell to refresh."
    }
}


# Function to install .NET SDK
function Install-DotNet {
    Write-Host "Installing .NET SDK (latest LTS)..."
    $dotnetInstaller = "$env:TEMP\dotnet-install.ps1"
    Invoke-WebRequest -Uri "https://dot.net/v1/dotnet-install.ps1" -OutFile $dotnetInstaller
    & $dotnetInstaller -Channel LTS -InstallDir "$env:ProgramFiles\dotnet" -NoPath
    Write-Host ".NET SDK installation complete."
}



# Run installations
Install-Git
Install-DotNet

Write-Host "`Git and .NET SDK installation complete."
