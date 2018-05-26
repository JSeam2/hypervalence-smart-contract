pragma solidity ^0.4.23;

import "./ArtistToken.sol";

contract TokenAuction is ArtistToken {
  
  struct Auction {
    address seller;
    address artist;
    address topBidder;
    uint256 startPrice;
    uint256 endPrice;
    uint64 auctionStart;
    uint64 auctionClose;
    uint8 royaltyPercentage;
  }

  // Open Auctions
  mapping (uint256 => Auction) public tokenIdToAuction;

  // Completed auctions
  Auction[] public completedAuctions;

  event AuctionCreated(uint256 tokenId, address artist, uint256 startPrice, uint64 duration);
  event AuctionBidIncreased(uint256 tokenId, address artist, address bidder, uint256 startPrice, uint256 endPrice);
  event AuctionSuccessful(uint256 tokenId, address artist, uint256 endPrice, address winner);
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

  // check if the auction is on
  function _isOnAuction(Auction storage _auction) internal view returns (bool) {
    return (_auction.startedAt > 0);
  }

  // creates an Auction
  function createAuction(uint256 _tokenId, 
                         uint256 _startPrice,
                         uint64 _duration) public onlyOwnerOf(_tokenId) {
    // require non-zero start price
    require(_startPrice > 0);
    // transfer token to this contract
    _escrow(msg.sender, _tokenId);
    
    // get values from inherited contract ArtistToken
    address _artist = getArtistAddress(_tokenId);
    uint8 _royaltyPercentage = getRoyaltyPercentage(_tokenId);

    Auction memory _auction = Auction(
      msg.sender,
      _artist,
      msg.sender,
      _startPrice,
      _startPrice,
      uint64(now),
      uint64(now) + _duration,
      _royaltyPercentage
    );

    // create mapping
    tokenIdToAuction[_tokenId] = _auction;

    // broadcast event
    emit AuctionCreated(
      uint256(_tokenId),
      address(_auction.artist),
      uint256(_auction.startPrice),
      uint256 (_auction.duration)
    );
  }

  function cancelAuction(uint256 _tokenId) public {
    Auction storage auction = tokenIdToAuction[_tokenId];
    require(msg.sender == auction.seller);
    require(_isOnAuction(auction));
    _transfer(_seller, _tokenId);
    delete tokenIdToAuction[_tokenId];
    emit AuctionCancelled(_tokenId);
  }

  function bid(uint256 _tokenId) public payable {
    Auction storage auction = tokenIdToAuction[_tokenId];
    require(_isOnAuction(auction));
    require(now <= auction.auctionClose);
    require(msg.value > auction.endPrice); 

    Auction memory _auction = Auction(
      auction.seller,
      auction.artist,
      msg.sender,
      auction.startPrice,
      msg.value,
      auction.auctionStart,
      auction.auctionClose,
      auction.royaltyPercentage
    );

    // create mapping
    tokenIdToAuction[_tokenId] = _auction;

    emit AuctionBidIncreased(_tokenId, auction.artist, msg.sender, auction.startPrice, msg.value);
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
