# Wazuh Dockerfile
FROM amazonlinux:2023

# Use bash instead of sh
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

# Arguments
ARG WAZUH_VERSION
ARG WAZUH_TAG_REVISION
ARG FILEBEAT_VERSION=7.10.2
ARG S6_VERSION="v3.2.1.0"

# Basic dependencies
RUN yum install -y curl-minimal xz gnupg tar gzip openssl findutils procps git && \
    yum clean all

# Copy scripts
COPY config/check_repository.sh /check_repository.sh
COPY config/filebeat_module.sh /filebeat_module.sh
COPY config/permanent_data.env config/permanent_data.sh /

RUN chmod 775 /check_repository.sh /filebeat_module.sh
RUN source /check_repository.sh

# 1. Install Wazuh Manager
RUN yum install -y wazuh-manager-${WAZUH_VERSION}-${WAZUH_TAG_REVISION} && \
    yum clean all

# 2. Install Filebeat and Wazuh module
RUN bash /filebeat_module.sh
RUN rm /filebeat_module.sh

# 3. Download s6-overlay
RUN curl -fL -o /tmp/s6-overlay-amd64.tar.xz \
    https://github.com/just-containers/s6-overlay/releases/download/${S6_VERSION}/s6-overlay-x86_64.tar.xz

# 4. Extract s6-overlay
RUN tar -xJf /tmp/s6-overlay-amd64.tar.xz -C / && \
    rm /tmp/s6-overlay-amd64.tar.xz

# 5. Copy configuration
COPY config/etc/ /etc/
COPY --chown=root:wazuh config/create_user.py /var/ossec/framework/scripts/create_user.py
COPY config/filebeat.yml /etc/filebeat/
RUN chmod go-w /etc/filebeat/filebeat.yml

# 6. Add Filebeat template
ARG FILEBEAT_TEMPLATE_BRANCH=main
ADD https://raw.githubusercontent.com/wazuh/wazuh/$FILEBEAT_TEMPLATE_BRANCH/extensions/elasticsearch/7.x/wazuh-template.json /etc/filebeat/
RUN chmod go-w /etc/filebeat/wazuh-template.json

# 7. Prepare permanent data directories
RUN mkdir -p /var/ossec/var/multigroups && \
    chown root:wazuh /var/ossec/var/multigroups && chmod 770 /var/ossec/var/multigroups && \
    mkdir -p /var/ossec/agentless && \
    chown root:wazuh /var/ossec/agentless && chmod 770 /var/ossec/agentless && \
    mkdir -p /var/ossec/active-response/bin && \
    chown root:wazuh /var/ossec/active-response/bin && chmod 770 /var/ossec/active-response/bin && \
    chmod 755 /permanent_data.sh && sync && /permanent_data.sh && sync && rm /permanent_data.sh

# Remove Wazuh repo
RUN rm /etc/yum.repos.d/wazuh.repo

# Ports
EXPOSE 55000/tcp 1514/tcp 1515/tcp 514/udp 1516/tcp

ENTRYPOINT [ "/init" ]
