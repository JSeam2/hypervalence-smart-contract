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
      from: "0xe2de31f1bc5bb18234ca9ff3eec9e7783d447b37",
      gas: 6000000
    }
  }
};

