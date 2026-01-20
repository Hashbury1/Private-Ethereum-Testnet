#!/bin/bash
set -e

echo "🚀 Bootstrapping Ethereum PoA Network..."

# Configuration
NUM_VALIDATORS=${1:-3}
NETWORK_ID=1337
DATA_DIR="./nodes"

# Clean previous data
if [ -d "$DATA_DIR" ]; then
    read -p "Remove existing network data? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -rf "$DATA_DIR"
    fi
fi

# Create directories
mkdir -p "$DATA_DIR"

# Generate validator accounts
echo "📝 Generating validator accounts..."
VALIDATOR_ADDRESSES=()

for i in $(seq 1 $NUM_VALIDATORS); do
    NODE_DIR="$DATA_DIR/node$i"
    mkdir -p "$NODE_DIR/keystore"
    
    # Generate account
    PASSWORD="node${i}password"
    echo "$PASSWORD" > "$NODE_DIR/password.txt"
    
    ADDRESS=$(docker run --rm -v "$(pwd)/$NODE_DIR:/root/.ethereum" \
        ethereum/client-go:latest \
        account new --password /root/.ethereum/password.txt 2>&1 | \
        grep -oP 'Public address of the key:\s+\K0x[a-fA-F0-9]+')
    
    VALIDATOR_ADDRESSES+=("$ADDRESS")
    echo "✅ Node $i: $ADDRESS"
done

# Build extradata for genesis
echo "🔧 Building genesis configuration..."
EXTRADATA="0x0000000000000000000000000000000000000000000000000000000000000000"
for addr in "${VALIDATOR_ADDRESSES[@]}"; do
    EXTRADATA="${EXTRADATA}${addr:2}"
done
EXTRADATA="${EXTRADATA}0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"

# Update genesis.json
ALLOC=""
for addr in "${VALIDATOR_ADDRESSES[@]}"; do
    ALLOC="${ALLOC}\"$addr\": { \"balance\": \"1000000000000000000000\" },"
done
ALLOC="${ALLOC%,}"

cat > genesis.json <<EOF
{
  "config": {
    "chainId": $NETWORK_ID,
    "homesteadBlock": 0,
    "eip150Block": 0,
    "eip155Block": 0,
    "eip158Block": 0,
    "byzantiumBlock": 0,
    "constantinopleBlock": 0,
    "petersburgBlock": 0,
    "istanbulBlock": 0,
    "berlinBlock": 0,
    "londonBlock": 0,
    "clique": {
      "period": 5,
      "epoch": 30000
    }
  },
  "difficulty": "1",
  "gasLimit": "8000000",
  "extradata": "$EXTRADATA",
  "alloc": {
    $ALLOC
  }
}
EOF

# Initialize nodes with genesis
echo "⚙️  Initializing nodes..."
for i in $(seq 1 $NUM_VALIDATORS); do
    docker run --rm \
        -v "$(pwd)/genesis.json:/genesis.json" \
        -v "$(pwd)/$DATA_DIR/node$i:/root/.ethereum" \
        ethereum/client-go:latest \
        init /genesis.json
    echo "✅ Node $i initialized"
done

# Generate enode URLs
echo "🔗 Generating static-nodes.json..."
STATIC_NODES="["

for i in $(seq 1 $NUM_VALIDATORS); do
    BOOTKEY=$(docker run --rm \
        -v "$(pwd)/$DATA_DIR/node$i:/root/.ethereum" \
        ethereum/client-go:latest \
        --datadir /root/.ethereum \
        --exec "admin.nodeInfo.enode" \
        console 2>/dev/null | grep -oP 'enode://[^"]+')
    
    # Replace IP with service name
    BOOTKEY=$(echo "$BOOTKEY" | sed "s/@[^:]*:/@node$i:/")
    STATIC_NODES="${STATIC_NODES}\"$BOOTKEY\","
done

STATIC_NODES="${STATIC_NODES%,}]"

# Save static nodes for each node
for i in $(seq 1 $NUM_VALIDATORS); do
    echo "$STATIC_NODES" > "$DATA_DIR/node$i/static-nodes.json"
done

echo "✅ Network bootstrapped successfully!"
echo "📊 Validator addresses:"
for i in "${!VALIDATOR_ADDRESSES[@]}"; do
    echo "   Node $((i+1)): ${VALIDATOR_ADDRESSES[$i]}"
done