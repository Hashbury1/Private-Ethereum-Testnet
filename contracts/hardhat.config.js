require("@nomicfoundation/hardhat-toolbox");

module.exports = {
  solidity: "0.8.19",
  networks: {
    poa: {
      url: "http://localhost:8545",
      chainId: 1451,
      accounts: {
        mnemonic: "test test test test test test test test test test test junk"
      }
    }
  }
};