const hre = require("hardhat");

async function main() {
  const [deployer] = await hre.ethers.getSigners(); // 🔥 Récupérer l'adresse du déployeur
  console.log("Deploying contract with the account:", deployer.address);

  const MyNFT = await hre.ethers.getContractFactory("MyNFT");
  const nft = await MyNFT.deploy(deployer.address); // ✅ Passer l'adresse du déployeur

  await nft.waitForDeployment(); // ✅ Remplace `.deployed()` par `.waitForDeployment()`

  console.log("MyNFT deployed to:", await nft.getAddress()); // ✅ Récupérer l'adresse déployée
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
