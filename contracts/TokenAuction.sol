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

  event AuctionCreated(uint256 tokenId, address artist, uint256 startPrice, uint64 auctionStart, uint64 auctionClose);
  event AuctionBidIncreased(uint256 tokenId, address artist, address bidder, uint256 startPrice, uint256 endPrice);
  event AuctionSuccessful(uint256 tokenId, address artist, uint256 endPrice, address winner);
  event AuctionCancelled(uint256 tokenId);

  // escrow the NFT assigns ownership to contract
  function _escrow(address _owner, uint256 _tokenId) internal {
    // clear approvals
    clearApproval(_owner, _tokenId);
    
    // remove token from   
    super.removeTokenFrom(_owner, _tokenId);
    
    // transfer ownership
    super.addTokenTo(this, _tokenId);
    tokenOwner[_tokenId] = this;
    ownedTokensCount[this] = ownedTokensCount[this].add(1);
    
    emit Transfer(_owner, this, _tokenId);
  }

  // transfer NFT owned by contract to another address
  function _transfer(address _receiver, uint256 _tokenId) internal {
    // clear approvals
    clearApproval(this, _tokenId);
    
    // remove token from   
    super.removeTokenFrom(this, _tokenId);
    
    // transfer ownership
    addTokenTo(_receiver, _tokenId);
    tokenOwner[_tokenId] = _receiver;
    ownedTokensCount[_receiver] = ownedTokensCount[_receiver].add(1);
    
    emit Transfer(this, _receiver, _tokenId);
  }

  // check if the auction is on
  function _isOnAuction(Auction storage _auction) internal view returns (bool) {
    return (_auction.auctionStart > 0);
  }

  // creates an Auction
  function createAuction(uint256 _tokenId, 
                         uint256 _startPrice,
                         uint64 _duration) public onlyOwnerOf(_tokenId) {
    // require non-zero start price
    require(_startPrice >= 100);
    // transfer token to this contract
    _escrow(msg.sender, _tokenId);
    
    // get values from inherited contract ArtistToken
    address _artist = getArtistAddress(_tokenId);
    uint8 _royaltyPercentage = getRoyaltyPercentage(_tokenId);
    
    uint64 _auctionStart = uint64(now);
    uint64 _auctionEnd = _auctionStart + _duration;

    Auction memory _auction = Auction(
      msg.sender,
      _artist,
      msg.sender,
      _startPrice,
      _startPrice,
      _auctionStart,
      _auctionEnd,
      _royaltyPercentage
    );

    // create mapping
    tokenIdToAuction[_tokenId] = _auction;

    // broadcast event
    emit AuctionCreated(
      uint256(_tokenId),
      address(_auction.artist),
      uint256(_auction.startPrice),
      uint64(_auction.auctionStart),
      uint64(_auction.auctionClose)
    );
  }

  function cancelAuction(uint256 _tokenId) public {
    Auction storage auction = tokenIdToAuction[_tokenId];
    require(msg.sender == auction.seller);
    require(_isOnAuction(auction));
    require(auction.auctionClose >= now);
    _transfer(auction.seller, _tokenId);
    delete tokenIdToAuction[_tokenId];
    emit AuctionCancelled(_tokenId);
  }

  function bid(uint256 _tokenId) public payable {
    Auction storage auction = tokenIdToAuction[_tokenId];
    require(_isOnAuction(auction));
    require(now <= auction.auctionClose);
    require(msg.value > auction.endPrice); 

    // update mapping
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

    tokenIdToAuction[_tokenId] = _auction;

    emit AuctionBidIncreased(_tokenId, auction.artist, msg.sender, auction.startPrice, msg.value);
  }

  function auctionClose(uint256 _tokenId) public {
    Auction storage auction = tokenIdToAuction[_tokenId];
    require(now > auction.auctionClose);
    require(_isOnAuction(auction));
    
    // add to completedAuctions
    completedAuctions.push(auction);
    
    // transfer token
    _transfer(auction.topBidder, _tokenId);

    // delete auction
    delete tokenIdToAuction[_tokenId];

    uint256 artistCut =  auction.endPrice * auction.royaltyPercentage/100;
    uint256 sellerProceeds = auction.endPrice - artistCut;

    // transfer as accordingly
    auction.seller.transfer(sellerProceeds);
    auction.artist.transfer(artistCut);

    // announce event
    emit AuctionSuccessful(_tokenId, auction.artist, auction.endPrice, auction.topBidder);
  }

  function getOpenAuction(uint256 _tokenId)
    public
    view
    returns
  (
    address,
    address,
    address,
    uint256,
    uint256,
    uint64,
    uint64,
    uint8
  ) {
    Auction storage auction = tokenIdToAuction[_tokenId];
    require(_isOnAuction(auction));
    return (
        auction.seller,
        auction.artist,
        auction.topBidder,
        auction.startPrice,
        auction.endPrice,
        auction.auctionStart,
        auction.auctionClose,
        auction.royaltyPercentage
    );
  }
  
    function getCompletedAuction(uint256 index)
    public
    view
    returns
  (
    address,
    address,
    address,
    uint256,
    uint256,
    uint64,
    uint64,
    uint8
  ) {
    Auction storage auction = completedAuctions[index];
    return (
        auction.seller,
        auction.artist,
        auction.topBidder,
        auction.startPrice,
        auction.endPrice,
        auction.auctionStart,
        auction.auctionClose,
        auction.royaltyPercentage
    );
  }
}
