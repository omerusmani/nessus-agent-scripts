#!/bin/bash

# Author: Omer Usmani
# Date: 11-14-24
# Description: This script automates the deployment of a Nessus Agent on a RHEL7 or AL2 endpoint.

# Configuration variables
NESSUS_VERSION="10.8.0"
DOWNLOAD_LINK=" https://www.tenable.com/downloads/api/v1/public/pages/nessus-agents/downloads/24582/download?i_agree_to_tenable_license_agreement=true"
RPM_FILE="NessusAgent-${NESSUS_VERSION}-el7.x86_64.rpm"
NESSUS_AGENT_DIR="/opt/nessus_agent"  
NESSUS_MANAGER_KEY="" # Rotate key periodically in Nessus Manager, or implement a secrets manager.
NESSUS_MANAGER_HOST=""
NESSUS_MANAGER_PORT="8834" # Default remote_listen_port is 8834.
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
    /bin/systemctl stop nessusagent.service

    # Perform pre-imaging cleanup
    /opt/nessus_agent/sbin/nessuscli prepare-image
    
    # Uninstall Nessus Agent
    yum remove NessusAgent -y  # Assuming the package name is NessusAgent; adjust if necessary
    echo "Nessus Agent has been uninstalled."
fi

# Download the Nessus Agent RPM package
echo "Downloading Nessus Agent..."
curl -L "${DOWNLOAD_LINK}" -o "${RPM_FILE}"

# Install the Nessus Agent package
echo "Installing Nessus Agent..."

TEMP_FILE=$(mktemp)
if yum install -y "${RPM_FILE}" &> "$TEMP_FILE"; then
    sed '/- First,/,/info./d' "$TEMP_FILE"
    rm -f "$TEMP_FILE" 
else
    cat "$TEMP_FILE"
    rm -f "$TEMP_FILE" 
    echo "Installation failed. Exiting."
    exit 1
fi

# Start Nessus Agent
/bin/systemctl start nessusagent.service


# Prompt for Nessus Agent name
echo "Please enter a name for the Nessus Agent (leave blank to use the system hostname):"
read AGENT_NAME

if [ -z "$AGENT_NAME" ]; then
    AGENT_NAME=$(hostname)
fi

echo "Using '$AGENT_NAME' as the Nessus Agent name."

# Link the installed Nessus Agent to a Nessus Manager instance
${NESSUS_AGENT_DIR}/sbin/nessuscli agent link \
--key="${NESSUS_MANAGER_KEY}" \
--name="$AGENT_NAME" \
--groups="${NESSUS_MANAGER_GROUPS}" \
--host="${NESSUS_MANAGER_HOST}" \
--port="${NESSUS_MANAGER_PORT}"

exit 0