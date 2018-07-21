module.exports = {
  // See <http://truffleframework.com/docs/advanced/configuration>
  // to customize your Truffle configuration!
  networks: {
    test: {
      host: "127.0.0.1",
      port: 7545,
      network_id: "*" // match any network id
    },

    rinkeby: {
      host: "127.0.0.1",
      port: 8545,
      network_id: 4,
      from: "0x0d604C28A2a7c199c7705859c3f88A71cCE2aCb7",
      gas: 6000000
    }
  }
};

