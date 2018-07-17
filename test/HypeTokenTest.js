/**
* HypeTokenTest
* Unit tests for token functionality
*/

const HypeToken = artifacts.require("TokenAuction");

contract("HypeToken", (accounts) => {

  /**
   * Testing basic token functionality
   */
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
			instance.safeTransferFrom(accounts[0], accounts[1], 0);
			return instance.ownerOf(0);
		}).then(addr => {
			assert.equal(accounts[1], addr, "Addresses should equal");
		});
	});

  it("should transfer between people without errors", () => {
		return HypeToken.deployed().then(instance => {
			instance.mint("Test Token", "Test Description");
			instance.safeTransferFrom(accounts[1], accounts[2], 0, {from: accounts[1]});
      instance.safeTransferFrom(accounts[2], accounts[3], 0, {from: accounts[2]});
			return instance.ownerOf(0);
		}).then(addr => {
			assert.equal(accounts[3], addr, "Addresses should equal");
		});
  });

  /** 
   * Testing redeem functionality
   */
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
      assert.equal(state, true, "Token redeem state should be true");
    });
  });

  it("Original creator of token should be able to change redeem state again", () => {
    return HypeToken.deployed().then(instance => {
      instance.toggleRedeem(2);
      return instance.tokenToRedeemed(2);
    }).then(state => {
      assert.equal(state, false, "Token redeem state should be false");
    });
  });

  it("Original creator of token should be able to change redeem state after sending", () => {
    return HypeToken.deployed().then(instance => {
			instance.safeTransferFrom(accounts[0], accounts[1], 2);
      instance.toggleRedeem(2);
      return instance.tokenToRedeemed(2);
    }).then(state => {
      assert.equal(state, true, "Token redeem state shoule be true");
    });
  });

});

