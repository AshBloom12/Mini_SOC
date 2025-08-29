#!/usr/bin/env bash
set -e

CERTS_DIR="$(dirname "$0")/../certs"
INDEXER_DIR="$CERTS_DIR/indexer"
DASHBOARD_DIR="$CERTS_DIR/dashboard"

mkdir -p "$INDEXER_DIR" "$DASHBOARD_DIR"

echo "Generating Root CA..."
openssl genrsa -out "$INDEXER_DIR/root-ca.key" 4096
openssl req -x509 -new -nodes -key "$INDEXER_DIR/root-ca.key" -sha256 -days 3650 -out "$INDEXER_DIR/root-ca.pem" -subj "/C=US/ST=California/L=San Francisco/O=Wazuh/CN=Wazuh-Root-CA"

# Copy CA for dashboard
cp "$INDEXER_DIR/root-ca.pem" "$DASHBOARD_DIR/root-ca.pem"

echo "Generating Indexer certificate..."
openssl genrsa -out "$INDEXER_DIR/indexer-key.pem" 4096
openssl req -new -key "$INDEXER_DIR/indexer-key.pem" -out "$INDEXER_DIR/indexer.csr" -subj "/C=US/ST=California/L=San Francisco/O=Wazuh/CN=wazuh-indexer"
openssl x509 -req -in "$INDEXER_DIR/indexer.csr" -CA "$INDEXER_DIR/root-ca.pem" -CAkey "$INDEXER_DIR/root-ca.key" -CAcreateserial -out "$INDEXER_DIR/indexer.pem" -days 365 -sha256
rm "$INDEXER_DIR/indexer.csr"

echo "Generating Dashboard certificate..."
openssl genrsa -out "$DASHBOARD_DIR/dashboard-key.pem" 4096
openssl req -new -key "$DASHBOARD_DIR/dashboard-key.pem" -out "$DASHBOARD_DIR/dashboard.csr" -subj "/C=US/ST=California/L=San Francisco/O=Wazuh/CN=wazuh-dashboard"
openssl x509 -req -in "$DASHBOARD_DIR/dashboard.csr" -CA "$DASHBOARD_DIR/root-ca.pem" -CAkey "$INDEXER_DIR/root-ca.key" -CAcreateserial -out "$DASHBOARD_DIR/dashboard.pem" -days 365 -sha256
rm "$DASHBOARD_DIR/dashboard.csr"

echo "Certificates generated successfully in:"
echo " - $INDEXER_DIR"
echo " - $DASHBOARD_DIR"
