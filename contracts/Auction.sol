pragma solidity ^0.4.23;

contract ArtistAuctionContract {
  struct Auction {
    uint startTime;
    uint endTime;
    uint highestBid;
    address owner;
    address winner; 
  }

  mapping (uint => Auction[]) public auctions;

  function startAuction {
    // Create an auction 
  }

  function bid {

  }

