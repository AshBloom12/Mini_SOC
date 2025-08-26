# Intentionally vulnerable Dockerfile for testing purposes

# Use an intentionally old base image
FROM alpine:3.10

# Install an old version of bash (known CVE: CVE-2019-18276) and curl for testing
RUN apk add --no-cache bash=5.0.0-r0 curl

# Set a default command
CMD ["sh"]
