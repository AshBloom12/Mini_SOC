#!/bin/bash
set -e

# Install Filebeat RPM
curl -L -O https://artifacts.elastic.co/downloads/beats/filebeat/${FILEBEAT_CHANNEL}-${FILEBEAT_VERSION}-x86_64.rpm
yum install -y ${FILEBEAT_CHANNEL}-${FILEBEAT_VERSION}-x86_64.rpm
rm -f ${FILEBEAT_CHANNEL}-${FILEBEAT_VERSION}-x86_64.rpm

# Download Wazuh Filebeat module directly from GitHub
TMP_DIR=$(mktemp -d)
git clone --branch v${WAZUH_VERSION} --depth 1 https://github.com/wazuh/wazuh.git "$TMP_DIR"

# Copy module to Filebeat directory
mkdir -p /usr/share/filebeat/module
cp -r "$TMP_DIR/extensions/filebeat/module/wazuh" /usr/share/filebeat/module/

# Clean up
rm -rf "$TMP_DIR"
