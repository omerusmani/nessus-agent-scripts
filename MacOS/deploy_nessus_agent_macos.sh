#!/bin/bash

# Configuration variables
NESSUS_VERSION="10.6.1"
DOWNLOAD_LINK="https://www.tenable.com/downloads/api/v1/public/pages/nessus-agents/downloads/22699/download?i_agree_to_tenable_license_agreement=true"
DMG_FILE="NessusAgent-${NESSUS_VERSION}.dmg"
NESSUS_AGENT_DIR="/Library/NessusAgent"
NESSUS_MANAGER_KEY=""
NESSUS_MANAGER_HOST=""
NESSUS_MANAGER_PORT="8834" # Default listening port is 8834
NESSUS_MANAGER_GROUPS=""

# Check for root privileges
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root. Please use 'sudo'."
   exit 1
fi

# Check for existing Nessus Agent installation
if [ -d "${NESSUS_AGENT_DIR}" ]; then
    echo "Nessus Agent is already installed. Proceeding with unlinking and uninstallation."
    
    # Stop Nessus Agent
    launchctl stop com.tenablesecurity.nessusagent

    # Perform pre-imaging cleanup
    /Library/NessusAgent/run/sbin/nessuscli prepare-image

    # Uninstall Nessus Agent
    launchctl remove com.tenablesecurity.nessusagent
    echo "Nessus Agent has been uninstalled."
fi

# Get download link
echo "Downloading Nessus Agent..."
curl -L "${DOWNLOAD_LINK}" -o "${DMG_FILE}"

# Mount the DMG file
echo "Mounting ${DMG_FILE}..."
MOUNT_POINT=$(hdiutil attach "$DMG_FILE" | grep -o '/Volumes/.*')

# Check if the mount was successful
if [ -z "$MOUNT_POINT" ]; then
    echo "Failed to mount ${DMG_FILE}. Exiting."
    exit 1
fi

echo "Mounted at ${MOUNT_POINT}"

# Install the Nessus Agent packages
echo "Installing Nessus Agent..."
installer -pkg "${MOUNT_POINT}/Install Nessus Agent.pkg" -target / || { echo "Error installing Nessus Agent."; exit 1; }
installer -pkg "${MOUNT_POINT}/.NessusAgent.pkg" -target / || { echo "Error installing .NessusAgent package."; exit 1; }

# Unmount the DMG file
echo "Unmounting ${DMG_FILE}..."
hdiutil detach "$MOUNT_POINT"

echo "Installation complete."

# Start Nessus Agent
launchctl start com.tenablesecurity.nessusagent

# Prompt for Nessus Agent name
echo "Please enter a name for the Nessus Agent (leave blank to use the system hostname):"
read AGENT_NAME

if [ -z "$AGENT_NAME" ]; then
    AGENT_NAME=$(hostname)
fi

echo "Using '$AGENT_NAME' as the Nessus Agent name."

# Link the installed Nessus Agent to a Nessus Manager instance.
/Library/NessusAgent/run/sbin/nessuscli agent link \
--key="${NESSUS_MANAGER_KEY}" \
--name="$AGENT_NAME" \
--groups="${NESSUS_MANAGER_GROUPS}" \
--host="${NESSUS_MANAGER_HOST}" \
--port="${NESSUS_MANAGER_PORT}"

exit 0