pragma solidity ^0.4.21;

import "../node_modules/openzeppelin-solidity/contracts/token/ERC721/ERC721.sol";
import "../node_modules/openzeppelin-solidity/contracts/token/ERC721/ERC721BasicToken.sol";
import "../node_modules/openzeppelin-solidity/contracts/AddressUtils.sol";
import "../node_modules/openzeppelin-solidity/contracts/math/SafeMath.sol";

contract ArtistToken is ERC721, ERC721BasicToken {
  using SafeMath for uint256;
  using AddressUtils for address;

  // Token name
  string internal name_;

  // Token symbol
  string internal symbol_;  


  /// @notice struct that holds token data
  /// @param name the name of the token
  /// @param description information about the token, you may indicate benefits the token confers and the time it is valid until.
  /// @param artistAddress the address of the artist who created the token
  /// @param artistTokenNumber the number of tokens created by the artist. eg 1st token, 2nd, ..., nth token
  /// @param timeCreated the block timestamp time where the token was created
  /// @param royaltyPercentage the royalty percentage the artist receives from exchange of the token. This is specified by the artist.
  
  struct TokenData {
    string name;
    string description;
    address artistAddress;
    uint256 artistTokenNumber;
    uint256 timeCreated;
    uint8 royaltyPercentage;
  }

  TokenData[] internal tokens;

  // Mapping from owner to list of owned token ID
  mapping (address => uint256[]) internal ownedTokens;
  
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

	/**
	* @dev Constructor function
	**/
	constructor(string _name, string _symbol) public {
		name_ = _name;
		symbol_ = _symbol;
	}

  /**
   * @dev Gets the token name
   * @return string representing the token name
   */
  function name() public view returns (string) {
    return name_;
  }

  /**
   * @dev Gets the token symbol
   * @return string representing the token symbol
   */
  function symbol() public view returns (string) {
    return symbol_;
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
    return tokens.length;
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
  returns (string, string, address, uint256, uint256, uint8) {
    require(_index < totalSupply());
    return (tokenToName[_index],
            tokenToDescription[_index],
            tokenToArtistAddress[_index],
            tokenToArtistTokenNumber[_index],
            tokenToTimeCreated[_index],
            tokenToRoyaltyPercentage[_index]);
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

  /**
   * @dev Public function to mint a token, minted token will be credited to the creator
   * @dev Reverts if royalty percentage > 100 or < 0
   */
  function mint(string _name, 
                string _description,
                uint8 _royaltyPercentage) public {

    require(_royaltyPercentage >= 0);
    require(_royaltyPercentage <= 100);

    super._mint(msg.sender, tokens.length);

    // add data
    uint256 _timeCreated = now;
    uint256 _artistTokenNumber = addrToArtistTokenNumber[msg.sender];
    
    allTokensIndex[_tokenId] = tokens.length;
    allTokens.push(_tokenId);
    
    uint256 _tokenId = tokens.push(TokenData(_name,
                                            _description,
                                            msg.sender,
                                            _artistTokenNumber,
                                            _timeCreated,
                                            _royaltyPercentage)).sub(1);

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
   * @dev Public function to burn a specific token
   * @dev Reverts if the token does not exist
   * @param _tokenId uint256 ID of the token being burned by the msg.sender
   */
  function burn(uint256 _tokenId) public {
    super._burn(msg.sender, _tokenId);

    // Reorg all tokens array
    uint256 tokenIndex = allTokensIndex[_tokenId];
    uint256 lastTokenIndex = tokens.length.sub(1);
    TokenData storage lastToken = tokens[lastTokenIndex];
    
    uint256 tokenIndex_all = allTokensIndex[_tokenId];
    uint256 lastTokenIndex_all = allTokens.length.sub(1);
    uint256 lastToken_all = allTokens[lastTokenIndex];

    tokens[tokenIndex] = lastToken;
    delete tokens[lastTokenIndex];
    tokens.length--;

    allTokens[tokenIndex_all] = lastToken_all;
    allTokens[lastTokenIndex_all] = 0;
    allTokens.length--;
    
    allTokensIndex[_tokenId] = 0;
    allTokensIndex[lastTokenIndex] = tokenIndex;
  }
}
