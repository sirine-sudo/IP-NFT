// SPDX-License-Identifier: MIT
// Licence Open Source : Permet à tout le monde d'utiliser ce code librement.

// ------------------------------------------------------
// Objectif  :
//définir un smart contract appelé "MyNFT".
// Ce smart contract permet de créer des NFTs, gérer des royalties, 
// mettre à jour les métadonnées des NFTs, et contrôler l'accès à la mise à jour via une whitelist.
// 
// Ce contrat est basé sur les standards ERC721 (NFT), ERC721URIStorage (gestion d'URI par token),
// ERC2981 (gestion des royalties) et utilise le contrôle d'accès Ownable (seul l'owner peut faire certaines actions).
// ------------------------------------------------------

pragma solidity ^0.8.19;

// Importation de bibliothèques standards d'OpenZeppelin
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol"; // Extension d'ERC721 pour stocker les URI des NFTs
import "@openzeppelin/contracts/token/common/ERC2981.sol"; // Standard pour gérer les royalties
import "@openzeppelin/contracts/access/Ownable.sol"; // Permet d'avoir un propriétaire du contrat

// ------------------------------------------------------
// Définition du contrat
// ------------------------------------------------------
contract MyNFT is ERC721URIStorage, ERC2981, Ownable {
    
    uint256 private _tokenIds; // Compteur interne pour suivre l'ID des NFTs créés
    mapping(uint256 => address) private _creators; // Associe chaque NFT à son créateur
    mapping(address => bool) private whitelisted; // Liste blanche pour autoriser certaines adresses à modifier les métadonnées

    // Événement émis lorsqu'un NFT est mis à jour
    event MetadataUpdated(uint256 tokenId, string newUri, uint256 timestamp);

    // ------------------------------------------------------
    // Constructeur : Initialisation du contrat au moment du déploiement
    // ------------------------------------------------------
    constructor(address initialOwner, uint96 defaultRoyaltyFee)
        ERC721("MyNFT", "MNFT") // Nom du token : "MyNFT", Symbole : "MNFT"
        Ownable(initialOwner)   // Définit l'owner initial du contrat
    {
        _setDefaultRoyalty(initialOwner, defaultRoyaltyFee); 
        // Définit l'adresse qui recevra les royalties par défaut et le pourcentage de royalties
    }

    // ------------------------------------------------------
    // Fonction interne pour créer un nouveau NFT (mint)
    // Cette fonction n'est pas directement accessible par les utilisateurs
    // ------------------------------------------------------
    function _mintNFT(address recipient, string memory uri) private returns (uint256) {
        _tokenIds++; // Incrémente l'ID
        uint256 newItemId = _tokenIds; // Sauvegarde l'ID pour le nouveau NFT
        _mint(recipient, newItemId); // Crée le NFT et l'attribue au destinataire
        _setTokenURI(newItemId, uri); // Associe une URI (métadonnée) au NFT
        _creators[newItemId] = recipient; // Enregistre le créateur du NFT
        return newItemId; // Retourne l'ID du nouveau NFT
    }

    // ------------------------------------------------------
    // Fonction publique pour "mint" un NFT en toute sécurité
    // Seul l'owner du contrat peut appeler cette fonction
    // ------------------------------------------------------
    function safeMint(address recipient, string memory uri) external onlyOwner returns (uint256) {
        return _mintNFT(recipient, uri); // Appelle la fonction privée interne _mintNFT
    }

    // ------------------------------------------------------
    // Fonction pour mettre à jour les métadonnées d'un NFT existant
    // Seules les adresses ajoutées à la whitelist peuvent appeler cette fonction
    // ------------------------------------------------------
    function updateMetadata(uint256 tokenId, string memory newUri) public {
        require(whitelisted[_msgSender()], "Erreur : Vous n'etes pas autorise"); 
        // Vérifie si l'adresse de l'utilisateur est autorisée
        _setTokenURI(tokenId, newUri); // Met à jour l'URI du NFT
        emit MetadataUpdated(tokenId, newUri, block.timestamp); // Émet un événement de mise à jour
    }

    // ------------------------------------------------------
    // Fonction pour ajouter une adresse à la whitelist
    // Seul l'owner du contrat peut ajouter des adresses
    // ------------------------------------------------------
    function addToWhitelist(address user) external onlyOwner {
        whitelisted[user] = true;
    }

    // ------------------------------------------------------
    // Fonction pour retirer une adresse de la whitelist
    // Seul l'owner du contrat peut retirer des adresses
    // ------------------------------------------------------
    function removeFromWhitelist(address user) external onlyOwner {
        whitelisted[user] = false;
    }

    // ------------------------------------------------------
    // Fonction pour vérifier si une adresse est dans la whitelist
    // ------------------------------------------------------
    function isWhitelisted(address user) public view returns (bool) {
        return whitelisted[user];
    }

    // ------------------------------------------------------
    // Fonction pour obtenir l'adresse du créateur d'un NFT donné
    // ------------------------------------------------------
    function getCreator(uint256 tokenId) public view returns (address) {
        return _creators[tokenId];
    }

    // ------------------------------------------------------
    // Fonction nécessaire pour que le contrat supporte à la fois ERC721URIStorage et ERC2981
    // (obligatoire pour la compatibilité avec les plateformes qui lisent les standards NFT et royalties)
    // ------------------------------------------------------
    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721URIStorage, ERC2981)
        returns (bool)
    {
        return super.supportsInterface(interfaceId); // Appelle la fonction supporteInterface héritée
    }
}
