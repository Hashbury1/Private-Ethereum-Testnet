const { ethers } = require("hardhat");

async function main() {
  const [signer] = await ethers.getSigners();
  const contract = await ethers.getContractAt("YourContract", "0x4AACe6677f6522A192E42007d63CCd563577558C");
  
  console.log("Current count:", await contract.count());
  const tx = await contract.increment();
  await tx.wait();
  console.log("New count:", await contract.count());
}

main().catch(console.error);
