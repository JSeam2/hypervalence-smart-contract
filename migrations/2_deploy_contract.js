const HypeToken = artifacts.require("./HypeToken.sol");                                                                                                            
const TokenAuction = artifacts.require("./TokenAuction.sol");
 module.exports = function(deployer) { 
   deployer.deploy(HypeToken); 
   deployer.deploy(TokenAuction);
 };                                                                                                            
        
