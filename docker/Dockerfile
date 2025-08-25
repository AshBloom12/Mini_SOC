# Intentionally vulnerable image for testing Trivy
FROM ubuntu:18.04

# Install outdated packages to trigger vulnerabilities
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        curl=7.58.0-2ubuntu3.16 \
        nodejs \
        npm \
        openssl=1.1.1-1ubuntu2.1~18.04.20 && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir /app && \
    echo 'console.log("Vulnerable test dashboard")' > /app/index.js

WORKDIR /app

# Install node dependencies (none for now)
RUN npm init -y

CMD ["node", "index.js"]
