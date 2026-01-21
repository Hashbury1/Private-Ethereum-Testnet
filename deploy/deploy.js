const { Web3 } = require('web3');

async function deploy() {
  const web3 = new Web3('http://localhost:8545');
  
  // Fresh account with Ether from mining
  const account = web3.eth.accounts.create();
  console.log('👤 Deployer:', account.address);
  
  // ULTRA-SIMPLE "Hello World" storage contract - NO constructor
  const bytecode = '0x6080604052348015600f57600080fd5b506004361060285760003560e01c80633fa8dc0014602d575b600080fd5b60336035565b005b60005481565b565b600080fd5b600080fd';
  const abi = [{"inputs":[{"internalType":"uint256","name":"num","type":"uint256"}],"name":"set","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[],"name":"get","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"}];
  
  const contract = new web3.eth.Contract(abi);
  
  console.log('🚀 Deploying...');
  const gas = await contract.deploy({data: bytecode}).estimateGas({from: account.address});
  
  const deployedContract = await contract.deploy({data: bytecode}).send({from: account.address, gas});
  
  console.log('🏁 Deployed at:', deployedContract.options.address);
}

deploy().catch(console.error);