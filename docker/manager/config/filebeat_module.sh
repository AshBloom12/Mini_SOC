#!/bin/bash
set -e

## Variables
WAZUH_VERSION="4.12.0"
FILEBEAT_MODULE_DIR="/usr/share/filebeat/module"
FILEBEAT_VERSION="${FILEBEAT_VERSION:-7.10.2}"
WAZUH_FILEBEAT_MODULE="wazuh-${WAZUH_VERSION}-filebeat-module.tar.gz"
REPOSITORY="packages.wazuh.com/4.x"

# Install Filebeat RPM from official Wazuh site
curl -L -O https://packages.wazuh.com/4.x/yum/x86_64/filebeat-7.10.2-1.x86_64.rpm
yum install -y filebeat-7.10.2-1.x86_64.rpm
rm -f filebeat-7.10.2-1.x86_64.rpm

# Prepare Filebeat module directory
mkdir -p ${FILEBEAT_MODULE_DIR}

# Download Wazuh Filebeat module tarball and extract it
curl -L https://${REPOSITORY}/filebeat/${WAZUH_FILEBEAT_MODULE} | tar -xvzf - -C ${FILEBEAT_MODULE_DIR}

echo "Wazuh Filebeat module for version ${WAZUH_VERSION} installed successfully."
