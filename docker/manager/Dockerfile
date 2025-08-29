# Wazuh Docker Copyright (C) 2017, Wazuh Inc. (License GPLv2)
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
ARG S6_VERSION="v2.2.0.3"

# Install dependencies
RUN yum swap -y curl-minimal curl && \
    yum install -y xz gnupg tar gzip openssl findutils procps && \
    yum clean all

# Add Wazuh yum repo + GPG key
RUN rpm --import https://packages.wazuh.com/key/GPG-KEY-WAZUH && \
    echo -e "[wazuh]\n\
name=Wazuh repo\n\
baseurl=https://packages.wazuh.com/4.x/yum/\n\
gpgcheck=1\n\
gpgkey=https://packages.wazuh.com/key/GPG-KEY-WAZUH\n\
enabled=1" > /etc/yum.repos.d/wazuh.repo

# Copy helper scripts
COPY config/check_repository.sh / 
COPY config/filebeat_module.sh / 
COPY config/permanent_data.env config/permanent_data.sh /

RUN chmod 775 /check_repository.sh && /bin/bash -c "source /check_repository.sh"

# Install Wazuh Manager + Filebeat module + s6-overlay
RUN yum install -y wazuh-manager-${WAZUH_VERSION}-${WAZUH_TAG_REVISION} && \
    yum clean all && \
    chmod 775 /filebeat_module.sh && /bin/bash -c "source /filebeat_module.sh" && \
    rm /filebeat_module.sh && \
    \
    # Download s6-overlay using GitHub release direct URL
    curl -fSLJ -o /tmp/s6-overlay-x86_64.tar.xz \
      https://github.com/just-containers/s6-overlay/releases/download/${S6_VERSION}/s6-overlay-x86_64.tar.xz && \
    file /tmp/s6-overlay-x86_64.tar.xz && \
    \
    # Extract to temporary folder, then copy
    mkdir -p /tmp/s6 && \
    tar -xJf /tmp/s6-overlay-x86_64.tar.xz -C /tmp/s6 && \
    cp -r /tmp/s6/* / && \
    rm -rf /tmp/s6 /tmp/s6-overlay-x86_64.tar.xz

# Copy configs
COPY config/etc/ /etc/
COPY --chown=root:wazuh config/create_user.py /var/ossec/framework/scripts/create_user.py
COPY config/filebeat.yml /etc/filebeat/

RUN chmod go-w /etc/filebeat/filebeat.yml

# Load Filebeat Elasticsearch template
ADD https://raw.githubusercontent.com/wazuh/wazuh/$FILEBEAT_TEMPLATE_BRANCH/extensions/elasticsearch/7.x/wazuh-template.json /etc/filebeat
RUN chmod go-w /etc/filebeat/wazuh-template.json

# Prepare permanent data
RUN mkdir -p /var/ossec/var/multigroups && \
    chown root:wazuh /var/ossec/var/multigroups && chmod 770 /var/ossec/var/multigroups && \
    mkdir -p /var/ossec/agentless && \
    chown root:wazuh /var/ossec/agentless && chmod 770 /var/ossec/agentless && \
    mkdir -p /var/ossec/active-response/bin && \
    chown root:wazuh /var/ossec/active-response/bin && chmod 770 /var/ossec/active-response/bin && \
    chmod 755 /permanent_data.sh && sync && /permanent_data.sh && sync && rm /permanent_data.sh

# Cleanup (optional: remove wazuh repo after installation)
RUN rm -f /etc/yum.repos.d/wazuh.repo

# Ports
EXPOSE 55000/tcp 1514/tcp 1515/tcp 514/udp 1516/tcp

ENTRYPOINT ["/init"]
