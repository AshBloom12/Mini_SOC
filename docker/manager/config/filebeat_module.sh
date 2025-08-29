#!/bin/bash
set -e

## Variables
REPOSITORY="packages-dev.wazuh.com/pre-release"

# Determine the Wazuh tag for the version
WAZUH_TAG=$(curl --silent https://api.github.com/repos/wazuh/wazuh/git/refs/tags \
               | grep '["]ref["]:' \
               | sed -E 's/.*\"([^\"]+)\".*/\1/' \
               | cut -c 11- \
               | grep ^v${WAZUH_VERSION}$)

# Use production repository if tag exists
if [[ -n "${WAZUH_TAG}" ]]; then
  REPOSITORY="packages.wazuh.com/4.x"
fi

# Install the correct Filebeat RPM from Wazuh repo
curl -L -O https://packages.wazuh.com/4.x/yum/filebeat-${FILEBEAT_VERSION}-1.x86_64.rpm
yum install -y filebeat-${FILEBEAT_VERSION}-1.x86_64.rpm
rm -f filebeat-${FILEBEAT_VERSION}-1.x86_64.rpm

# Extract Wazuh Filebeat module tarball
curl -s https://${REPOSITORY}/filebeat/${WAZUH_FILEBEAT_MODULE} | tar -xvz -C /usr/share/filebeat/module
