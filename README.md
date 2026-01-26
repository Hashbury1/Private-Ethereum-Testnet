# Ethereum Private Testnet Deployment

A simple, reliable Ethereum testnet deployment using Geth in dev mode for development and testing purposes.

## 🚀 Quick Start

### Prerequisites

- Docker installed on your system
- Node.js (for running deployment scripts)
- Git (for version control)

### Local Deployment

Start the Ethereum testnet node with a single command:

```bash
docker run -d \
  --name eth-node \
  -p 8545:8545 \
  -p 8546:8546 \
  ethereum/client-go:latest \
  --dev \
  --dev.period 1 \
  --http \
  --http.addr "0.0.0.0" \
  --http.port 8545 \
  --http.api "eth,net,web3,personal,admin,miner,debug,txpool" \
  --http.corsdomain "*" \
  --http.vhosts "*" \
  --ws \
  --ws.addr "0.0.0.0" \
  --ws.port 8546 \
  --ws.api "eth,net,web3,personal,admin,miner,debug,txpool" \
  --ws.origins "*" \
  --verbosity 3
```

Wait 10-15 seconds for the node to start, then verify:

```bash
curl -X POST http://localhost:8545 \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}'
```

### GitHub Actions Deployment

The repository includes a GitHub Actions workflow that automatically deploys the testnet on push or manual trigger.

**Workflow file:** `.github/workflows/deploy-eth-node.yml`

To trigger manually:
1. Go to your repository on GitHub
2. Click "Actions" tab
3. Select "Deploy Ethereum Testnet"
4. Click "Run workflow"

## 📋 Configuration

### Network Details

- **RPC Endpoint:** `http://localhost:8545`
- **WebSocket Endpoint:** `ws://localhost:8546`
- **Chain ID:** `1337` (dev mode default)
- **Block Time:** 1 second
- **Pre-funded Account:** `0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266`

### Available APIs

The node exposes the following JSON-RPC APIs:
- `eth` - Ethereum-related methods
- `net` - Network information
- `web3` - Web3 utilities
- `personal` - Account management
- `admin` - Node administration
- `miner` - Mining control
- `debug` - Debugging tools
- `txpool` - Transaction pool inspection

## 🔧 Common Commands

### Managing the Node

**Start the node:**
```bash
docker run -d --name eth-node -p 8545:8545 -p 8546:8546 ethereum/client-go:latest --dev --dev.period 1 --http --http.addr "0.0.0.0" --http.port 8545 --http.api "eth,net,web3,personal,admin,miner,debug,txpool" --http.corsdomain "*" --http.vhosts "*" --ws --ws.addr "0.0.0.0" --ws.port 8546 --ws.api "eth,net,web3,personal,admin,miner,debug,txpool" --ws.origins "*"
```

**Stop the node:**
```bash
docker stop eth-node
```

**Remove the node:**
```bash
docker rm eth-node
```

**View logs:**
```bash
docker logs -f eth-node
```

**Check node status:**
```bash
docker ps | grep eth-node
```

### Testing RPC Connection

**Get current block number:**
```bash
curl -X POST http://localhost:8545 \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}'
```

**Get account balance:**
```bash
curl -X POST http://localhost:8545 \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"eth_getBalance","params":["0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266","latest"],"id":1}'
```

**Get network ID:**
```bash
curl -X POST http://localhost:8545 \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"net_version","params":[],"id":1}'
```

## 🐛 Troubleshooting

### Issue 1: "Failed to write genesis block: invalid chain configuration in blobSchedule"

**Symptoms:**
```
Fatal: Failed to write genesis block: invalid chain configuration in blobSchedule for fork "cancun": update fraction must be defined and non-zero
```

**Cause:** Using custom genesis.json with newer Geth versions that require complete blob schedule configuration.

**Solution:**
1. Remove any custom genesis.json files
2. Remove docker-compose.yml if it contains genesis initialization
3. Use pure `--dev` mode (no custom genesis needed)
4. Clean up old data:
   ```bash
   docker stop eth-node
   docker rm eth-node
   docker volume prune -f
   ```

### Issue 2: "ECONNREFUSED 127.0.0.1:8545"

**Symptoms:**
```
FetchError: request to http://localhost:8545/ failed, reason: connect ECONNREFUSED 127.0.0.1:8545
```

**Cause:** Ethereum node is not running or not ready yet.

**Solution:**
1. Check if container is running:
   ```bash
   docker ps | grep eth-node
   ```
2. If not running, start it with the docker run command above
3. Wait 10-15 seconds for the node to fully initialize
4. Check logs for errors:
   ```bash
   docker logs eth-node
   ```

### Issue 3: "invalid command: 'sh'" or "invalid command: 'geth'"

**Symptoms:**
```
invalid command: "sh"
invalid command: "geth"
```

**Cause:** Using shell wrapper commands (`sh -c`) with the geth Docker image.

**Solution:**
Pass geth flags directly without shell wrappers. Use the command format shown in Quick Start.

### Issue 4: "Geth only supports PoS networks"

**Symptoms:**
```
ERROR: Geth only supports PoS networks. Please transition legacy networks using Geth v1.13.x.
Fatal: Failed to register the Ethereum service: 'terminalTotalDifficulty' is not set in genesis block
```

**Cause:** Using old PoW (Proof of Work) genesis configuration with newer Geth that only supports PoS (Proof of Stake).

**Solution:**
Use `--dev` mode which automatically configures everything correctly. Avoid custom genesis files.

### Issue 5: "flag provided but not defined: -miner.threads"

**Symptoms:**
```
flag provided but not defined: -miner.threads
```

**Cause:** The `--miner.threads` flag was removed in newer Geth versions.

**Solution:**
Remove the `--miner.threads` flag from your command. Dev mode handles mining automatically.

### Issue 6: Container exits immediately

**Symptoms:**
Container starts but exits with code 1 immediately.

**Cause:** Usually due to configuration errors or conflicting flags.

**Solution:**
1. Check logs:
   ```bash
   docker logs eth-node
   ```
2. Ensure you're not mixing `--dev` with custom genesis
3. Remove any old volumes:
   ```bash
   docker volume rm $(docker volume ls -q | grep eth)
   ```

### Issue 7: GitHub Actions workflow fails

**Symptoms:**
Workflow shows genesis-related errors even though local deployment works.

**Cause:** Old workflow file with embedded genesis configuration.

**Solution:**
Update `.github/workflows/deploy-eth-node.yml` to use the simplified dev mode approach (see Quick Start section).

## 🧹 Complete Reset

If you're experiencing persistent issues, do a complete cleanup:

```bash
# Stop all containers
docker stop $(docker ps -aq)

# Remove all containers
docker rm $(docker ps -aq)

# Remove all volumes
docker volume prune -f

# Remove all unused images
docker system prune -a --volumes -f

# Start fresh
docker run -d --name eth-node -p 8545:8545 -p 8546:8546 ethereum/client-go:latest --dev --dev.period 1 --http --http.addr "0.0.0.0" --http.port 8545 --http.api "eth,net,web3,personal,admin,miner,debug,txpool" --http.corsdomain "*" --http.vhosts "*" --ws --ws.addr "0.0.0.0" --ws.port 8546 --ws.api "eth,net,web3,personal,admin,miner,debug,txpool" --ws.origins "*"
```

## 📚 Additional Resources

### Connecting from JavaScript

```javascript
const Web3 = require('web3');
const web3 = new Web3('http://localhost:8545');

async function test() {
  const blockNumber = await web3.eth.getBlockNumber();
  console.log('Current block:', blockNumber);
  
  const accounts = await web3.eth.getAccounts();
  console.log('Accounts:', accounts);
}

test();
```

### Using ethers.js

```javascript
const { ethers } = require('ethers');

const provider = new ethers.JsonRpcProvider('http://localhost:8545');

async function test() {
  const blockNumber = await provider.getBlockNumber();
  console.log('Current block:', blockNumber);
  
  const balance = await provider.getBalance('0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266');
  console.log('Balance:', ethers.formatEther(balance), 'ETH');
}

test();
```

### Connecting from MetaMask

1. Open MetaMask
2. Click network dropdown → "Add Network"
3. Enter details:
   - **Network Name:** Local Testnet
   - **RPC URL:** `http://localhost:8545`
   - **Chain ID:** `1337`
   - **Currency Symbol:** ETH
4. Save and switch to the network

## ⚙️ Advanced Configuration

### Running with Persistent Data

If you need data to persist across restarts:

```bash
mkdir -p ./eth-data

docker run -d \
  --name eth-node \
  -p 8545:8545 \
  -p 8546:8546 \
  -v $(pwd)/eth-data:/data \
  ethereum/client-go:latest \
  --dev \
  --dev.period 1 \
  --datadir /data \
  --http \
  --http.addr "0.0.0.0" \
  --http.port 8545 \
  --http.api "eth,net,web3,personal,admin,miner,debug,txpool" \
  --http.corsdomain "*" \
  --http.vhosts "*" \
  --ws \
  --ws.addr "0.0.0.0" \
  --ws.port 8546 \
  --ws.api "eth,net,web3,personal,admin,miner,debug,txpool" \
  --ws.origins "*"
```

### Changing Block Time

Modify `--dev.period` value (in seconds):

```bash
--dev.period 5  # 5 second blocks
--dev.period 0  # Instant blocks (mines only when transactions are pending)
```

## 🔒 Security Notes

⚠️ **WARNING:** This setup is for **development and testing only**. Never use in production:

- `--allow-insecure-unlock` is enabled
- No authentication on RPC endpoints
- CORS is wide open (`*`)
- No network security
- Private keys are not secured

## 📝 License

This project is open source and available under the MIT License.

## 🤝 Contributing

Contributions, issues, and feature requests are welcome!

## 📧 Support

If you encounter issues not covered in this README:
1. Check the [Troubleshooting](#-troubleshooting) section
2. Review container logs: `docker logs eth-node`
3. Open an issue with detailed error messages and steps to reproduce
