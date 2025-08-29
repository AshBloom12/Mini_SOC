# ---------------- Build Stage ----------------
FROM amazonlinux:2023 AS builder

ARG WAZUH_VERSION
ARG WAZUH_TAG_REVISION

RUN yum install -y curl-minimal openssl xz tar findutils shadow-utils

# Copy repository check script
COPY config/check_repository.sh /
RUN chmod 775 /check_repository.sh && source /check_repository.sh

# Install Wazuh Indexer
RUN yum install -y wazuh-indexer-${WAZUH_VERSION}-${WAZUH_TAG_REVISION} && yum clean all

# Copy configuration files
COPY config/opensearch.yml /config/opensearch.yml
COPY config/config.sh /config/config.sh
COPY config/config.yml /config/config.yml
COPY config/action_groups.yml /config/action_groups.yml
COPY config/internal_users.yml /config/internal_users.yml
COPY config/roles_mapping.yml /config/roles_mapping.yml
COPY config/roles.yml /config/roles.yml

# Apply configuration
RUN bash /config/config.sh

# ---------------- Runtime Stage ----------------
FROM amazonlinux:2023

ENV USER="wazuh-indexer" \
    GROUP="wazuh-indexer" \
    INSTALL_DIR="/usr/share/wazuh-indexer"

# Install runtime dependencies
RUN yum install -y curl-minimal shadow-utils findutils hostname && yum clean all

# Create user and group
RUN getent group $GROUP || groupadd -r -g 1000 $GROUP && \
    useradd --system --uid 1000 --gid $GROUP --no-create-home --home-dir $INSTALL_DIR \
            --shell /sbin/nologin --comment "$USER user" $USER

WORKDIR $INSTALL_DIR

# Copy entrypoint and securityadmin scripts
COPY config/entrypoint.sh /entrypoint.sh
COPY config/securityadmin.sh /securityadmin.sh
RUN chmod 700 /entrypoint.sh /securityadmin.sh

# Set ownership
RUN chown 1000:1000 /*.sh

# Copy Wazuh Indexer binaries and configuration from builder
COPY --from=builder --chown=1000:1000 /usr/share/wazuh-indexer /usr/share/wazuh-indexer
COPY --from=builder --chown=1000:1000 /etc/wazuh-indexer /usr/share/wazuh-indexer/config

# Create runtime directories
RUN mkdir -p /var/lib/wazuh-indexer /usr/share/wazuh-indexer/logs /run/wazuh-indexer /var/log/wazuh-indexer && \
    chown -R 1000:1000 /var/lib/wazuh-indexer /usr/share/wazuh-indexer/logs /run/wazuh-indexer /var/log/wazuh-indexer && \
    chmod 700 /usr/share/wazuh-indexer /usr/share/wazuh-indexer/config && \
    chmod 600 /usr/share/wazuh-indexer/config/jvm.options /usr/share/wazuh-indexer/config/opensearch.yml

# Run as non-root user
USER wazuh-indexer

# Expose service port
EXPOSE 9200

# Entrypoint and default command
ENTRYPOINT ["/entrypoint.sh"]
CMD ["opensearchwrapper"]
