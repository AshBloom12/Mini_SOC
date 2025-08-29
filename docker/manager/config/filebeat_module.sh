#!/bin/bash
set -e

## Variables
FILEBEAT_MODULE_VERSION="4.12.0"
FILEBEAT_MODULE_DIR="/usr/share/filebeat/module"
FILEBEAT_CHANNEL="${FILEBEAT_CHANNEL:-filebeat-oss}"
FILEBEAT_VERSION="${FILEBEAT_VERSION:-7.10.2}"

# Install Filebeat RPM
curl -L -O https://artifacts.elastic.co/downloads/beats/filebeat/${FILEBEAT_CHANNEL}-${FILEBEAT_VERSION}-x86_64.rpm
yum install -y ${FILEBEAT_CHANNEL}-${FILEBEAT_VERSION}-x86_64.rpm
rm -f ${FILEBEAT_CHANNEL}-${FILEBEAT_VERSION}-x86_64.rpm

# Prepare Filebeat module directory
mkdir -p ${FILEBEAT_MODULE_DIR}

# Download Wazuh Filebeat module from GitHub using the correct tag
TMP_DIR=$(mktemp -d)
git clone --depth 1 --branch "${FILEBEAT_MODULE_VERSION}" https://github.com/wazuh/wazuh.git "${TMP_DIR}"

# Copy using the correct path
cp -r "${TMP_DIR}/extensions/filebeat/modules/wazuh" "${FILEBEAT_MODULE_DIR}/"
rm -rf "${TMP_DIR}"

echo "Wazuh Filebeat module for version ${FILEBEAT_MODULE_VERSION} installed successfully."
