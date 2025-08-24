# TLS/HTTPS Policy – Mini-SOC Project

## 1. Objective
This document defines the policy for securing communications within the Mini-SOC project using TLS/HTTPS. The goal is to ensure confidentiality, integrity, and authenticity of all traffic exposed over the public internet.

## 2. Scope
This policy applies to:
- Wazuh Dashboard (public-facing service).
- Internal communications between nodes (Dashboard, Manager, Indexer).
- Reverse proxy (Traefik) that terminates TLS.

## 3. TLS Termination
- All external HTTPS connections are terminated at Traefik (running on the Dashboard node).
- Traefik uses a self-signed certificate generated manually for the public IP address of the Dashboard node.
- Certificates and keys are securely stored and injected into the deployment using Ansible Vault.

## 4. Certificate Management
- **Public Access:** Since no public domain is available, a self-signed certificate is used for external access.
- **Renewal:** Self-signed certificates must be manually regenerated at least every 12 months.
- **Storage:** Certificates and private keys are never stored in plain text inside the repository. They are encrypted with Ansible Vault.

## 5. Protocols and Cipher Suites
- TLS 1.2 and TLS 1.3 are required.
- SSLv2, SSLv3, TLS 1.0, and TLS 1.1 are disabled.
- Strong ciphers are enforced (no known weak algorithms such as RC4, MD5, or SHA1).

## 6. Trust Model
- For self-signed certificates: The certificate must be manually distributed and installed in trusted stores of client systems.
- Users accessing the Wazuh Dashboard must accept the self-signed certificate in their browser or import it into their system trust store.

## 7. Security Controls
- The certificate and private key are encrypted in `ansible/inventory/production/group_vars/vault.yml` using **Ansible Vault**.
- Only the Traefik service has access to the decrypted certificate and key at runtime.
- Certificates and keys must never be committed in plain text to version control repositories.
- Access to Ansible Vault requires a passphrase known only to the project administrators.

## 8. Incident Handling
- If a certificate or private key is compromised, it must be replaced immediately with a newly generated self-signed certificate.
- All nodes and users must be notified of the incident and instructed to update their trust store if required.

## 9. Exceptions
- For the Mini-SOC project, automated certificate expiration monitoring is not enforced.
- In production environments, automated certificate lifecycle management (e.g., Let’s Encrypt or an internal CA) must be implemented.

## 10. Review
This TLS/HTTPS policy must be reviewed at least annually or after any major change in:
- TLS protocols or cipher vulnerabilities.
- Certificate management practices.
- Infrastructure hosting (e.g., migration to a new cloud provider).
