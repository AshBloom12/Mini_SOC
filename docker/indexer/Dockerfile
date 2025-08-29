# Dockerfile for Wazuh Indexer with self-signed certs
FROM wazuh/wazuh-indexer:4.12.0

# Install openssl (if not already present)
USER root
RUN apt-get update && \
    apt-get install -y openssl && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p /etc/wazuh-indexer/certs && \
    openssl req -x509 -nodes -days 365 \
        -subj "/CN=wazuh-root-ca" \
        -newkey rsa:4096 \
        -keyout /etc/wazuh-indexer/certs/root-ca-key.pem \
        -out /etc/wazuh-indexer/certs/root-ca.pem && \
    openssl req -nodes -newkey rsa:4096 \
        -subj "/CN=wazuh-indexer" \
        -keyout /etc/wazuh-indexer/certs/indexer-key.pem \
        -out /etc/wazuh-indexer/certs/indexer.csr && \
    openssl x509 -req -in /etc/wazuh-indexer/certs/indexer.csr \
        -CA /etc/wazuh-indexer/certs/root-ca.pem \
        -CAkey /etc/wazuh-indexer/certs/root-ca-key.pem \
        -CAcreateserial -out /etc/wazuh-indexer/certs/indexer.pem -days 365 && \
    rm /etc/wazuh-indexer/certs/indexer.csr /etc/wazuh-indexer/certs/root-ca-key.pem /etc/wazuh-indexer/certs/root-ca.srl && \
    chmod -R 644 /etc/wazuh-indexer/certs && \
    chown -R root:root /etc/wazuh-indexer/certs

# Switch back to default user
USER 1000

# Continue with original entrypoint
ENTRYPOINT ["/entrypoint.sh"]
