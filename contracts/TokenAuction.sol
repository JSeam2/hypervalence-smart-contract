pragma solidity ^0.4.21;

import "./ERC721Basic.sol";
import "./ArtistToken.sol";


contract TokenAuction is ArtistToken {
	ERC721Basic public nonFungibleContract;

	constructor(address _nftAddress) public {
		nonFungibleContract = ERC721Basic(_nftAddress);
	}


  struct Auction {
  	address seller;
  	uint256 price;

    // uint startTime;
    // uint endTime;
    // uint highestBid;
  }

  // Every auction to be associated with a tokenId
  mapping (uint256 => Auction) public tokenIdToAuction;

  /**
  * TODO
  */
  function createAuction(uint256 _tokenId, uint256 price) public {
  	nonFungibleContract.takeOwnership(_tokenId);
  	Auction memory _auction = Auction({
  		seller: msg.sender,
  		price: uint256(price)
  		});

  	tokenIdToAuction[_tokenId] = _auction;
  }

  /**
  * TODO
  */
  function bid(uint256 _tokenId) public payable {
  	Auction memory auction = tokenIdToAuction[_tokenId];
  	require(auction.seller != address(0));
  	require(msg.value >= auction.price);

  	address seller = auction.seller;
  	uint256 price = auction.price;

  	delete tokenIdToAuction[_tokenId];

  	seller.transfer(price);
  	nonFungibleContract.transfer(msg.sender, _tokenId);
  }

  /**
  * TODO
  */
  function cancel(uint256 _tokenId) public {
  	Auction memory auction = tokenIdToAuction[_tokenId];
  	require(auction.seller == msg.sender);

  	delete tokenIdToAuction[_tokenId];

  	nonFungibleContract.transfer(msg.sender, _tokenId);
  }
}
