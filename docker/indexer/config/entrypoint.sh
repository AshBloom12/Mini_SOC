#!/usr/bin/env bash
# Wazuh Docker Indexer Entrypoint
set -e

umask 0002

export USER=wazuh-indexer
export INSTALLATION_DIR=/usr/share/wazuh-indexer
export OPENSEARCH_PATH_CONF=${INSTALLATION_DIR}/config
export JAVA_HOME=${INSTALLATION_DIR}/jdk

# Ensure config folder exists
if [[ ! -d "${OPENSEARCH_PATH_CONF}" ]]; then
    mkdir -p "${OPENSEARCH_PATH_CONF}"
    chown -R 1000:1000 "${OPENSEARCH_PATH_CONF}"
    chmod 755 "${OPENSEARCH_PATH_CONF}"
fi

# Read discovery type safely
if [[ -f "${OPENSEARCH_PATH_CONF}/opensearch.yml" ]]; then
    DISCOVERY=$(grep -oP "(?<=discovery.type: ).*" "${OPENSEARCH_PATH_CONF}/opensearch.yml")
else
    DISCOVERY="single-node"
fi

# --- Certificates (aligned with opensearch.yml) ---
CERTS_DIR=${OPENSEARCH_PATH_CONF}/certs
export CACERT=${CERTS_DIR}/root-ca.pem
export CERT=${CERTS_DIR}/indexer.pem
export KEY=${CERTS_DIR}/indexer-key.pem

# Ensure certs folder exists
if [[ ! -d "${CERTS_DIR}" ]]; then
    mkdir -p "${CERTS_DIR}"
    chown -R 1000:1000 "${CERTS_DIR}"
    chmod 700 "${CERTS_DIR}"
fi

# --- Copy Docker secrets to the certs directory ---
if [[ "$(id -u)" == "0" ]]; then
    [[ -f /run/secrets/indexer-key ]] && cp /run/secrets/indexer-key "${KEY}"
    [[ -f /run/secrets/indexer-cert ]] && cp /run/secrets/indexer-cert "${CERT}"
    [[ -f /run/secrets/root-ca ]] && cp /run/secrets/root-ca "${CACERT}"

    # Ensure correct ownership & permissions
    chown -R 1000:0 "${CERTS_DIR}"
    chmod 600 "${CERTS_DIR}"/*.pem
fi

run_as_other_user_if_needed() {
    if [[ "$(id -u)" == "0" ]]; then
        # Drop to UID 1000 / GID 0
        exec chroot --userspec=1000:0 / "${@}"
    else
        exec "${@}"
    fi
}

# Allow running custom commands
if [[ "$1" != "opensearchwrapper" ]]; then
    exec "$@"
fi

# Source secrets-based environment for keystore
if [[ -f "${INSTALLATION_DIR}/bin/opensearch-env-from-file" ]]; then
    source "${INSTALLATION_DIR}/bin/opensearch-env-from-file"
fi

# Bootstrap security password if INDEXER_PASSWORD is set
if [[ -f "${INSTALLATION_DIR}/bin/opensearch-users" ]] && [[ -n "$INDEXER_PASSWORD" ]]; then
    [[ -f "${INSTALLATION_DIR}/opensearch.keystore" ]] || \
        run_as_other_user_if_needed opensearch-keystore create

    if ! run_as_other_user_if_needed opensearch-keystore has-passwd --silent; then
        if ! run_as_other_user_if_needed opensearch-keystore list | grep -q '^bootstrap.password$'; then
            echo "$INDEXER_PASSWORD" | run_as_other_user_if_needed opensearch-keystore add -x 'bootstrap.password'
        fi
    else
        if ! run_as_other_user_if_needed opensearch-keystore list | grep -q '^bootstrap.password$'; then
            COMMANDS="$(printf "%s\n%s" "$KEYSTORE_PASSWORD" "$INDEXER_PASSWORD")"
            echo "$COMMANDS" | run_as_other_user_if_needed opensearch-keystore add -x 'bootstrap.password'
        fi
    fi
fi

# Optional: mutate ownership of bind-mounts if running as root
if [[ "$(id -u)" == "0" ]] && [[ -n "$TAKE_FILE_OWNERSHIP" ]]; then
    chown -R 1000:0 /usr/share/wazuh-indexer/{data,logs}
fi

# Optional: run securityadmin.sh for single-node (uncomment if needed)
# if [[ "$DISCOVERY" == "single-node" ]] && [[ ! -f "/var/lib/wazuh-indexer/.flag" ]]; then
#     nohup /securityadmin.sh &
#     touch "/var/lib/wazuh-indexer/.flag"
# fi

# Start Wazuh Indexer
run_as_other_user_if_needed "${INSTALLATION_DIR}/bin/opensearch" <<<"$KEYSTORE_PASSWORD"
