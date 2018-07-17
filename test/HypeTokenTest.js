/**
* HypeTokenTest
* Unit tests for token functionality
*/

const HypeToken = artifacts.require("HypeToken");

contract("HypeToken", (accounts) => {

	it("should have 0 tokens initially", () => {
		return HypeToken.deployed().then(instance => {
			return instance.totalSupply.call();
		}).then(supply => {
			assert.equal(supply.valueOf(), 0, "Should not start with more than 0 tokens"); 
		});	
	});

	it("should have 1 token in totalSupply after minting", () => {
		return HypeToken.deployed().then(instance => {
			instance.mint("Test Token", "Test Description");
			return instance.totalSupply.call();
		}).then(supply => {
			assert.equal(supply.valueOf(), 1, "TotalSupply should not be more than 1");
		});
	});

	it("should transfer without errors", () => {
		return HypeToken.deployed().then(instance => {
			instance.mint("Test Token", "Test Description");
			instance.transferFrom(accounts[0], accounts[1], 0);
			return instance.ownerOf(0);
		}).then(addr => {
			assert.equal(accounts[1], addr, "Addresses should equal");
		});
	});

  // Testing redeem functionality
  it("Original state of token redeem should be false", () => {
    return HypeToken.deployed().then(instance => {
      instance.mint("Test Token", "Test Description");
      return instance.tokenToRedeemed(2);
    }).then(state => {
      assert.equal(state, false, "Token redeem state should be false at first");
    });
  });

  it("Original creator of token should be able to change redeem state", () => {
    return HypeToken.deployed().then(instance => {
      instance.toggleRedeem(2);
      return instance.tokenToRedeemed(2);
    }).then(state => {
      assert.equal(state, true, "After triggering redeemed, the token should be true");
    });
  });

  it("Original creator of token should be able to change redeem state again", () => {
    return HypeToken.deployed().then(instance => {
      instance.toggleRedeem(2);
      return instance.tokenToRedeemed(2);
    }).then(state => {
      assert.equal(state, false, "After triggering redeemed again, the token should be false");
    });
  });

});

