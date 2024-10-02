# NOTE: Set execution policy to allow this script before running. 
# Example: Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process

# Author: Omer Usmani
# Email: its.omerusmani@gmail.com
# Date: 10-02-24
# Description: This script automates the deployment of a Nessus Agent on a Windows endpoint.

# Configuration variables

$NESSUS_VERSION="10.7.3"
$DOWNLOAD_LINK="https://www.tenable.com/downloads/api/v1/public/pages/nessus-agents/downloads/22846/download?i_agree_to_tenable_license_agreement=true"
$MSI_FILE="NessusAgent-${NESSUS_VERSION}-x64.msi"
$NESSUS_AGENT_FOLDER="C:\Program Files\Tenable\Nessus Agent"
$NESSUS_MANAGER_KEY="" # Rotate key periodically in Nessus Manager, or implement a secrets manager.
$NESSUS_MANAGER_HOST=""
$NESSUS_MANAGER_PORT="8834" # Default remote_listen_port is 8834.
$NESSUS_MANAGER_GROUPS=""

# Check for administrator privileges
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "This script must be run as an administrator. Please run PowerShell as an administrator and re-run the script."
    exit 1
}

# Check if the directory exists
if (Test-Path $NESSUS_AGENT_FOLDER) {
    Write-Host "Nessus Agent is already installed. Proceeding with unlinking and uninstallation."
    
    # Stop Nessus Agent
    Stop-Service -Name "Tenable Nessus Agent"

    # Perform pre-imaging cleanup
    & "$NESSUS_AGENT_FOLDER\nessuscli.exe" prepare-image

    # Uninstall Nessus Agent
    (Get-WmiObject -Class Win32_Product -Filter "Name='Nessus Agent (x64)'").Uninstall()
    Write-Host "Nessus Agent has been uninstalled."
}

# Download the Nessus Agent MSI Installer
Write-Host "Downloading Nessus Agent. This may take a moment..."
Invoke-WebRequest -Uri $DOWNLOAD_LINK -OutFile $MSI_FILE

 	
# Install the Nessus Agent package
Write-Host "Installing Nessus Agent..."

$process = Start-Process -FilePath "msiexec.exe" -ArgumentList "/i `"$MSI_FILE`" /qn" -PassThru -Wait
if ($process.ExitCode -ne 0) {
    Write-Error "Installation failed with exit code $($process.ExitCode)"
    exit 1
} else {
    Write-Host "Installation complete."
}

# Start Nessus Agent
Start-Service -Name "Tenable Nessus Agent"

# Prompt for Nessus Agent name
Write-Host "Please enter a name for the Nessus Agent (leave blank to use the system hostname):"
$AGENT_NAME = Read-Host

if ([string]::IsNullOrWhiteSpace($AGENT_NAME)) {
    $AGENT_NAME = $env:COMPUTERNAME
}

Write-Host "Using '$AGENT_NAME' as the Nessus Agent name."


# Link the installed Nessus Agent to a Nessus Manager instance
& "$NESSUS_AGENT_FOLDER\nessuscli.exe" `
    agent link `
    --key="$NESSUS_MANAGER_KEY" `
    --name="$AGENT_NAME" `
    --groups="$NESSUS_MANAGER_GROUPS" `
    --host="$NESSUS_MANAGER_HOST" `
    --port="$NESSUS_MANAGER_PORT"

exit 0