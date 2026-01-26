
# Private Ethereum PoA Testnet

A production-ready private Ethereum Proof of Authority network with automation, monitoring, and management tools.


## Tools and Concept

Blockchain: Geth (Go-Ethereum) with Clique PoA
Containerization: Docker & Docker Compose
Orchestration: Docker Compose / Kubernetes (optional)
Block Explorer: Blockscout
Monitoring: Prometheus + Grafana
Scripting: Bash scripts for automation
IaC: Terraform (optional for cloud deployment)
CI/CD: GitHub Actions


## Architecture 

┌─────────────────────────────────────────────────────────┐
│                  Private Ethereum Network                │
├─────────────────────────────────────────────────────────┤
│                                                           │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐              │
│  │ Validator│  │ Validator│  │ Validator│              │
│  │  Node 1  │  │  Node 2  │  │  Node 3  │              │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘              │
│       │             │             │                      │
│       └─────────────┴─────────────┘                      │
│                     │                                    │
│       ┌─────────────┴─────────────┐                      │
│       │                           │                      │
│  ┌────▼─────┐              ┌─────▼────┐                 │
│  │  Block   │              │  RPC     │                 │
│  │ Explorer │              │  Node    │                 │
│  │(Blockscout)│            │          │                 │
│  └──────────┘              └──────────┘                 │
│                                                           │
│  ┌──────────┐              ┌──────────┐                 │
│  │Prometheus│              │ Grafana  │                 │
│  │Monitoring│              │Dashboard │                 │
│  └──────────┘              └──────────┘                 │
└─────────────────────────────────────────────────────────┘




## Features

- ✅ Multi-node PoA consensus (Clique)
- ✅ Block explorer (Blockscout)
- ✅ Automated bootstrapping
- ✅ Validator management scripts
- ✅ Monitoring (Prometheus + Grafana)
- ✅ Backup and recovery
- ✅ Docker Compose orchestration

## Quick Start

### 1. Bootstrap the Network
```bash
./scripts/bootstrap.sh 3
```

### 2. Start the Network
```bash
docker-compose up -d
```

### 3. Access Services

- **RPC Endpoint:** http://localhost:8545
- **Block Explorer:** http://localhost:4000
- **Grafana:** http://localhost:3000 (admin/admin)
- **Prometheus:** http://localhost:9090

## Management

### Add a Validator
```bash
./scripts/add-validator.sh
```

### Remove a Validator
```bash
./scripts/remove-validator.sh 0xVALIDATOR_ADDRESS
```

### Rotate Keys
```bash
./scripts/rotate-keys.sh 1
```

### Reset Chain
```bash
./scripts/reset-chain.sh
```

### Backup Data
```bash
./scripts/backup-chain.sh
```

## Network Configuration

- **Chain ID:** 1337
- **Block Time:** 5 seconds
- **Consensus:** Clique PoA
- **Initial Balance:** 1000 ETH per validator

## Monitoring

View metrics in Grafana:
1. Navigate to http://localhost:3000
2. Login with admin/admin
3. Import Geth dashboard (ID: 6976)

## Testing
```bash
# Connect to node
geth attach http://localhost:8545

# Check peer count
> net.peerCount

# Get block number
> eth.blockNumber

# Propose new validator
> clique.propose("0xNEW_VALIDATOR", true)
```

## Architecture
```
[Validator Node 1] ←→ [Validator Node 2] ←→ [Validator Node 3]
         ↓                    ↓                      ↓
    [Block Explorer]     [Monitoring]          [RPC Access]
```

## Troubleshooting

### Nodes not connecting
- Check `static-nodes.json` exists in each node directory
- Verify Docker network connectivity
- Check firewall rules or ports. 


### Mining not starting
- Verify validator address in extradata
- Check unlock password is correct
- Ensure at least 51% of validators are online

## Security Notes

This is for development/testing only:

- Private keys stored in plaintext
- RPC endpoints exposed without auth
- `--allow-insecure-unlock` enabled

For production use:

- Implement proper key management (Vault, AWS secrets)
- Add authentication to RPC endpoints
- Use TLS for all communications
- Implement network segmentation
* Not using Genesis.json will help out 
```

