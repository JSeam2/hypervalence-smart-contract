pragma solidity ^0.4.23;

import "./ArtistToken.sol";

contract TokenAuction is ArtistToken {
  
  struct Auction {
    address seller;
    address artist;
    uint256 price;
    uint64 startedAt;
    uint8 royaltyPercentage;
  }

  // Open Auctions
  mapping (uint256 => Auction) public tokenIdToAuction;

  event AuctionCreated(uint256 tokenId, address artist, uint256 price);
  event AuctionSuccessful(uint256 tokenId, address artist, uint256 totalPrice, address winner);
  event AuctionCancelled(uint256 tokenId);

  // escrow the NFT assigns ownership to contract
  function _escrow(address _owner, uint256 _tokenId) internal {
    //approve(this, _tokenId);
    transferFrom(_owner, this, _tokenId);
  }

  // transfer NFT owned by contract to another address
  function _transfer(address _receiver, uint256 _tokenId) internal {
    //approve(_receiver, _tokenId);  
    transferFrom(this, _receiver, _tokenId);
  }

  // add auction
  function _addAuction(uint256 _tokenId, Auction _auction) internal {
    tokenIdToAuction[_tokenId] = _auction;
    emit AuctionCreated(
      uint256(_tokenId),
      address(_auction.artist),
      uint256(_auction.price)
    );
  }

  function _removeAuction(uint256 _tokenId) internal {
    delete tokenIdToAuction[_tokenId];
  }

  function _cancelAuction(uint256 _tokenId, address _seller) internal {
    _removeAuction(_tokenId);
    _transfer(_seller, _tokenId);
    emit AuctionCancelled(_tokenId);
  } 

  function _isOnAuction(Auction storage _auction) internal view returns (bool) {
    return (_auction.startedAt > 0);
  }

  function _bid(uint256 _tokenId, uint256 _bidAmount) internal {
    Auction storage auction = tokenIdToAuction[_tokenId];
    require(_isOnAuction(auction));
    uint256 price = auction.price;
    require(_bidAmount >= price);
    // save values
    address seller = auction.seller;
    address artist = auction.artist; 
    uint256 royaltyPercentage = uint256(auction.royaltyPercentage);
    _removeAuction(_tokenId);

    if (price > 0) {
      uint256 artistCut = price * royaltyPercentage/100; 
      uint256 sellerProceeds = price - artistCut;
      seller.transfer(sellerProceeds);
      artist.transfer(artistCut);
    }
    
    emit AuctionSuccessful(_tokenId, artist, _bidAmount, msg.sender);
    
  }


  function createAuction(
    uint256 _tokenId,
    uint256 _price
  ) public onlyOwnerOf(_tokenId) {


    _escrow(msg.sender, _tokenId);
    address _artist = getArtistAddress(_tokenId);
    uint8 _royaltyPercentage = getRoyaltyPercentage(_tokenId);

    Auction memory auction = Auction(
      msg.sender,
      _artist,
      _price,
      uint64(now),
      _royaltyPercentage
    );
    
    _addAuction(_tokenId, auction);
  }

  function bid(uint256 _tokenId) external payable {
    _bid(_tokenId, msg.value);
    _transfer(msg.sender, _tokenId);
  }

  function cancelAuction(uint256 _tokenId) public {
    Auction storage auction = tokenIdToAuction[_tokenId];
    require(_isOnAuction(auction));
    address seller = auction.seller;
    require(msg.sender == seller);
    _cancelAuction(_tokenId, seller);
  }

  function getOpenAuction(uint256 _tokenId)
    external
    view
    returns
  (
    address,
    address,
    uint256,
    uint64,
    uint8
  ) {
    Auction storage auction = tokenIdToAuction[_tokenId];
    require(_isOnAuction(auction));
    return (
        auction.seller,
        auction.artist,
        auction.price,
        auction.startedAt,
        auction.royaltyPercentage
    );
  }
}
