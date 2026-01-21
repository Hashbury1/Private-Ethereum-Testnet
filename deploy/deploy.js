const { Web3 } = require('web3');

async function deploy() {
  const web3 = new Web3('http://localhost:8545');
  
  // Create account (no keystore issues)
  const account = web3.eth.accounts.create();
  console.log('👤 Deployer:', account.address);
  
  // Simple storage contract bytecode + ABI
  const bytecode = '0x608060405234801561001057600080fd5b50600436106100465760003560e01c80633fa8dc001461004b5780636d4ce63c14610055575b600080fd5b61005e610053366004610323565b610066565b004b90565b61007161006c366004610323565b61009b565b005b60008060009050600160009090046001908152602001908152602001600020600060009060ff1660ff1681565b92915050565b6000602082840312156100d757600080fd5b503591905056fea2646970667358221220a2b4f6e9f8c5d2e4f1a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a264736f6c634300081a0033';
  const abi = [{"inputs":[{"internalType":"uint256","name":"num","type":"uint256"}],"name":"set","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[],"name":"get","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"
