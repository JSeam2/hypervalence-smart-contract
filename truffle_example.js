var HDWalletProvider = require("truffle-hdwallet-provider");

// insert mnemonic from some mnemonic generator
var mnemonic = "push shock journey victory apology slush reflect cement gadget door wage logic";

// insert infura url
var infuraURL = "https://rinkeby.infura.io/JRIhcMSUX50sCH9PKk6b"

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
      provider: return new HDWalletProvider(mnemonic, infuraURL),
      from: "0x0d604c28a2a7c199c7705859c3f88a71cce2acb7",
      port: 8545,
      network_id: 4,
      gas: 4700000,
    }
  }
};

