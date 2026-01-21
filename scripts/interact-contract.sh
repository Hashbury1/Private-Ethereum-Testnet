#!/bin/bash
set -e

if [ ! -f "deployment.json" ]; then
    echo "❌ No deployment found. Run deploy-contract.sh first"
    exit 1
fi

CONTRACT_ADDRESS=$(cat deployment.json | grep -o '"address":"[^"]*' | cut -d'"' -f4)

echo "🔗 Interacting with contract at: $CONTRACT_ADDRESS"

cat > /tmp/interact.js << 'EOF'
const Web3 = require('web3');
const fs = require('fs');

const web3 = new Web3('http://localhost:8545');
const deployment = JSON.parse(fs.readFileSync('./deployment.json', 'utf8'));

const contract = new web3.eth.Contract(
    deployment.abi,
    deployment.address
);

async function interact() {
    const accounts = await web3.eth.getAccounts();
    
    // Get current value
    console.log('📖 Getting current value...');
    let value = await contract.methods.getValue().call();
    console.log(`Current value: ${value}`);
    
    // Set new value
    const newValue = Math.floor(Math.random() * 1000);
    console.log(`\n📝 Setting new value: ${newValue}`);
    
    const receipt = await contract.methods.setValue(newValue).send({
        from: accounts[0],
        gas: 100000
    });
    
    console.log(`✅ Transaction: ${receipt.transactionHash}`);
    console.log(`⛽ Gas used: ${receipt.gasUsed}`);
    
    // Verify new value
    value = await contract.methods.getValue().call();
    console.log(`\n✅ New value confirmed: ${value}`);
    
    // Listen for events
    console.log('\n👂 Listening for ValueChanged events...');
    contract.events.ValueChanged()
        .on('data', event => {
            console.log(`📢 Event: Value changed to ${event.returnValues.newValue}`);
            console.log(`   Changed by: ${event.returnValues.changedBy}`);
        });
}

interact().catch(console.error);
EOF

node /tmp/interact.js
rm /tmp/interact.js