#!/usr/bin/env bash
# Wazuh Docker Indexer Entrypoint
set -e

umask 0002

export USER=wazuh-indexer
export INSTALLATION_DIR=/usr/share/wazuh-indexer
export OPENSEARCH_PATH_CONF=${INSTALLATION_DIR}/config
export JAVA_HOME=${INSTALLATION_DIR}/jdk
export DISCOVERY=$(grep -oP "(?<=discovery.type: ).*" ${OPENSEARCH_PATH_CONF}/opensearch.yml || echo "single-node")

# --- Certificates directory ---
CERTS_DIR=${OPENSEARCH_PATH_CONF}/certs
export CACERT=${CERTS_DIR}/root-ca.pem
export CERT=${CERTS_DIR}/indexer.pem
export KEY=${CERTS_DIR}/indexer-key.pem

# Ensure config and certs directories exist
mkdir -p "${OPENSEARCH_PATH_CONF}" "${CERTS_DIR}"
chown -R 1000:0 "${OPENSEARCH_PATH_CONF}" "${CERTS_DIR}"
chmod 700 "${CERTS_DIR}"

# --- Copy Docker secrets if running as root ---
if [[ "$(id -u)" == "0" ]]; then
    [[ -f /run/secrets/indexer-key ]] && cp /run/secrets/indexer-key "${KEY}"
    [[ -f /run/secrets/indexer-cert ]] && cp /run/secrets/indexer-cert "${CERT}"
    [[ -f /run/secrets/root-ca ]] && cp /run/secrets/root-ca "${CACERT}"

    # Set ownership and permissions
    chown -R 1000:0 "${CERTS_DIR}"
    chmod 600 "${CERTS_DIR}"/*.pem || true
fi

# --- Function to run as UID 1000 if root ---
run_as_wazuh_user() {
    if [[ "$(id -u)" == "0" ]]; then
        exec chroot --userspec=1000:0 / "${@}"
    else
        exec "${@}"
    fi
}

# --- Custom commands support ---
if [[ "$1" != "opensearchwrapper" ]]; then
    exec "$@"
fi

# Source secrets-based environment for keystore if exists
[[ -f ${INSTALLATION_DIR}/bin/opensearch-env-from-file ]] && source ${INSTALLATION_DIR}/bin/opensearch-env-from-file

# Bootstrap security password if INDEXER_PASSWORD is set
if [[ -f bin/opensearch-users ]] && [[ -n "$INDEXER_PASSWORD" ]]; then
    [[ -f ${INSTALLATION_DIR}/opensearch.keystore ]] || (run_as_wazuh_user opensearch-keystore create)
    
    if ! (run_as_wazuh_user opensearch-keystore has-passwd --silent); then
        if ! (run_as_wazuh_user opensearch-keystore list | grep -q '^bootstrap.password$'); then
            (run_as_wazuh_user echo "$INDEXER_PASSWORD" | opensearch-keystore add -x 'bootstrap.password')
        fi
    else
        if ! (run_as_wazuh_user opensearch-keystore list | grep -q '^bootstrap.password$'); then
            COMMANDS="$(printf "%s\n%s" "$KEYSTORE_PASSWORD" "$INDEXER_PASSWORD")"
            (run_as_wazuh_user echo "$COMMANDS" | opensearch-keystore add -x 'bootstrap.password')
        fi
    fi
fi

# Optional: change ownership of bind-mounted volumes
if [[ "$(id -u)" == "0" && -n "$TAKE_FILE_OWNERSHIP" ]]; then
    chown -R 1000:0 /usr/share/wazuh-indexer/{data,logs}
fi

# Start Wazuh Indexer
run_as_wazuh_user ${INSTALLATION_DIR}/bin/opensearch <<<"$KEYSTORE_PASSWORD"
