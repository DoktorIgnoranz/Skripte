## Script to setup a new Windows 10 Installation
# Author: Jeremy Stephan, Hendrik Behle
# Version: 1.0
# Date: 2022-12-21
# Description: This script will install basic software and configure Windows 10/11
## 

# Setup Configuration
$DEBUG = $false
$NAME = "Dummy"
$ORGANISATION = "Dummy"

# Get Motnh and Year Day
$DAY = (Get-Date -Format dd)
$MONTH = (Get-Date -Format MMM)
$YEAR = (Get-Date -Format yyyy)

# Create Temp Directory for all files
try {
    $TEMP_DIR = "$env:TEMP\WindowsSetup"
    if (!(Test-Path $TEMP_DIR)) {
        New-Item -ItemType Directory -Path $TEMP_DIR
    }
}
catch {
    Write-Host "Could not create Temp Directory. Please run this script as Administrator."
    exit 1
}

# Main Logging Function
function Write-Log {
    [CmdletBinding()]
    param(
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$Message,
 
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('Information','Warning','Error','Debug','Data')]
        [string]$Severity = 'Information'
    )

    # Write to console
    switch ($Severity) {
        'Debug' {
            if ($DEBUG) {
                Write-Host -NoNewline -ForegroundColor DarkGray -Object " [DBG] "
            }
            else {
                return
            } 
        }
        'Information' { Write-Host -NoNewline -ForegroundColor Green -Object " [INFO] " }
        'Warning' { Write-Host -NoNewline -ForegroundColor Yellow -Object " [WARN] " }
        'Error' { Write-Host -NoNewline -ForegroundColor Red -Object " [ERR] " }
    }
    Write-Host -ForegroundColor White -Object "$Message"

     # Write to log file
     [pscustomobject]@{
        Time = (Get-Date -f g)
        Message = $Message
        Severity = $Severity
    } | Export-Csv -Path "$TEMP_DIR\WindowsSetup-$YEAR-$MONTH-$DAY.csv" -Append -NoTypeInformation

}
Write-Log -Message "Initialized Logging function" -Severity Debug

# Set the execution policy to unrestricted
try {
    Set-ExecutionPolicy Unrestricted -Scope CurrentUser -Force
}
catch {
    Write-Log -Message "Could not set execution policy to unrestricted. Please run this script as Administrator." -Severity Error
    exit 1
}

# Functions for setup
function F_SETORGAN {
    Write-Log -Message "Starting Set Organisation" -Severity Debug
    # Set Owner & Organisatzion of the Current PC
    New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name RegisteredOwner -Value $NAME -PropertyType String -Force
    New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name RegisteredOrganization -Value $ORGANISATION -PropertyType String -Force
    Write-Log -Message "Set Owner & Organisation" -Severity Information
}

# Function to Update Windows
function F_UPDATEWIN {
    Write-Log -Message "Starting Update Windows" -Severity Debug
    Install-Module -Name PSWindowsUpdate -Force -AcceptLicense
    Write-Log -Message "Installing Windows Updates"
    Write-Log -Message "This may take a while. Please be patient. The Computer will restart automatically" -Severity Warning
    Get-WindowsUpdate -AcceptAll -Install -AutoReboot
}

function F_SHUTUPWIN {
    Write-Log -Message "Starting Shut Up Windows" -Severity Debug
    # Stop Windows to Install Cloud Apps
    New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Name DisableWindowsConsumerFeatures -Value 1 -PropertyType DWord -Force
    # Remove Windows Apps except Windows Store itself
    Get-AppxProvisionedPackage -Online | Where-Object DisplayName -NotMatch "*store*" | Remove-AppxProvisionedPackage -Online
    Get-AppxPackage -AllUsers | Where-Object PackageName -NotMatch "*store*" | Remove-AppxPackage
    # Disable or remove Telemetry
    New-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer' -Name 'SmartScreenEnabled' -PropertyType String -Value 'Off' -Force
    New-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection' -Name 'AllowTelemetry' -PropertyType DWord -Value '0' -Force
    New-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection' -Name 'AllowTelemetry' -PropertyType DWord -Value '0' -Force
    # Stop Windows Defender from sending Data to Microsoft
    New-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet' -Name 'SpyNetReporting' -PropertyType DWord -Value '0' -Force
    New-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet' -Name 'SubmitSamplesConsent' -PropertyType DWord -Value '2' -Force
    # Ensure Updates are downloaded from Microsoft and not from other sources
    New-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization' -Name 'DODownloadMode' -PropertyType DWord -Value '0' -Force
    New-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization' -Name 'SystemSettingsDownloadMode' -PropertyType DWord -Value '0' -Force
    New-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config' -Name 'DODownloadMode' -PropertyType DWord -Value '0' -Force
    # Disable Hibernate
    powercfg -h off
}

function F_PREINSTALL_APP {
   # Install Chocolatey
    Write-Log -Message "Starting Install Chocolatey" -Severity Debug
    Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    Write-Log -Message "Installed Chocolatey" -Severity Information
    # Install Git for Windows via Chocolatey
    Write-Log -Message "Starting Install Git for Windows" -Severity Debug
    choco install git -y
    Write-Log -Message "Installed Git for Windows" -Severity Information
}

function F_INSTALL_APP_BASIC {
    Write-Log -Message "Starting Install Basic Apps" -Severity Debug
    choco install firefox vlc 7zip spotify notepadplusplus adobereader teamviewer -y
    Write-Log -Message "Installed all Programms" -Severity Information
}

function F_INSTALL_APP_DEV {
    Write-Log -Message "Starting Install Developer Apps" -Severity Debug
    choco install firefox vlc 7zip spotify notepadplusplus adobereader teamviewer vscode openvpn powershell-core microsoft-windows-terminal nodejs python github-desktop putty postman googlechrome -y
    Write-Log -Message "Installed all Programms" -Severity Information
}

function F_INSTALL_APP_GAMING {
    Write-Log -Message "Starting Install Gaming Apps" -Severity Debug
    choco install firefox vlc 7zip spotify notepadplusplus adobereader teamviewer openvpn steam discord epicgameslauncher goggalaxy teamspeak -y
    Write-Log -Message "Installed all Programms" -Severity Information
}

function F_INSTAL_APP_TROUBELSHOOT {
    Write-Log -Message "Starting Install Troubleshooting Apps" -Severity Debug
    choco install HWiNFO treesizefree malwarebytes teamviewer.host putty advanced-ip-scanner wireshark crystaldiskmark crystaldiskinfo.install sysinternals
    Write-Log -Message "Installed Troubleshooting Apps" -Severity Information
}

function F_INSTALL_APP_FULL {
    Write-Log -Message "Starting Install Full Apps" -Severity Debug
    choco install firefox vlc 7zip spotify notepadplusplus adobereader teamviewer vscode openvpn powershell-core microsoft-windows-terminal nodejs python github-desktop putty postman googlechrome openvpn steam discord epicgameslauncher goggalaxy teamspeak HWiNFO treesizefree malwarebytes teamviewer.host putty advanced-ip-scanner wireshark crystaldiskmark crystaldiskinfo.install sysinternals -y
    Write-Log -Message "Installed all Programms" -Severity Information
}

function F_INSTALL_APP_BACKUP {
    Write-Log -Message "Starting Install Backup" -Severity Debug
    choco install veeam-agent -y
    Write-Log -Message "Installed all Programms" -Severity Information
}

# Basic Setup Function
function SETUP_BASIC {
    Write-Log -Message "Starting Basic Setup" -Severity Debug
    F_PREINSTALL_APP
    F_SETORGAN
    F_SHUTUPWIN
    F_INSTALL_APP_BASIC
    F_UPDATEWIN
}

# Developer Setup Function
function SETUP_DEV {
    Write-Log -Message "Starting Developer Setup" -Severity Debug
    F_PREINSTALL_APP
    F_SETORGAN
    F_SHUTUPWIN
    F_INSTALL_APP_DEV
    F_UPDATEWIN
}

# Gaming Setup Function
function SETUP_GAMING {
    Write-Log -Message "Starting Gaming Setup" -Severity Debug
    F_PREINSTALL_APP
    F_SETORGAN
    F_SHUTUPWIN
    F_INSTALL_APP_GAMING
    F_UPDATEWIN
}

# Full Setup Function
function SETUP_FULL {
    Write-Log -Message "Starting Full Setup" -Severity Debug
    F_PREINSTALL_APP
    F_SETORGAN
    F_SHUTUPWIN
    F_INSTALL_APP_FULL
    F_INSTAL_APP_TROUBELSHOOT
    F_UPDATEWIN
}

# Create a Selection Menu to allow User to slect what kind of Installation he wants
$SELECT_MENU_TITLE = 'Windows Automated Setup'
$SELECT_MENU_TEXT = 'This script will automatically install basic software and configure Windows 10. Please select the type of installation you want to perform:'
$SELECT_MENU_INSTALL_BASIC = New-Object System.Management.Automation.Host.ChoiceDescription "&Basic Installation", "Basic Installation"
$SELECT_MENU_INSTALL_DEV = New-Object System.Management.Automation.Host.ChoiceDescription "&Developer Installation", "Developer Installation"
$SELECT_MENU_INSTALL_GAMING = New-Object System.Management.Automation.Host.ChoiceDescription "&Gaming Installation", "Gaming Installation"
$SELECT_MENU_INSTALL_FULL = New-Object System.Management.Automation.Host.ChoiceDescription "&Full Installation", "Full Installation"
$SELECT_MENU_OPTIONS = [System.Management.Automation.Host.ChoiceDescription[]]($SELECT_MENU_INSTALL_BASIC, $SELECT_MENU_INSTALL_DEV, $SELECT_MENU_INSTALL_GAMING, $SELECT_MENU_INSTALL_FULL)

# Create the Menu
$SELECT_MENU_RESULT = $Host.UI.PromptForChoice($SELECT_MENU_TITLE, $SELECT_MENU_TEXT, $SELECT_MENU_OPTIONS, 0)

switch ($SELECT_MENU_RESULT)
{
    0 {
        SETUP_BASIC
    }
    1 { 
        SETUP_DEV
    }
    2 { 
        SETUP_GAMING
     }
    3 { 
        SETUP_FULL
    }
}