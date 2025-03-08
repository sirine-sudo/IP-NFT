// Ce script utilise Hardhat et Ethers.js pour déployer le smart contract sur Sepolia.
// Il récupère la configuration réseau depuis .env pour sécuriser les clés API et la clé privée.
// Une fois déployé, l’adresse du contrat NFT est affichée pour utilisation.
require("dotenv").config();
const hre = require("hardhat");

async function main() {
  // Récupérer l'usine du contrat (Factory)
  const IPNFT = await hre.ethers.getContractFactory("IPNFT");

  // Déploiement du contrat
  const ipNFT = await IPNFT.deploy();
  await ipNFT.deployed(); // ✅ Remplacement de `waitForDeployment()`

  // Affichage de l'adresse du contrat
  console.log("ERC-721 Contract deployed at:", ipNFT.address);
}

// Gestion des erreurs
main().catch((error) => {
  console.error(error);
  process.exit(1);
});
