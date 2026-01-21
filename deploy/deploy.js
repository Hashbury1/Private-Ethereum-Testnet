const { Web3 } = require('web3');
const fs = require('fs');
const solc = require('solc');

async function deploy() {
  const web3 = new Web3('http://localhost:8545');
  
  const accounts = await web3.eth.getAccounts();
  const deployer = accounts[0];
  
  console.log('👤 Deployer:', deployer);
  
  // Read contract
  const source = fs.readFileSync('./contracts/Counter.sol', 'utf8');
  
  console.log('🔨 Compiling contract...');
  
  const input = {
    language: 'Solidity',
    sources: {
      'Counter.sol': { content: source }
    },
    settings: {
      outputSelection: {
        '*': { '*': ['abi', 'evm.bytecode'] }
      }
    }
  };
  
  const output = JSON.parse(solc.compile(JSON.stringify(input)));
  
  if (output.errors) {
    output.errors.forEach(err => {
      if (err.severity === 'error') {
        console.error(err.formattedMessage);
      }
    });
    if (output.errors.some(e => e.severity === 'error')) {
      process.exit(1);
    }
  }
  
  const contract = output.contracts['Counter.sol']['Counter'];
  const abi = contract.abi;
  const bytecode = '0x' + contract.evm.bytecode.object;
  
  console.log('✅ Compiled successfully');
  
  const Counter = new web3.eth.Contract(abi);
  
  console.log('🚀 Deploying...');
  
  const gasPrice = await web3.eth.getGasPrice();
  
  const deployed = await Counter.deploy({
    data: bytecode
  }).send({
    from: deployer,
    gas: 1000000,
    gasPrice: gasPrice
  });
  
  console.log('✅ Deployed to:', deployed.options.address);
  
  // Save deployment
  fs.writeFileSync('deployment.json', JSON.stringify({
    address: deployed.options.address,
    abi: abi,
    deployer: deployer,
    timestamp: new Date().toISOString()
  }, null, 2));
  
  console.log('💾 Saved to deployment.json');
  
  // Test
  console.log('\n🧪 Testing...');
  
  const counter = new web3.eth.Contract(abi, deployed.options.address);
  
  let count = await counter.methods.getCount().call();
  console.log('Initial count:', count);
  
  const tx = await counter.methods.increment().send({
    from: deployer,
    gas: 100000,
    gasPrice: gasPrice
  });
  
  console.log('✅ Increment tx:', tx.transactionHash);
  
  count = await counter.methods.getCount().call();
  console.log('New count:', count);
  
  console.log('\n🎉 Success!');
}

deploy().catch(console.error);
