#!/bin/bash
set -e

echo "📜 Deploying Smart Contract..."

# Configuration
RPC_URL="http://localhost:8545"
DEPLOYER_ADDRESS=$(cat nodes/node1/keystore/* | grep -o '"address":"[^"]*' | head -1 | cut -d'"' -f4)
DEPLOYER_ADDRESS="0x${DEPLOYER_ADDRESS}"

echo "👤 Deployer Address: $DEPLOYER_ADDRESS"

# Install dependencies if needed
if ! command -v solc &> /dev/null; then
    echo "📦 Installing Solidity compiler..."
    npm install -g solc
fi

if ! command -v node &> /dev/null; then
    echo "❌ Node.js is required. Please install it first."
    exit 1
fi

# Create deployment script
cat > /tmp/deploy.js << 'EOF'
const Web3 = require('web3');
const fs = require('fs');
const solc = require('solc');

const web3 = new Web3('http://localhost:8545');

// Read and compile contract
const source = fs.readFileSync('./contracts/SimpleStorage.sol', 'utf8');

const input = {
    language: 'Solidity',
    sources: {
        'SimpleStorage.sol': {
            content: source
        }
    },
    settings: {
        outputSelection: {
            '*': {
                '*': ['*']
            }
        }
    }
};

console.log('🔨 Compiling contract...');
const output = JSON.parse(solc.compile(JSON.stringify(input)));

if (output.errors) {
    output.errors.forEach(error => {
        console.error(error.formattedMessage);
    });
    if (output.errors.some(e => e.severity === 'error')) {
        process.exit(1);
    }
}

const contract = output.contracts['SimpleStorage.sol']['SimpleStorage'];
const abi = contract.abi;
const bytecode = contract.evm.bytecode.object;

console.log('✅ Contract compiled successfully');

async function deploy() {
    const accounts = await web3.eth.getAccounts();
    const deployer = accounts[0];
    
    console.log(`👤 Deploying from: ${deployer}`);
    
    const SimpleStorage = new web3.eth.Contract(abi);
    
    console.log('🚀 Deploying contract...');
    
    const deployment = SimpleStorage.deploy({
        data: '0x' + bytecode
    });
    
    const gas = await deployment.estimateGas();
    console.log(`⛽ Estimated gas: ${gas}`);
    
    const deployedContract = await deployment.send({
        from: deployer,
        gas: gas + 100000
    });
    
    console.log('✅ Contract deployed successfully!');
    console.log(`📍 Contract Address: ${deployedContract.options.address}`);
    
    // Save deployment info
    const deploymentInfo = {
        address: deployedContract.options.address,
        abi: abi,
        deployer: deployer,
        timestamp: new Date().toISOString(),
        network: 'PoA Testnet',
        chainId: await web3.eth.getChainId()
    };
    
    fs.writeFileSync(
        './deployment.json',
        JSON.stringify(deploymentInfo, null, 2)
    );
    
    console.log('💾 Deployment info saved to deployment.json');
    
    // Test the contract
    console.log('\n🧪 Testing contract...');
    
    await deployedContract.methods.setValue(42).send({
        from: deployer,
        gas: 100000
    });
    console.log('✅ Set value to 42');
    
    const value = await deployedContract.methods.getValue().call();
    console.log(`✅ Retrieved value: ${value}`);
    
    if (value === '42') {
        console.log('✅ Contract test passed!');
    } else {
        console.log('❌ Contract test failed!');
    }
}

deploy().catch(console.error);
EOF

# Install Node.js dependencies
if [ ! -d "node_modules" ]; then
    echo "📦 Installing dependencies..."
    npm init -y
    npm install web3 solc
fi

# Run deployment
node /tmp/deploy.js

# Cleanup
rm /tmp/deploy.js

echo "✅ Deployment complete!"