const {ethers} = require("hardhat")


async function main(){
  const ERC721NFT = await ethers.getContractFactory("ERC721NFT");
  console.log("Deploying contract...");
  const nft = await ERC721NFT.deploy();
  console.log("Deployed contract to " + nft.target)
}

main()
.then(()=>process.exit(0))
.catch((error) => {
  console.error(error);
  process.exit(1)
})