/**
* TokenAuctionTest
*/

const TokenAuction = artifacts.require("TokenAuction");

contract("TokenAuction", (accounts) => {
	it("should have 0 tokens initially", () => {
		return TokenAuction.deployed().then((instance) => {
			return instance.totalSupply.call();
		}).then((supply) => {
			assert.equal(supply.valueOf(), 0, "Started with more than 0???"); 
		});	
	});

});

