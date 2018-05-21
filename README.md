# Smackathon Smart Contract Idea
This repository possess the smart contract implementation of the project

# Idea
We create a curation market for artists and fans. Artists can create unique collectible tokens that they can sell on the market to raise funds. To incentivise sales of tokens, Artists can indicate in the descriptions what these tokens would entitle fans to. For example, backstage access, skype sessions. Fans who collect the tokens essentially possess a proof of support, allowing fans to claim OG fan status, verified on the blockchain. The tokens are tradeable, and the artist can define a royalty percentage fee that can be taxed on trades.  


# Features
## Minting Tokens
1. Artists can mint collectible tokens to raise funds
2. Artists can sell the token on a crowdsale
3. Artists can define in a description field what the tokens entitle fans to.
4. Artists can define a startTime and endTime for the duration the tokens are valid.
If the token are to last forever, indicate true in the lastForever field. If lastForever is true, value in startTime and endTime do not matter.
5. Artists can define a royalty percentage fee between 0 and 100 that will be credited to the Artist upon future transactions. (This fee has default value at 5 or 5%)

## Tokens 
1. Tokens are ERC-721 compliant and are tradeable
2. The tokens possess the following information
    ```
    uint tokenNumber
    uint dateCreated
    string description
    uint startBlock
    uint endBlock	// we use block to denote time to prevent miners from manipulating these fields
    boolean lastForever
    uint royaltyPercentage
	```	

## Auction
1. All tokens are to be sold as an auction. 
TODO: Elaborate
