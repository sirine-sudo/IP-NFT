// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/common/ERC2981.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MyNFT is ERC721URIStorage, ERC2981, Ownable {
    uint256 private _tokenIds;
    mapping(uint256 => address) private _creators;

    constructor(address initialOwner, uint96 defaultRoyaltyFee)
        ERC721("MyNFT", "MNFT")
        Ownable(initialOwner)
    {
        _setDefaultRoyalty(initialOwner, defaultRoyaltyFee); // e.g. 500 = 5%
    }

    function mintNFT(address recipient, string memory uri) public onlyOwner returns (uint256) {
        _tokenIds++;
        uint256 newItemId = _tokenIds;
        _mint(recipient, newItemId);
        _setTokenURI(newItemId, uri);
        _creators[newItemId] = recipient;
        return newItemId;
    }

    function updateMetadata(uint256 tokenId, string memory newUri) public {
        require(
            _msgSender() == ownerOf(tokenId) ||
            getApproved(tokenId) == _msgSender() ||
            isApprovedForAll(ownerOf(tokenId), _msgSender()),
            "Not authorized"
        );
        _setTokenURI(tokenId, newUri);
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
