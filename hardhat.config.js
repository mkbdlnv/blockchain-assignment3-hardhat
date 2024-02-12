require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();
RPC_URL = process.env.RPC_URL;
const PRIVATE_KEY = process.env.PRIVATE_KEY;
/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  defaultNetwork: "hardhat",
  networks:{
    sepolia: {
      url: RPC_URL,
      accounts: [PRIVATE_KEY],
      chainId: 11155111,
    },
  },
  etherscan: {
    apiKey: "CEQ1DDK3EHRQX7GZSM816JH9WS62UGD9JH"
  },
  sourcify: {
    enabled: true
  },
  
  solidity: "0.8.20",
};
