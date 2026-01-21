#!/bin/bash
set -e

echo "🗝️  Generating Ethereum PoA test network..."

# Create directories
mkdir -p nodes/{node1,node2,node3,bootnode}/data/keystore config

# Create password file IN THE WORKSPACE (will be mounted)
echo "testpass" > password.txt

# Generate validator accounts (3 nodes) - MOUNT the password file
for i in {1..3}; do
  echo "Generating validator $i..."
  docker run --rm -v $(pwd):/workspace -v $(pwd)/password.txt:/workspace/password.txt ethereum/client-go:alltools-v1.14.11 geth account new \
    --datadir /workspace/nodes/node$i/data \
    --password /workspace/password.txt
done

# Extract validator addresses (jq required - install if missing)
if ! command -v jq &> /dev/null; then
    echo "Installing jq..."
    sudo apt-get update && sudo apt-get install -y jq  # Ubuntu/Debian
    # or: brew install jq  # macOS
fi

ADDR1=$(cat nodes/node1/data/keystore/* | jq -r '.address')
ADDR2=$(cat nodes/node2/data/keystore/* | jq -r '.address') 
ADDR3=$(cat nodes/node3/data/keystore/* | jq -r '.address')

echo "✅ Validators: $ADDR1, $ADDR2, $ADDR3"

# Generate bootnode keypair
docker run --rm -v $(pwd):/workspace ethereum/client-go:alltools-v1.14.11 bootnode -genkey /workspace/nodes/bootnode/boot.key
BOOTNODE_ENODE=$(docker run --rm -v $(pwd):/workspace ethereum/client-go:alltools-v1.14.11 bootnode -nodekey /workspace/nodes/bootnode/boot.key)

echo "🌐 Bootnode: $BOOTNODE_ENODE" > nodes/bootnode/enode

# Create genesis.json (Clique PoA)
cat > config/genesis.json << EOF
{
  "config": {
    "chainId": 1451,
    "homesteadBlock": 0,
    "eip150Block": 0,
    "eip155Block": 0,
    "eip158Block": 0,
    "clique": {
      "period": 5,
      "epoch": 30000
    }
  },
  "nonce": "0x0",
  "timestamp": "0x0",
  "extraData": "0x000000000000000000000000000000000000000000000000$(echo $ADDR1 | sed 's/^0x//')0000000000000000000000000000000000000000000000000000000000000000$(echo $ADDR2 | sed 's/^0x//')0000000000000000000000000000000000000000000000000000000000000000$(echo $ADDR3 | sed 's/^0x//')0000000000000000000000000000000000000000000000000000000000000000",
  "gasLimit": "0x2fefd8",
  "difficulty": "0x1",
  "mixHash": "0x0000000000000000000000000000000000000000000000000000000000000000",
  "coinbase": "0x0000000000000000000000000000000000000000",
  "alloc": {
    "$ADDR1": { "balance": "0xad78ebc5ac6200000" },
    "$ADDR2": { "balance": "0xad78ebc5ac6200000" },
    "$ADDR3": { "balance": "0xad78ebc5ac6200000" }
  }
}
EOF

# Initialize each node with genesis
for i in {1..3}; do
  docker run --rm -v $(pwd):/workspace ethereum/client-go:alltools-v1.14.11 \
    geth init --datadir /workspace/nodes/node$i/data /workspace/config/genesis.json
done

echo "✅ Network generated! Keystores ready in nodes/node*/data/keystore/"
echo "Deployer address: $ADDR1 (password: testpass)"
echo "password.txt created - delete after use for security"
