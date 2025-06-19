# This script installs the Amazon AppStream Client on Windows 10 or later systems.
#
# It downloads the latest version from Amazon, extracts the contents, and installs both the AppStream Client and the USB driver based on the installation instructions
# provided by Amazon here: https://docs.aws.amazon.com/appstream2/latest/developerguide/install-client-configure-settings.html
#
# View full system requirements here: https://docs.aws.amazon.com/en_us/appstream2/latest/developerguide/client-application-windows-requirements-user.html
#
# It also supports a "ForceInstall" option that removes any existing AppStreamClient directory from %localappdata% before proceeding with the installation (by default,
# the AppStream Client will not install if this folder is present).
#
# NOTE: The AppStream Client will not be immediately available after running this script. The AppStream Client Installer requires either a system restart or a user
# logoff/logon to complete the installation process. This script provides a "RebootAfterInstall" option to automatically reboot the system after installation to automate this step, if desired.
#
# The script also includes a "NoUSBDriver" option to skip the installation of the USB driver if you do not want to install it.
#
# The script is intended to be run with administrative privileges.
#
#
# Copyright 2025 Cosmistack, Inc.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”),
# to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#
#
param(
    [switch]$ForceInstall = $false,
    [switch]$RebootAfterInstall = $false,
    [switch]$NoUSBDriver = $false
)

$DownloadUrl = "https://clients.amazonappstream.com/installers/windows/latest/AmazonAppStreamClient_EnterpriseSetup.zip"
$TempPath = "$env:TEMP\AppStreamInstall"


function Write-Log {
    param([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "[$timestamp] $Message" -ForegroundColor Green
}

function Write-Error-Log {
    param([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "[$timestamp] ERROR: $Message" -ForegroundColor Red
}

try {
    Write-Log "Starting Amazon AppStream Client installation"
    
    # Handle force install - remove existing AppStreamClient from %localappdata%
    if ($ForceInstall) {
        $appStreamClientPath = Join-Path $env:LOCALAPPDATA "AppStreamClient"
        if (Test-Path $appStreamClientPath) {
            Write-Log "ForceInstall specified - removing existing AppStreamClient from: $appStreamClientPath"
            try {
                Remove-Item -Path $appStreamClientPath -Recurse -Force
                Write-Log "Successfully removed existing AppStreamClient directory"
            } catch {
                Write-Error-Log "Failed to remove existing AppStreamClient directory: $($_.Exception.Message)"
                Write-Log "Continuing with installation..."
            }
        } else {
            Write-Log "ForceInstall specified but no existing AppStreamClient found in %localappdata%"
        }
    }
    
    # Create temporary directory
    Write-Log "Creating temporary directory: $TempPath"
    if (Test-Path $TempPath) {
        Remove-Item -Path $TempPath -Recurse -Force
    }
    New-Item -ItemType Directory -Path $TempPath -Force | Out-Null
    
    # Download the zip file
    $zipFile = Join-Path $TempPath "AmazonAppStreamClient_EnterpriseSetup.zip"
    Write-Log "Downloading from: $DownloadUrl"
    Write-Log "Saving to: $zipFile"
    
    Invoke-WebRequest -Uri $DownloadUrl -OutFile $zipFile -UseBasicParsing
    Write-Log "Download completed successfully"
    
    # Extract the zip file
    Write-Log "Extracting zip file contents"
    Expand-Archive -Path $zipFile -DestinationPath $TempPath -Force
    Write-Log "Extraction completed"
    
    # Find the MSI and EXE files with version numbers
    $msiFile = Get-ChildItem -Path $TempPath -Filter "AmazonAppStreamClientSetup_*.msi" | Select-Object -First 1
    $exeFile = Get-ChildItem -Path $TempPath -Filter "AmazonAppStreamUsbDriverSetup_*.exe" | Select-Object -First 1
    
    if (-not $msiFile) {
        throw "MSI file not found in extracted contents"
    }
    
    if (-not $exeFile) {
        throw "USB driver EXE file not found in extracted contents"
    }
    
    Write-Log "Found MSI file: $($msiFile.Name)"
    Write-Log "Found EXE file: $($exeFile.Name)"
    
    # Change to the extraction directory
    Set-Location -Path $TempPath
    
    # Install the MSI package
    Write-Log "Installing Amazon AppStream Client MSI package"
    $msiArgs = "/i `"$($msiFile.FullName)`" /quiet /norestart"
    Write-Log "Running: msiexec.exe $msiArgs"
    
    $msiProcess = Start-Process -FilePath "msiexec.exe" -ArgumentList $msiArgs -Wait -PassThru -NoNewWindow
    
    if ($msiProcess.ExitCode -eq 0) {
        Write-Log "MSI installation completed successfully"
    } else {
        Write-Error-Log "MSI installation failed with exit code: $($msiProcess.ExitCode)"
    }
    
    # Check if USB driver installation is skipped
    if (!$NoUSBDriver) {
        # Install the USB driver
        Write-Log "Installing Amazon AppStream USB driver"
        Write-Log "Running: $($exeFile.FullName) /quiet"
        
        $exeProcess = Start-Process -FilePath $exeFile.FullName -ArgumentList "/quiet" -Wait -PassThru -NoNewWindow
        
        if ($exeProcess.ExitCode -eq 0) {
            Write-Log "USB driver installation completed successfully"
        } else {
            Write-Error-Log "USB driver installation failed with exit code: $($exeProcess.ExitCode)"
        }
    } else {
        Write-Log "USB driver installation skipped via NoUSBDriver option"
    }
    
    Write-Log "Amazon AppStream Client installation process completed"
    
    if ($RebootAfterInstall) {
        Write-Log "Rebooting system as per RebootAfterInstall option"
        Restart-Computer -Force
    } else {
        Write-Log "Installation completed. Please log off or restart your system to finalize the installation."
    }
} catch {
    Write-Error-Log "Installation failed: $($_.Exception.Message)"
    exit 1
}

Write-Log "Script execution completed"