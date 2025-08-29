## variables
REPOSITORY="packages-dev.wazuh.com/pre-release"
WAZUH_TAG=$(curl --silent https://api.github.com/repos/wazuh/wazuh/git/refs/tags \
              | grep '["]ref["]:' \
              | sed -E 's/.*\"([^\"]+)\".*/\1/' \
              | cut -c 11- \
              | grep ^v${WAZUH_VERSION}$)

## check tag to use the correct repository
if [[ -n "${WAZUH_TAG}" ]]; then
  REPOSITORY="packages.wazuh.com/4.x"
fi

# Install Filebeat RPM
curl -L -O https://artifacts.elastic.co/downloads/beats/filebeat/${FILEBEAT_CHANNEL}-${FILEBEAT_VERSION}-x86_64.rpm
yum install -y ${FILEBEAT_CHANNEL}-${FILEBEAT_VERSION}-x86_64.rpm
rm -f ${FILEBEAT_CHANNEL}-${FILEBEAT_VERSION}-x86_64.rpm

# Download and extract Wazuh Filebeat module
curl -f -sL https://${REPOSITORY}/filebeat/wazuh-${WAZUH_VERSION}.tar.gz -o /tmp/wazuh-module.tar.gz
mkdir -p /usr/share/filebeat/module
tar -xzf /tmp/wazuh-module.tar.gz -C /usr/share/filebeat/module
rm /tmp/wazuh-module.tar.gz
