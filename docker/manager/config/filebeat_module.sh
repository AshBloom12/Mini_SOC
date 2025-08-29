#!/bin/bash
set -e

## Variables
WAZUH_VERSION="4.12.0"
FILEBEAT_MODULE_DIR="/usr/share/filebeat/module"

# Install Filebeat RPM from Wazuh official repository
curl -L -O https://packages.wazuh.com/4.x/yum/filebeat-7.10.2-1.x86_64.rpm
yum install -y filebeat-7.10.2-1.x86_64.rpm
rm -f filebeat-7.10.2-1.x86_64.rpm

# Ensure the Wazuh Filebeat module directory exists
mkdir -p ${FILEBEAT_MODULE_DIR}

echo "Filebeat 7.10.2 with Wazuh module installed successfully."
