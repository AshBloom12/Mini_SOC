# Wazuh Docker Option 2 - Optimized Build
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

# Install dependencies, add Wazuh repo, and import GPG key
RUN yum install -y curl xz gnupg tar gzip openssl findutils procps && \
    rpm --import https://packages.wazuh.com/key/GPG-KEY-WAZUH && \
    echo -e "[wazuh]\nname=Wazuh repo\nbaseurl=https://packages.wazuh.com/4.x/yum/\ngpgcheck=1\ngpgkey=https://packages.wazuh.com/key/GPG-KEY-WAZUH\nenabled=1" > /etc/yum.repos.d/wazuh.repo && \
    yum clean all

# Copy helper scripts
COPY config/check_repository.sh / 
COPY config/filebeat_module.sh / 
COPY config/permanent_data.env config/permanent_data.sh /

RUN chmod +x /check_repository.sh /filebeat_module.sh /permanent_data.sh && \
    /bin/bash /check_repository.sh && \
    /bin/bash /filebeat_module.sh && \
    rm -f /filebeat_module.sh

# Install Wazuh Manager
RUN yum install -y wazuh-manager-${WAZUH_VERSION}-${WAZUH_TAG_REVISION} && yum clean all

# Download and install s6-overlay
RUN curl -fSLJ -o /tmp/s6-overlay-x86_64.tar.xz \
      https://github.com/just-containers/s6-overlay/releases/download/${S6_VERSION}/s6-overlay-x86_64.tar.xz && \
    tar -xJf /tmp/s6-overlay-x86_64.tar.xz -C / && \
    rm -f /tmp/s6-overlay-x86_64.tar.xz

# Copy configurations
COPY config/etc/ /etc/
COPY --chown=root:wazuh config/create_user.py /var/ossec/framework/scripts/create_user.py
COPY config/filebeat.yml /etc/filebeat/
ADD https://raw.githubusercontent.com/wazuh/wazuh/$FILEBEAT_TEMPLATE_BRANCH/extensions/elasticsearch/7.x/wazuh-template.json /etc/filebeat/

RUN chmod go-w /etc/filebeat/filebeat.yml /etc/filebeat/wazuh-template.json

# Prepare permanent data directories
RUN mkdir -p /var/ossec/var/multigroups /var/ossec/agentless /var/ossec/active-response/bin && \
    chown root:wazuh /var/ossec/var/multigroups /var/ossec/agentless /var/ossec/active-response/bin && \
    chmod 770 /var/ossec/var/multigroups /var/ossec/agentless /var/ossec/active-response/bin && \
    chmod +x /permanent_data.sh && /permanent_data.sh && rm -f /permanent_data.sh

# Cleanup Wazuh repo file
RUN rm -f /etc/yum.repos.d/wazuh.repo

# Expose ports
EXPOSE 55000/tcp 1514/tcp 1515/tcp 514/udp 1516/tcp

# Start container with s6-overlay
ENTRYPOINT ["/init"]
