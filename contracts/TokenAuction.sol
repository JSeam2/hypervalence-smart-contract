pragma solidity ^0.4.21;

import "./ERC721Basic.sol";
import "./ArtistToken.sol";

contract TokenAuction is ArtistToken {
  
  struct Auction {
    address seller;
    address artist;
    uint256 startPrice;
    uint256 endPrice;
    uint64 startedAt;
    uint8 royaltyPercentage;
  }

	struct ArtistStats {
		address artist;
		uint256 endPrice;
		uint64 endTime;
	}

  // Open Auctions
  mapping (uint256 => Auction) public tokenIdToOpenAuction;

	ArtistStats[] public artistStats;
  

  event AuctionCreated(uint256 tokenId, address artist, uint256 startingPrice, uint256 endingPrice);
  event AuctionSuccessful(uint256 tokenId, address artist, uint256 totalPrice, address winner);
  event AuctionCancelled(uint256 tokenId);

  // escrow the NFT assigns ownership to contract
  function _escrow(address _owner, uint256 _tokenId) internal {
  ERC721BasicToken.transferFrom(_owner, this, _tokenId);
  }

  // transfer NFT owned by contract to another address
  function _transfer(address _receiver, uint256 _tokenId) internal {
    ERC721BasicToken.transferFrom(this, _receiver, _tokenId);
  }

  // add auction
  function _addAuction(uint256 _tokenId, Auction _auction) internal {
    tokenIdToOpenAuction[_tokenId] = _auction;
    emit AuctionCreated(
      uint256(_tokenId),
      address(_auction.artist),
      uint256(_auction.startPrice),
      uint256(_auction.endPrice)
    );
  }

  function _removeAuction(uint256 _tokenId) internal {
    delete tokenIdToOpenAuction[_tokenId];
  }

  function _cancelAuction(uint256 _tokenId, address _seller) internal {
    _removeAuction(_tokenId);
    _transfer(_seller, _tokenId);
    emit AuctionCancelled(_tokenId);
  } 

  function _isOnAuction(Auction storage _auction) internal view returns (bool) {
    return (_auction.startedAt > 0);
  }

  function _bid(uint256 _tokenId, uint256 _bidAmount)
    internal returns (uint256) {

    Auction storage auction = tokenIdToOpenAuction[_tokenId];
    require(_isOnAuction(auction));
    uint256 price = auction.startPrice;
    require(_bidAmount >= price);
    // save values
    address seller = auction.seller;
    address artist = auction.artist; 
    uint256 endPrice = _bidAmount;
    uint256 royaltyPercentage = uint256(auction.royaltyPercentage);
    _removeAuction(_tokenId);

    if (price > 0) {
      uint256 artistCut = price * royaltyPercentage/100; 
      uint256 sellerProceeds = price - artistCut;
      seller.transfer(sellerProceeds);
      artist.transfer(artistCut);

	  artistStats.push(ArtistStats(artist, endPrice, uint64(now)));
    }
    
    emit AuctionSuccessful(_tokenId, artist, endPrice, msg.sender);

    return endPrice;
    
  }


  function createAuction(
    uint256 _tokenId,
    uint256 _startingPrice,
    uint256 _endingPrice
  ) public onlyOwnerOf(_tokenId) {

		require(_startingPrice == uint256(uint128(_startingPrice)));
		require(_endingPrice == uint256(uint128(_endingPrice)));

		_escrow(msg.sender, _tokenId);
		address _artist = ArtistToken.tokenToArtistAddress[_tokenId];
		uint8 _royaltyPercentage = ArtistToken.tokenToRoyaltyPercentage[_tokenId];

		Auction memory auction = Auction(
			msg.sender,
			_artist,
			_startingPrice,
			_endingPrice,
			uint64(now),
			uint8(_royaltyPercentage)
		);
    
		_addAuction(_tokenId, auction);
  }

  function bid(uint256 _tokenId) external payable {
    _bid(_tokenId, msg.value);
    _transfer(msg.sender, _tokenId);
  }

  function cancelAuction(uint256 _tokenId) public {
    Auction storage auction = tokenIdToOpenAuction[_tokenId];
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
    address seller,
    address artist,
    uint256 startingPrice,
    uint256 endingPrice,
    uint256 startedAt,
    uint256 royaltyPercentage
  ) {
    Auction storage auction = tokenIdToOpenAuction[_tokenId];
    require(_isOnAuction(auction));
    return (
      auction.seller,
	  auction.artist,
      auction.startPrice,
      auction.endPrice,
      auction.startedAt,
	  auction.royaltyPercentage
    );
      
  }
    
  function getArtistStats(uint256 index)
    external
    view
    returns
  (
    address artist,
    uint256 endingPrice,
    uint64 endTime
  ) {
    ArtistStats storage stats = artistStats[index];
    return (
	  stats.artist,
      stats.endPrice,
      stats.endTime
    );
    }
}
