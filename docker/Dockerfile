# Intentionally vulnerable image for Trivy testing
FROM ubuntu:18.04

# Install outdated packages to trigger vulnerabilities
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        curl \
        nodejs \
        npm \
        openssl && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir /app && \
    echo 'console.log("Vulnerable test dashboard")' > /app/index.js

WORKDIR /app

# Initialize a dummy Node project
RUN npm init -y

# Default command
CMD ["node", "index.js"]
