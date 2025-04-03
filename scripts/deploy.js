// scripts/deploy.js
const hre = require("hardhat");

async function main() {
  const [deployer] = await hre.ethers.getSigners();

  console.log("Deploying contract with the account:", deployer.address);

  const MyNFT = await hre.ethers.getContractFactory("MyNFT");
  const contract = await MyNFT.deploy(deployer.address, 500); // 5% royalty

  await contract.waitForDeployment();

  console.log("MyNFT deployed to:", await contract.getAddress());
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
