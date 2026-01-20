#!/bin/bash
set -e

echo "⚠️  WARNING: This will delete all blockchain data!"
read -p "Are you sure? (type 'yes' to confirm): " confirm

if [ "$confirm" != "yes" ]; then
    echo "❌ Aborted"
    exit 1
fi

echo "🗑️  Stopping all containers..."
docker-compose down

echo "🧹 Removing chain data..."
for node in nodes/node*; do
    if [ -d "$node/geth" ]; then
        rm -rf "$node/geth"
        echo "  Cleaned: $node"
    fi
done

echo "♻️  Reinitializing nodes..."
./scripts/bootstrap.sh

echo "✅ Chain reset complete. Start network with: docker-compose up -d"