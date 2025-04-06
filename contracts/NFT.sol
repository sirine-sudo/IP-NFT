// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/common/ERC2981.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MyNFT is ERC721URIStorage, ERC2981, Ownable {
    uint256 private _tokenIds;
    mapping(uint256 => address) private _creators;
    mapping(address => bool) private whitelisted;

    event MetadataUpdated(uint256 tokenId, string newUri, uint256 timestamp);

    constructor(address initialOwner, uint96 defaultRoyaltyFee)
        ERC721("MyNFT", "MNFT")
        Ownable(initialOwner)
    {
        _setDefaultRoyalty(initialOwner, defaultRoyaltyFee);
    }

    // 🛡️ Fonction privée : VRAI mint
    function _mintNFT(address recipient, string memory uri) private returns (uint256) {
        _tokenIds++;
        uint256 newItemId = _tokenIds;
        _mint(recipient, newItemId);
        _setTokenURI(newItemId, uri);
        _creators[newItemId] = recipient;
        return newItemId;
    }

    // 🔥 Fonction publique sécurisée : appelable par l'owner uniquement
function safeMint(address recipient, string memory uri) external onlyOwner returns (uint256) {
    return _mintNFT(recipient, uri);
}

    function updateMetadata(uint256 tokenId, string memory newUri) public {
        require(whitelisted[_msgSender()], "Erreur : Vous n'etes pas autorise");
        _setTokenURI(tokenId, newUri);
        emit MetadataUpdated(tokenId, newUri, block.timestamp);
    }

    function addToWhitelist(address user) external onlyOwner {
        whitelisted[user] = true;
    }

    function removeFromWhitelist(address user) external onlyOwner {
        whitelisted[user] = false;
    }

    function isWhitelisted(address user) public view returns (bool) {
        return whitelisted[user];
    }

    function getCreator(uint256 tokenId) public view returns (address) {
        return _creators[tokenId];
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721URIStorage, ERC2981)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
