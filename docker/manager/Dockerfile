# Wazuh Docker for Amazon Linux 2023
FROM amazonlinux:2023

# Use bash as default shell
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

# Arguments
ARG WAZUH_VERSION
ARG WAZUH_TAG_REVISION
ARG FILEBEAT_TEMPLATE_BRANCH
ARG FILEBEAT_CHANNEL=filebeat-oss
ARG FILEBEAT_VERSION=7.10.2
ARG WAZUH_FILEBEAT_MODULE
ARG S6_VERSION="v3.2.1.0"


# Update system and install dependencies
RUN dnf -y upgrade --refresh && \
    dnf -y install \
        curl \
        tar \
        gzip \
        findutils \
        procps \
        gnupg2 \
        openssl \
        python3 \
        python3-pip \
        which && \
    dnf clean all

# Add Wazuh YUM repository
RUN rpm --import https://packages.wazuh.com/key/GPG-KEY-WAZUH && \
    tee /etc/yum.repos.d/wazuh.repo <<'EOF'
[wazuh]
name=Wazuh repo
baseurl=https://packages.wazuh.com/4.x/yum/
gpgcheck=1
gpgkey=https://packages.wazuh.com/key/GPG-KEY-WAZUH
enabled=1
EOF

# Copy helper scripts
COPY config/check_repository.sh / 
COPY config/filebeat_module.sh / 
COPY config/permanent_data.env config/permanent_data.sh /
RUN chmod +x /check_repository.sh && /bin/bash /check_repository.sh

# Install Wazuh Manager
RUN dnf -y install wazuh-manager-${WAZUH_VERSION}-${WAZUH_TAG_REVISION} && dnf clean all

# Install Filebeat module safely
RUN chmod +x /filebeat_module.sh && /bin/bash /filebeat_module.sh && rm /filebeat_module.sh

# Download and install s6-overlay safely
RUN curl -fSLJ -o /tmp/s6-overlay-x86_64.tar.xz \
      https://github.com/just-containers/s6-overlay/releases/download/${S6_VERSION}/s6-overlay-x86_64.tar.xz && \
    tar -xJf /tmp/s6-overlay-x86_64.tar.xz -C / && \
    rm -rf /tmp/s6-overlay-x86_64.tar.xz

# Copy configs
COPY config/etc/ /etc/
COPY --chown=root:wazuh config/create_user.py /var/ossec/framework/scripts/create_user.py
COPY config/filebeat.yml /etc/filebeat/
RUN chmod go-w /etc/filebeat/filebeat.yml

# Load Filebeat Elasticsearch template
ADD https://raw.githubusercontent.com/wazuh/wazuh/$FILEBEAT_TEMPLATE_BRANCH/extensions/elasticsearch/7.x/wazuh-template.json /etc/filebeat
RUN chmod go-w /etc/filebeat/wazuh-template.json

# Prepare permanent data
RUN mkdir -p /var/ossec/var/multigroups /var/ossec/agentless /var/ossec/active-response/bin && \
    chown root:wazuh /var/ossec/var/multigroups /var/ossec/agentless /var/ossec/active-response/bin && \
    chmod 770 /var/ossec/var/multigroups /var/ossec/agentless /var/ossec/active-response/bin && \
    chmod +x /permanent_data.sh && /permanent_data.sh && rm /permanent_data.sh

# Cleanup
RUN rm -f /etc/yum.repos.d/wazuh.repo

# Ports
EXPOSE 55000/tcp 1514/tcp 1515/tcp 514/udp 1516/tcp

ENTRYPOINT ["/init"]
