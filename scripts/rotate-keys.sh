#!/bin/bash
set -e

if [ -z "$1" ]; then
    echo "Usage: $0 <node-number>"
    exit 1
fi

NODE_NUM=$1
NODE_DIR="nodes/node${NODE_NUM}"

echo "🔄 Rotating keys for node${NODE_NUM}..."

# Backup old keystore
BACKUP_DIR="$NODE_DIR/keystore.backup.$(date +%Y%m%d_%H%M%S)"
cp -r "$NODE_DIR/keystore" "$BACKUP_DIR"
echo "📦 Old keystore backed up to: $BACKUP_DIR"

# Generate new account
NEW_PASSWORD="node${NODE_NUM}password_$(date +%s)"
echo "$NEW_PASSWORD" > "$NODE_DIR/password.txt.new"

NEW_ADDRESS=$(docker run --rm -v "$(pwd)/$NODE_DIR:/root/.ethereum" \
    ethereum/client-go:latest \
    account new --password /root/.ethereum/password.txt.new 2>&1 | \
    grep -oP 'Public address of the key:\s+\K0x[a-fA-F0-9]+')

mv "$NODE_DIR/password.txt.new" "$NODE_DIR/password.txt"

echo "✅ New key generated: $NEW_ADDRESS"
echo "⚠️  Update docker-compose.yml with new address"
echo "⚠️  Propose new validator and remove old one from network"