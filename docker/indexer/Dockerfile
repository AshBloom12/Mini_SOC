# Start from the official Wazuh Indexer image
FROM wazuh/wazuh-indexer:4.12.0

# Fix ownership and permissions
# Switch to root to fix permissions
USER root
# Change owner to root and make readable for the Wazuh process
RUN [ -d /etc/wazuh-indexer/certs ] && \
    chmod -R 644 /etc/wazuh-indexer/certs && \
    chown -R root:root /etc/wazuh-indexer/certs || echo "No certs directory, skipping"

# Switch back to default non-root user (if used in base image)
USER 1000
# Optional: ensure entrypoint is unchanged
ENTRYPOINT ["/entrypoint.sh"]
