// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract NFTOS is ERC721, ERC721URIStorage, Ownable {
    uint256 public nextTokenId;
    uint256 public mintPrice = 0.0008 ether; // Very low for Base

    // Marketplace
    struct Listing {
        address seller;
        uint256 price;
        bool active;
    }

    mapping(uint256 => Listing) public listings;

    // Royalties (EIP-2981)
    uint256 public royaltyFee = 500; // 5% (basis points)
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

    // === Marketplace ===
    function list(uint256 tokenId, uint256 price) public {
        require(ownerOf(tokenId) == msg.sender, "Not owner");
        require(price > 0, "Price must be > 0");

        listings[tokenId] = Listing({
            seller: msg.sender,
            price: price,
            active: true
        });

        emit Listed(tokenId, price);
    }

    function buy(uint256 tokenId) public payable {
        Listing memory listing = listings[tokenId];
        require(listing.active, "Not listed");
        require(msg.value >= listing.price, "Insufficient funds");

        address seller = listing.seller;
        uint256 price = listing.price;

        // Pay royalties
        uint256 royalty = (price * royaltyFee) / 10000;
        payable(royaltyReceiver).transfer(royalty);
        payable(seller).transfer(price - royalty);

        // Transfer NFT
        _transfer(seller, msg.sender, tokenId);

        // Deactivate listing
        listings[tokenId].active = false;

        emit Sold(tokenId, msg.sender, price);
    }

    function cancelListing(uint256 tokenId) public {
        require(listings[tokenId].seller == msg.sender, "Not seller");
        listings[tokenId].active = false;
    }

    // === Admin ===
    function setMintPrice(uint256 _newPrice) external onlyOwner {
        mintPrice = _newPrice;
    }

    function setRoyalty(uint256 _fee, address _receiver) external onlyOwner {
        royaltyFee = _fee;
        royaltyReceiver = _receiver;
    }

    // Required overrides
    function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721URIStorage) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
