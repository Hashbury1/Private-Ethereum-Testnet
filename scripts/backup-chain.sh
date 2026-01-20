#!/bin/bash
set -e

BACKUP_DIR="backups/$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

echo "💾 Backing up blockchain data..."

# Backup each node's data
for node in nodes/node*; do
    if [ -d "$node" ]; then
        node_name=$(basename "$node")
        tar -czf "$BACKUP_DIR/${node_name}.tar.gz" "$node"
        echo "  ✅ Backed up: $node_name"
    fi
done

# Backup genesis
cp genesis.json "$BACKUP_DIR/"

# Backup docker-compose
cp docker-compose.yml "$BACKUP_DIR/"

echo "✅ Backup complete: $BACKUP_DIR"
echo "📊 Backup size: $(du -sh $BACKUP_DIR | cut -f1)"