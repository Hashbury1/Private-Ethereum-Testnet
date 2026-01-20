#!/bin/bash
set -e

echo "➕ Adding new validator to the network..."

# Get next node number
NEXT_NODE=$(ls -d nodes/node* 2>/dev/null | wc -l)
NEXT_NODE=$((NEXT_NODE + 1))

NODE_DIR="nodes/node${NEXT_NODE}"
mkdir -p "$NODE_DIR/keystore"

# Generate new account
PASSWORD="node${NEXT_NODE}password"
echo "$PASSWORD" > "$NODE_DIR/password.txt"

echo "🔑 Generating new validator account..."
ADDRESS=$(docker run --rm -v "$(pwd)/$NODE_DIR:/root/.ethereum" \
    ethereum/client-go:latest \
    account new --password /root/.ethereum/password.txt 2>&1 | \
    grep -oP 'Public address of the key:\s+\K0x[a-fA-F0-9]+')

# Initialize with existing genesis
docker run --rm \
    -v "$(pwd)/genesis.json:/genesis.json" \
    -v "$(pwd)/$NODE_DIR:/root/.ethereum" \
    ethereum/client-go:latest \
    init /genesis.json

echo "✅ New validator created: $ADDRESS"
echo "📝 Add this address to genesis extradata and restart the network"
echo "💡 Then propose the validator using Clique API from an existing validator:"
echo "   clique.propose(\"$ADDRESS\", true)"