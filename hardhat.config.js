require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();

const {API_URL, PRIVATE_KEY, POLYGON_API_KEY} = process.env;

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.17",
  networks: {
    mumbai: {
      url: API_URL,
      accounts: [`0x${PRIVATE_KEY}`],
      
  
    }
  },
  etherscan: {
    apiKey: {
        polygonMumbai: POLYGON_API_KEY
      }
  },
};
