// Ce contrat ERC-721 permet de créer des NFT représentant des actifs de propriété intellectuelle (brevets, designs, licences).
// Il stocke les métadonnées associées (nom, auteur, date, licence) sur IPFS ou un autre système de stockage.
// Seul l’administrateur peut minter (créer) un NFT.
// Les NFT peuvent être transférés et vérifiés par les utilisateurs.

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Importation des bibliothèques OpenZeppelin
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract IPNFT is ERC721URIStorage, Ownable {
    uint256 private _nextTokenId;

    event NFTMinted(uint256 indexed tokenId, address indexed owner, string metadataURI);

    constructor() ERC721("IPManagementNFT", "IPNFT") {}

    function mintNFT(address to, string memory metadataURI) external onlyOwner returns (uint256) {
        uint256 tokenId = _nextTokenId++;
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, metadataURI);

        emit NFTMinted(tokenId, to, metadataURI);
        return tokenId;
    }

    function transferNFT(address from, address to, uint256 tokenId) external {
        require(ownerOf(tokenId) == from, "Not the owner");
        _transfer(from, to, tokenId);
    }

    function getMetadata(uint256 tokenId) external view returns (string memory) {
        require(_exists(tokenId), "Token does not exist");
        return tokenURI(tokenId);
    }
}
