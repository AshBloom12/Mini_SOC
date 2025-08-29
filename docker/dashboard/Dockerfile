# ---------------- Build Stage ----------------
FROM amazonlinux:2023 AS builder

ARG WAZUH_VERSION
ARG WAZUH_TAG_REVISION
ARG WAZUH_UI_REVISION
ARG INSTALL_DIR=/usr/share/wazuh-dashboard

# Update and install dependencies
RUN yum install -y curl-minimal libcap openssl

# Add Wazuh repo and import GPG key
RUN rpm --import https://packages.wazuh.com/key/GPG-KEY-WAZUH && \
    echo -e "[wazuh]\n\
name=Wazuh repo\n\
baseurl=https://packages.wazuh.com/4.x/yum/\n\
gpgcheck=1\n\
gpgkey=https://packages.wazuh.com/key/GPG-KEY-WAZUH\n\
enabled=1" > /etc/yum.repos.d/wazuh.repo

# Copy check_repository script and execute (optional)
COPY config/check_repository.sh /
RUN chmod 775 /check_repository.sh && source /check_repository.sh

# Install Wazuh Dashboard
RUN yum install -y wazuh-dashboard-${WAZUH_VERSION}-${WAZUH_TAG_REVISION} && \
    yum clean all

# Create and set permissions to data directories
RUN mkdir -p $INSTALL_DIR/data/wazuh && chmod -R 775 $INSTALL_DIR/data/wazuh && \
    mkdir -p $INSTALL_DIR/data/wazuh/config && chmod -R 775 $INSTALL_DIR/data/wazuh/config && \
    mkdir -p $INSTALL_DIR/data/wazuh/logs && chmod -R 775 $INSTALL_DIR/data/wazuh/logs
COPY config/wazuh.yml $INSTALL_DIR/data/wazuh/config/

# Set node binary capabilities to bind privileged ports
RUN setcap 'cap_net_bind_service=-ep' $INSTALL_DIR/node/bin/node && \
    setcap 'cap_net_bind_service=-ep' $INSTALL_DIR/node/fallback/bin/node

# Copy configuration scripts
COPY config/config.sh .
COPY config/config.yml .
RUN bash config.sh


# ---------------- Runtime Stage ----------------
FROM amazonlinux:2023

ENV USER="wazuh-dashboard" \
    GROUP="wazuh-dashboard" \
    INSTALL_DIR="/usr/share/wazuh-dashboard"

# Update and install dependencies
RUN yum install -y shadow-utils && yum clean all

# Create user and group
RUN getent group $GROUP || groupadd -r -g 1000 $GROUP && \
    useradd --system --uid 1000 --no-create-home --home-dir $INSTALL_DIR \
            --gid $GROUP --shell /sbin/nologin --comment "$USER user" $USER

# Copy scripts and set permissions
COPY config/entrypoint.sh /entrypoint.sh
COPY config/wazuh_app_config.sh /wazuh_app_config.sh
RUN chmod 700 /entrypoint.sh /wazuh_app_config.sh && \
    chown 1000:1000 /*.sh

# Copy install directory from builder
COPY --from=builder --chown=1000:1000 $INSTALL_DIR $INSTALL_DIR

# Create directory for custom assets
RUN mkdir -p $INSTALL_DIR/plugins/wazuh/public/assets/custom && \
    chown 1000:1000 $INSTALL_DIR/plugins/wazuh/public/assets/custom

# Set workdir and user
WORKDIR $INSTALL_DIR
USER wazuh-dashboard

# Expose HTTPS port for dashboard (Traefik will terminate TLS)
EXPOSE 443

# Entrypoint
ENTRYPOINT ["/entrypoint.sh"]
