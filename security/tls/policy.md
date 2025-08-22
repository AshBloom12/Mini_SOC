# TLS/HTTPS Policy – Mini-SOC Project

## 1. Objective
This document defines the policy for securing communications within the Mini-SOC project using TLS/HTTPS. The goal is to ensure confidentiality, integrity, and authenticity of all traffic exposed over the public internet.

## 2. Scope
This policy applies to:
- Wazuh Dashboard (public-facing service).
- Internal communications between nodes (Dashboard, Manager, Indexer).
- Reverse proxy (Traefik) that terminates TLS.

## 3. TLS Termination
- All external HTTPS connections are terminated at **Traefik** (running on the Dashboard node).
- Traefik uses **Let’s Encrypt ACME** certificates for automatic provisioning and renewal.
- Certificates are stored securely in the file `acme.json` with strict permissions (`0600`).

## 4. Certificate Management
- **Public Access:** Let’s Encrypt certificates are obtained automatically for public domains.
- **Fallback:** For testing or internal setups without a domain, self-signed certificates may be used.
- **Renewal:** Let’s Encrypt certificates renew automatically via ACME. Self-signed certificates must be regenerated manually every 12 months if used.

## 5. Protocols and Cipher Suites
- TLS 1.2 and TLS 1.3 are required.
- SSLv2, SSLv3, TLS 1.0, and TLS 1.1 are disabled.
- Strong ciphers are enforced (no known weak algorithms such as RC4, MD5, or SHA1).

## 6. Trust Model
- For public certificates: Clients automatically trust Let’s Encrypt CA.
- For self-signed/internal certificates: The certificate must be manually distributed and installed in trusted stores of client systems.

## 7. Security Controls
- The `acme.json` file storing certificates and keys is protected with `0600` permissions.
- Only the Traefik service user has access to certificate files.
- Certificates and keys must never be stored in version control repositories.
- Secrets are injected via **Docker Swarm secrets** where possible.

## 8. Incident Handling
- If a certificate is compromised, it must be revoked immediately via Let’s Encrypt ACME.
- A new certificate must be requested and deployed without delay.
- All nodes and users must be notified of the incident.

## 9. Exceptions
- For the Mini-SOC educational project, certificate expiration monitoring and automated alerting is not enforced.
- In production, continuous monitoring of TLS certificate status is required.

## 10. Review
This TLS/HTTPS policy must be reviewed at least annually or after any major change in:
- TLS protocols or cipher vulnerabilities.
- Certificate management practices.
- Infrastructure hosting (e.g., migration to new cloud provider).
