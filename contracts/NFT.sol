// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

// Importation de contrats standards depuis OpenZeppelin pour les fonctionnalités NFT (ERC721),
// stockage de métadonnées (URI), royalties (ERC2981), et contrôle de propriété (Ownable)
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/common/ERC2981.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// Déclaration du contrat principal
contract MyNFT is ERC721URIStorage, ERC2981, Ownable {
    // Compteur pour attribuer un nouvel identifiant unique à chaque NFT
    uint256 private _tokenIds;

    // Association entre chaque tokenId et son créateur d'origine
    mapping(uint256 => address) private _creators;

    // 🔄 Événement qui sera émis à chaque mise à jour de métadonnées
    event MetadataUpdated(uint256 tokenId, string newUri, uint256 timestamp);

    // Constructeur du contrat : initialise le nom de la collection et définit les royalties par défaut
    constructor(address initialOwner, uint96 defaultRoyaltyFee)
        ERC721("MyNFT", "MNFT") // Nom et symbole de la collection NFT
        Ownable(initialOwner)   // Définit le propriétaire initial du contrat
    {
        _setDefaultRoyalty(initialOwner, defaultRoyaltyFee); // Définition des royalties (ex: 500 = 5%)
    }

    // Fonction pour créer (minter) un nouveau NFT
    function mintNFT(address recipient, string memory uri) public onlyOwner returns (uint256) {
        _tokenIds++; // Incrémente l'ID du NFT
        uint256 newItemId = _tokenIds;
        _mint(recipient, newItemId);           // Crée le NFT
        _setTokenURI(newItemId, uri);          // Définit les métadonnées (lien IPFS, JSON, etc.)
        _creators[newItemId] = recipient;      // Enregistre le créateur du NFT
        return newItemId;                      // Retourne l'ID du NFT
    }

    // Fonction pour mettre à jour les métadonnées d'un NFT (ex : nouvelle image, nouveau contenu)
    function updateMetadata(uint256 tokenId, string memory newUri) public {
        // Autorisation : uniquement le propriétaire ou une personne approuvée peut modifier
        require(
            _msgSender() == ownerOf(tokenId) ||
            getApproved(tokenId) == _msgSender() ||
            isApprovedForAll(ownerOf(tokenId), _msgSender()),
            "Not authorized"
        );

        _setTokenURI(tokenId, newUri); // Mise à jour de l'URI (lien vers les nouvelles métadonnées)

        // 🔔 Émission de l'événement pour tracer cette modification
        emit MetadataUpdated(tokenId, newUri, block.timestamp);
    }

    // Fonction pour consulter l'adresse du créateur original d’un NFT
    function getCreator(uint256 tokenId) public view returns (address) {
        return _creators[tokenId];
    }

    // Nécessaire pour déclarer la compatibilité avec les interfaces ERC721, ERC2981, etc.
    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721URIStorage, ERC2981)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
