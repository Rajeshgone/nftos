// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFTOS is ERC721, ERC721URIStorage, Ownable {
    uint256 public nextTokenId;
    uint256 public mintPrice = 0.0008 ether;

    struct Listing {
        address seller;
        uint256 price;
        bool active;
    }

    mapping(uint256 => Listing) public listings;

    uint256 public royaltyFee = 500; // 5%
    address public royaltyReceiver;

    event Minted(uint256 tokenId, address owner, string uri);
    event Listed(uint256 tokenId, uint256 price);
    event Sold(uint256 tokenId, address buyer, uint256 price);

    constructor() ERC721("NFTOS", "NFTOS") Ownable(msg.sender) {
        royaltyReceiver = msg.sender;
    }

    function mint(string memory uri) public payable {
        require(msg.value >= mintPrice, "Insufficient ETH");
        uint256 tokenId = nextTokenId++;
        _safeMint(msg.sender, tokenId);
        _setTokenURI(tokenId, uri);
        emit Minted(tokenId, msg.sender, uri);
    }

    function list(uint256 tokenId, uint256 price) public {
        require(ownerOf(tokenId) == msg.sender, "Not owner");
        require(price > 0, "Price > 0");

        listings[tokenId] = Listing(msg.sender, price, true);
        emit Listed(tokenId, price);
    }

    function buy(uint256 tokenId) public payable {
        Listing memory l = listings[tokenId];
        require(l.active, "Not listed");
        require(msg.value >= l.price, "Insufficient funds");

        uint256 royalty = (l.price * royaltyFee) / 10000;
        payable(royaltyReceiver).transfer(royalty);
        payable(l.seller).transfer(l.price - royalty);

        _transfer(l.seller, msg.sender, tokenId);
        listings[tokenId].active = false;

        emit Sold(tokenId, msg.sender, l.price);
    }

    function cancelListing(uint256 tokenId) public {
        require(listings[tokenId].seller == msg.sender, "Not seller");
        listings[tokenId].active = false;
    }

    function setMintPrice(uint256 _price) external onlyOwner {
        mintPrice = _price;
    }

    // Overrides
    function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721URIStorage) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
