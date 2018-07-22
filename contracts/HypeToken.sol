pragma solidity ^0.4.21;

import "./ERC721.sol";
import "./ERC721BasicToken.sol";


contract HypeToken is ERC721, ERC721BasicToken {
  using SafeMath for uint256;
  using AddressUtils for address;


  /// @notice struct that holds token data
  /// @param name the name of the token
  /// @param description information about the token, you may indicate benefits 
  ///   the token confers and the time it is valid until.
  /// @param artistAddress the address of the artist who created the token
  /// @param artistTokenNumber the number of tokens created by the artist. 
  ///   eg 1st token, 2nd, ..., nth token
  /// @param timeCreated the block timestamp time where the token was created
  /// @param royaltyPercentage the royalty percentage the artist receives from 
  ///   exchange of the token. Fixed at 5%.
                            
  /**
   * @dev Struct to hold token data
   * @param name This is the name of the ERC721 token as defined by the artist
   * @param description This contains the description about the token. Artist may indicate benefits
   *    conferred by the token. (e.g. Holder of the token is entitled to backstage access for life) 
   * @param artistAddress Ethereum address of Artist, the account that minted the token is the artist
   * @param artistTokenNumber Number of ERC721 tokens minted by an address
   * @param artistRoyaltyPercentage Artist address gets a 5% commission from sale of token

   * @param firstOwnerAddress Ethereum address of first person who owned the token
   * @param firstOwnerRoyaltyPercentage First owner address gets a 2.5% commision from sale of token

   * @param timeCreated Epoch time 
   */  
  struct TokenData {
    string name;
    string description;
    address artistAddress;
    uint256 artistTokenNumber;
    uint256 timeCreated;
    uint8 royaltyPercentage;
    bool redeemed;
  }

  TokenData[] internal tokens;

  // Mapping from owner to list of owned token ID
  mapping (address => uint256[]) internal ownedTokens;

  // Mapping from token minter to list of minted token ID
  mapping (address => uint256[]) internal mintedTokens;
  
  // Mapping from token ID to index of ower token list
  mapping (uint256 => uint256) internal ownedTokensIndex;
 
 // Array with all token ids, used for enumeration
  uint256[] internal allTokens; 

  // Mapping from token id to position in the allTokens array
  mapping(uint256 => uint256) internal allTokensIndex;

  // Mapping from address to number of tokens minted by address
  mapping (address => uint256) public addrToArtistTokenNumber;

  // Mapping for TokenData struct
  mapping (uint256 => string) public tokenToName;
  mapping (uint256 => string) public tokenToDescription;
  mapping (uint256 => address) public tokenToArtistAddress;
  mapping (uint256 => uint256) public tokenToArtistTokenNumber; 
  mapping (uint256 => uint256) public tokenToTimeCreated;
  mapping (uint256 => uint8) public tokenToRoyaltyPercentage;
  mapping (uint256 => bool) public tokenToRedeemed;

  function getArtistAddress(uint256 _tokenId) public view returns (address) {
      return tokenToArtistAddress[_tokenId];
  }
  
  function getRoyaltyPercentage(uint256 _tokenId) public view returns (uint8) {
      return tokenToRoyaltyPercentage[_tokenId];
  }

  /**
   * @dev Gets the token ID at a given index of the tokens list of the requested owner
   * @param _owner address owning the tokens list to be accessed
   * @param _index uint256 representing the index to be accessed of the requested tokens list
   * @return uint256 token ID at the given index of the tokens list owned by the requested address
   */
  function tokenOfOwnerByIndex(address _owner, uint256 _index) public view returns (uint256) {
    require(_index < balanceOf(_owner));
    return ownedTokens[_owner][_index];
  }

  /**
   * @dev Gets the total amount of tokens stored by the contract
   * @return uint256 representing the total amount of tokens
   */
  function totalSupply() public view returns (uint256) {
    return allTokens.length;
  }

  /**
   * @dev Gets the token ID at a given index of all the tokens in this contract
   * @dev Reverts if the index is greater or equal to the total number of tokens
   * @param _index uint256 representing the index to be accessed of the tokens list
   * @return uint256 token ID at the given index of the tokens list
   */
  function tokenByIndex(uint256 _index) public view returns (uint256) {
    require(_index < totalSupply());
    return allTokens[_index];
  }
  
  /**
  * @dev Gets token data at a given index of all the tokens in this contract
  * @dev Reverts if the index is greater or equal to the total number of tokens
  * @param _index uint256 representing the index to be accessed of the tokens list
  * @return data in tokenData struct
  */
  function tokenDataByIndex(uint256 _index) public view 
  returns (string, string, address, uint256, uint256, uint8, bool) {
    require(_index < totalSupply());
    return (tokenToName[_index],
            tokenToDescription[_index],
            tokenToArtistAddress[_index],
            tokenToArtistTokenNumber[_index],
            tokenToTimeCreated[_index],
            tokenToRoyaltyPercentage[_index],
            tokenToRedeemed[_index]);
  }
  
  /**
   * @dev Internal function to add a token ID to the list of a given address
   * @param _to address representing the new owner of the given token ID
   * @param _tokenId uint256 ID of the token to be added to the tokens list of the given address
   */
  function addTokenTo(address _to, uint256 _tokenId) internal {
    super.addTokenTo(_to, _tokenId);
    uint256 length = ownedTokens[_to].length;
    ownedTokens[_to].push(_tokenId);
    ownedTokensIndex[_tokenId] = length;
  }  

  /**
   * @dev Internal function to remove a token ID from the list of a given address
   * @param _from address representing the previous owner of the given token ID
   * @param _tokenId uint256 ID of the token to be removed from the tokens list of the given address
   */
  function removeTokenFrom(address _from, uint256 _tokenId) internal {
    super.removeTokenFrom(_from, _tokenId);

    uint256 tokenIndex = ownedTokensIndex[_tokenId];
    uint256 lastTokenIndex = ownedTokens[_from].length.sub(1);
    uint256 lastToken = ownedTokens[_from][lastTokenIndex];

    ownedTokens[_from][tokenIndex] = lastToken;
    ownedTokens[_from][lastTokenIndex] = 0;
    // Note that this will handle single-element arrays. In that case, both tokenIndex and lastTokenIndex are going to
    // be zero. Then we can make sure that we will remove _tokenId from the ownedTokens list since we are first swapping
    // the lastToken to the first position, and then dropping the element placed in the last position of the list

    ownedTokens[_from].length--;
    ownedTokensIndex[_tokenId] = 0;
    ownedTokensIndex[lastToken] = tokenIndex;
  }

  function getOwnedTokens(address _owner) public view returns (uint256[]) {
    return ownedTokens[_owner];
  }

  function getMintedTokens(address _minter) public view returns (uint256[]) {
    return mintedTokens[_minter];
  }

  /**
   * @dev Public function to mint a token, minted token will be credited to the creator
   * @dev Royalty Percentage is fixed at 5%
   * @param _name name of token to be minted
   * @param _description of token to be minted
   */
  function mint(string _name, 
                string _description) public {

    super._mint(msg.sender, tokens.length);

    // add data
    uint256 _timeCreated = now;
    uint256 _artistTokenNumber = addrToArtistTokenNumber[msg.sender];
    
    allTokensIndex[_tokenId] = allTokens.length;
    allTokens.push(_tokenId);

    // Keep track of tokens minted
    mintedTokens[msg.sender].push(_tokenId); 
    
    // royalty percentage
    // use a fixed royalty percentage
    uint8 _royaltyPercentage = 5;
    
    uint256 _tokenId = tokens.push(TokenData(_name,
                                            _description,
                                            msg.sender,
                                            _artistTokenNumber,
                                            _timeCreated,
                                            _royaltyPercentage,
                                            false)).sub(1);


    // update mappings
    addrToArtistTokenNumber[msg.sender] = addrToArtistTokenNumber[msg.sender].add(1);
    tokenToName[_tokenId] = _name;
    tokenToDescription[_tokenId] = _description;
    tokenToArtistAddress[_tokenId] = msg.sender;
    tokenToArtistTokenNumber[_tokenId] = _artistTokenNumber;
    tokenToTimeCreated[_tokenId] = _timeCreated;
    tokenToRoyaltyPercentage[_tokenId] = _royaltyPercentage;
  }
  
  /**
   * @dev Public function to batch mint a token with same _name and _description
   * @dev Repeatedly calls mint
   * @dev reverts if numToken <= 0 or numToken > 5
   * @param _name name of token to be minted
   * @param _description of token to be minted
   * @param _numToken number of tokens to mint
   */
  function batchMint(string _name,
                     string _description,
                     uint8 _numToken) public {
    require(_numToken <= 5);
    require(_numToken > 0);
    for(uint8 i = 0; i < _numToken; i++) {
      mint(_name, _description);  
    }
  }
    
    /**
     * @dev Toggles token redeemed state
     * @dev The artist address controls the redeem state
     * @param _tokenId uint256 id of token
     */ 
  function toggleRedeem(uint256 _tokenId) public {
  
    require(msg.sender == tokenToArtistAddress[_tokenId]);
    bool state;
    if(tokenToRedeemed[_tokenId] == true) {
        state = false;
    } else {
        state = true;
    }
    // update token address
    tokenToRedeemed[_tokenId] = state;
    
    TokenData memory newData =  TokenData(tokenToName[_tokenId],
                                          tokenToDescription[_tokenId],
                                          tokenToArtistAddress[_tokenId],
                                          tokenToArtistTokenNumber[_tokenId],
                                          tokenToTimeCreated[_tokenId],
                                          tokenToRoyaltyPercentage[_tokenId],
                                          tokenToRedeemed[_tokenId]);
    tokens[_tokenId] = newData;
  }
}
