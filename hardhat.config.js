require("@nomicfoundation/hardhat-toolbox");
require("@nomicfoundation/hardhat-chai-matchers");
require("dotenv").config();
// require('@openzeppelin/hardhat-upgrades');

const { API_URL, PRIVATE_KEY, POLYGON_API_KEY } = process.env;

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.10",
  networks: {
    localhost: {
      blockGasLimit: 8000000000, // whatever you want here
      allowUnlimitedContractSize: true ,
    },
    mumbai: {
      url: API_URL,
      accounts: [`0x${PRIVATE_KEY}`],
    },
  },
  etherscan: {
    apiKey: {
      polygonMumbai: POLYGON_API_KEY,
    },
  },
};
