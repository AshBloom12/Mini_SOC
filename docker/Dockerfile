# Intentionally vulnerable image to test trivy scan
# Use an older base image with known vulnerabilities
FROM ubuntu:18.04

# Install required packages (including outdated versions to trigger Trivy)
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    curl=7.58.0-2ubuntu3.16 \
    openssl=1.1.1-1ubuntu2.1~18.04.20 \
    nodejs npm && \
    rm -rf /var/lib/apt/lists/*

# Copy the actual Wazuh dashboard files from build context
COPY . /app
WORKDIR /app

# Install Node dependencies
RUN npm install

# Default command to run dashboard
CMD ["npm", "start"]
