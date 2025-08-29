# Base Wazuh Indexer image
FROM wazuh/wazuh-indexer:4.12.0

# Switch to root to copy certs and fix permissions
USER root

# Copy certificates generated in CI/CD
COPY certs /etc/wazuh-indexer/certs

# Ensure permissions are correct
RUN chmod -R 644 /etc/wazuh-indexer/certs && chown -R root:root /etc/wazuh-indexer/certs

# Switch back to default Wazuh Indexer user
USER 1000

# Entry point stays the same
ENTRYPOINT ["/entrypoint.sh"]
