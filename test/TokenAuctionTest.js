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

  it("should be able to withdraw funds if outbidded", () => {
    return TokenAuction.deployed().then(instance => {
      instance.mint("Test Token", "Test Description");
      instance.createAuction(2, 1000, 20);

      let initial = web3.eth.getBalance(accounts[1]).toString();

      instance.bid(2, "0x0", {value: 200000, from: accounts[1]});
      instance.bid(2, "0x0", {value: 300000, from: accounts[2]});
      
      instance.withdraw({from: accounts[1]});
      return [initial, web3.eth.getBalance(accounts[1]).toString()];
    }).then(balances => {
      assert.isTrue(balances[0] == balances[1], "Old and new balance are not equal");
    });
  });

  it("should receive token if winner", () => {
    return TokenAuction.deployed().then(instance => {
      instance.mint("Test Token", "Test Description"); instance.createAuction(3, 1000, 3);
      instance.bid(3, "0x0", {value: 200000, from: accounts[1]});

      setTimeout(() => {
        instance.closeAuction(3).then(() => {
          return instance.ownerOf(3);
        }).then((addr) => {
            assert.equal(addr, accounts[1], "Auction winner does not have token");
        });
      }, 4000);
    });
  });

  it("new owner should be able to make a new auction and cancel", () => {
    return TokenAuction.deployed().then(instance => {
      instance.mint("Test Token", "Test Description");
      instance.createAuction(4, 1000, 3);
      instance.bid(4, "0x0", {value: 200000, from: accounts[1]});

      setTimeout(() => {
        instance.closeAuction(4).then(() => {
          instance.createAuction(4, 1000, 3, {from: accounts[1]});
          instance.cancelAuction(4);
          return instance.ownerOf(4);
        }).then((addr) => {
            assert.equal(addr, accounts[1], "Token owner is not the auction creator");
        });
      }, 4000);
    });
  });

  it("artist should receive royalty", () => {
    return TokenAuction.deployed().then(instance => {
      instance.mint("Test Token", "Test Description");
      instance.createAuction(5, 1000, 3);
      instance.bid(5, "0x0", {value: 200000, from: accounts[1]});

      setTimeout(() => {
        instance.closeAuction(5).then(() => {
          instance.createAuction(5, 1000, 3, {from: accounts[1]});
          instance.bid(5, "0x0", {value: 200000, from: accounts[2]});

          setTimeout(() => {
            instance.closeAuction(5).then(() => {
              let initial = web3.eth.getBalance(accounts[0]).toString();
              return initial;
            }).then(initial => {
              instance.withdraw();
              let newBalance = web3.eth.getBalance(accounts[0]).toString();
              assert.isTrue(newBalance > initial, "Artist did not receive royalty");
            });
          
          }, 4000);
        });

      }, 4000);
    });
  });

});
