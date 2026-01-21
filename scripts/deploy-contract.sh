#!/bin/bash
set -e

echo "📜 Deploying Smart Contract..."

# Install dependencies
cd deploy/
npm init -y
npm install web3

# Get deployer account from node1 keystore (password: testpass)
DEPLOYER_ADDR=$(cat ../nodes/node1/data/keystore/* | jq -r '.address')
echo "👤 Deployer Address: $DEPLOYER_ADDR"

# Simple deploy script
cat > deploy.js << JS
const Web3 = require('web3');
const fs = require('fs');

const web3 = new Web3('http://localhost:8545');  // Update with your RPC port

// Load deployer keystore
const keystorePath = '../nodes/node1/data/keystore/*';
const keystoreFiles = fs.readdirSync(keystorePath);
const keystore = JSON.parse(fs.readFileSync(keystoreFiles[0]));
const deployerAccount = web3.eth.accounts.decrypt(keystore, 'testpass');

console.log('Deployer unlocked:', deployerAccount.address);

// Deploy simple counter contract
const bytecode = '608060405234801561001057600080fd5b5060c78061001f6000396000f3fe6080604052348015600f57600080fd5b506004361060325760003560e01c806399a8bbde146037575b600080fd5b603f6065565b60405190815260200160405180910390f35b60008060009050600160009090046001908152602001908152602001600020600060009060ff1660ff1681565b9291505056fea2646970667358221220a0b1c3f4e5d6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a264736f6c63430008070033';
const abi = [{"inputs":[],"name":"getCount","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"increment","outputs":[],"stateMutability":"nonpayable","type":"function"}];

const contract = new web3.eth.Contract(abi);
const tx = contract.deploy({data: '0x' + bytecode}).send({from: deployerAccount.address, gas: 1000000});
tx.then(deployment => {
  console.log('✅ Deployed to:', deployment.options.address);
  fs.writeFileSync('contract-address.txt', deployment.options.address);
});
JS

node deploy.js
