#!/bin/bash
set -e

## Variables
FILEBEAT_MODULE_VERSION="4.12.0"
FILEBEAT_MODULE_DIR="/usr/share/filebeat/module"
FILEBEAT_VERSION="${FILEBEAT_VERSION:-7.10.2}"

# Install Wazuh-compatible Filebeat RPM
curl -L -O https://packages.wazuh.com/4.x/yum/filebeat-${FILEBEAT_VERSION}-1.x86_64.rpm
yum install -y filebeat-${FILEBEAT_VERSION}-1.x86_64.rpm
rm -f filebeat-${FILEBEAT_VERSION}-1.x86_64.rpm

# Prepare Filebeat module directory
mkdir -p ${FILEBEAT_MODULE_DIR}

# Download Wazuh Filebeat module from GitHub using the correct tag
TMP_DIR=$(mktemp -d)
git clone --depth 1 --branch "v${FILEBEAT_MODULE_VERSION}" https://github.com/wazuh/wazuh.git "${TMP_DIR}"

# Copy the Wazuh module to Filebeat modules directory
cp -r "${TMP_DIR}/extensions/filebeat/module/wazuh" "${FILEBEAT_MODULE_DIR}/"
rm -rf "${TMP_DIR}"

echo "Wazuh Filebeat module for version ${FILEBEAT_MODULE_VERSION} installed successfully."
