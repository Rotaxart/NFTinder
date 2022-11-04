const hre = require("hardhat");

async function main() {

  const NFT721 = await hre.ethers.getContractFactory("Test721");
  const nft721 = await NFT721.deploy('0xc631A4fd3bC7b7B14159C8976276f75BCEAe054a');

  await nft721.deployed();

  console.log(
    `721 ${nft721.address}`
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});