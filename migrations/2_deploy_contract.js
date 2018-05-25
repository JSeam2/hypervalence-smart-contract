const ArtistToken = artifacts.require("./ArtistToken.sol");                                                                                                            
const TokenAuction = artifacts.require("./TokenAuction.sol");
 module.exports = function(deployer) {                                                                         
     deployer.deploy(ArtistToken);                                                                      
	 deployer.deploy(TokenAuction);
 };                                                                                                            
        
