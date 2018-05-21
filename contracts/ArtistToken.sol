pragma solidity ^0.4.23;

import "./node_modules/openzeppelin-solidity/contracts/token/ERC721/ERC721.sol"

contract ArtistToken is ERC721 {
  struct TokenData {
    uint256 tokenNumber
    uint256 timeCreated
    uint256 startBlock
    uint256 endBlock
    bool lastForever
    uint32 royaltyPercentage
    string description
  }


}
