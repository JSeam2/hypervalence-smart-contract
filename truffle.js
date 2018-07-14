module.exports = {
  // See <http://truffleframework.com/docs/advanced/configuration>
  // to customize your Truffle configuration!
  networks: {
    test: {
      host: "127.0.0.1",
      port: 7545,
      network_id: "*" // match any network id
    },
	
    testnet: {
      host: "127.0.0.1",
      port: 8545,
      network_id: 3,
      gas: 4700000
    }
  }
};

