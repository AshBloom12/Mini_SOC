#!/usr/bin/env bash
# Wazuh Docker Copyright (C) 2017, Wazuh Inc. (License GPLv2)
set -e

umask 0002

INSTALL_DIR=/usr/share/wazuh-dashboard
CONFIG_DIR=${INSTALL_DIR}/config
CERTS_DIR=${CONFIG_DIR}/certs

DASHBOARD_USERNAME="${DASHBOARD_USERNAME:-kibanaserver}"
DASHBOARD_PASSWORD="${DASHBOARD_PASSWORD:-kibanaserver}"

run_as_other_user_if_needed() {
    if [[ "$(id -u)" == "0" ]]; then
        # Drop to non-root user (wazuh-dashboard UID 1000)
        exec chroot --userspec=1000:0 / "${@}"
    else
        exec "${@}"
    fi
}

# Load secrets if mounted via Docker Swarm
if [[ -f /run/secrets/dashboard_tls_key ]]; then
    export TLS_KEY_FILE=/run/secrets/dashboard_tls_key
fi
if [[ -f /run/secrets/dashboard_tls_crt ]]; then
    export TLS_CRT_FILE=/run/secrets/dashboard_tls_crt
fi
if [[ -f /run/secrets/wazuh_api_user ]]; then
    export WAZUH_API_USER_FILE=/run/secrets/wazuh_api_user
fi
if [[ -f /run/secrets/wazuh_api_password ]]; then
    export WAZUH_API_PASSWORD_FILE=/run/secrets/wazuh_api_password
fi

# Create Wazuh Dashboard keystore if not exists
if [[ ! -f "${CONFIG_DIR}/.opensearch_dashboards_keystore" ]]; then
    echo "Creating Wazuh Dashboard keystore..."
    yes | $INSTALL_DIR/bin/opensearch-dashboards-keystore create --allow-root
    echo "$DASHBOARD_USERNAME" | $INSTALL_DIR/bin/opensearch-dashboards-keystore add opensearch.username --stdin --allow-root
    echo "$DASHBOARD_PASSWORD" | $INSTALL_DIR/bin/opensearch-dashboards-keystore add opensearch.password --stdin --allow-root
fi

# Apply dashboard configuration scripts if present
if [[ -f /wazuh_app_config.sh ]]; then
    /wazuh_app_config.sh "${WAZUH_UI_REVISION:-latest}"
fi

# Launch Wazuh Dashboard
run_as_other_user_if_needed $INSTALL_DIR/bin/opensearch-dashboards -c $CONFIG_DIR/opensearch_dashboards.yml
