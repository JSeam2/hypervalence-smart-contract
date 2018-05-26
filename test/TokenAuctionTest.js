/**
* TokenAuctionTest
*/

const TokenAuction = artifacts.require("TokenAuction");

contract("TokenAuction", (accounts) => {
	it("should have 0 tokens initially", () => {
		return TokenAuction.deployed().then(instance => {
			return instance.totalSupply.call();
		}).then(supply => {
			assert.equal(supply.valueOf(), 0, "Started with more than 0???"); 
		});	
	});

	it("should have 1 token in totalSupply after minting", () => {
		return TokenAuction.deployed().then(instance => {
			instance.mint("Test Token", "Test Description");
			return instance.totalSupply.call();
		}).then(supply => {
			assert.equal(supply.valueOf(), 1, "TotalSupply should not be more than 1");
		});
	});

	it("should transfer without errors", () => {
		return TokenAuction.deployed().then(instance => {
			instance.mint("Test Token", "Test Description");
			instance.transferFrom(accounts[0], accounts[1], 0);
			return instance.ownerOf(0);
		}).then(addr => {
			assert.equal(accounts[1], addr, "Addresses should equal");
		});
	});

	it("should start an auction and contract to act as escrow", () => {
		return TokenAuction.deployed().then(instance => {
			instance.mint("Test Token", "Test Description");
			instance.createAuction(1, 1000);
			return instance.ownerOf(1);
		}).then(addr => {
			assert.equal(addr, TokenAuction.address, "Owner of token after createAuction is not contract");
		});
	});

	it("should be able to cancel an auction", () => {
		return TokenAuction.deployed().then(instance => {
			instance.mint("Test Token", "Test Description");
			instance.createAuction(2, 1000);
			instance.cancelAuction(2);
			return instance.ownerOf(2);
		}).then(addr => {
			assert.equal(addr, accounts[0], "Owner of token after cancelAuction is not the original owner");
		});
	});
});

