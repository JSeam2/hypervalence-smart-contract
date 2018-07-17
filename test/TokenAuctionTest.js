/**
* TokenAuctionTest
* Unit tests for auction functionality
*/

const TokenAuction = artifacts.require("TokenAuction");

contract("TokenAuction", (accounts) => {
	it("should start an auction and contract to act as escrow", () => {
		return TokenAuction.deployed().then(instance => {
			instance.mint("Test Token", "Test Description");
			instance.createAuction(0, 1000, 100);
			return instance.ownerOf(0);
		}).then(addr => {
			assert.equal(addr, TokenAuction.address, "Owner of token after createAuction is not contract");
		});
	});

	it("should be able to cancel an auction", () => {
		return TokenAuction.deployed().then(instance => {
			instance.mint("Test Token", "Test Description");
			instance.createAuction(1, 1000, 100);
			instance.cancelAuction(1);
			return instance.ownerOf(1);
		}).then(addr => {
			assert.equal(addr, accounts[0], "Owner of token after cancelAuction is not the original owner");
		});
	});
});

