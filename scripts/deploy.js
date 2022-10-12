// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");

async function main() {

  const LensInteractions = await hre.ethers.getContractFactory("LensInteractions");
  const lensInteractions = await LensInteractions.deploy("0x7582177F9E536aB0b6c721e11f383C326F2Ad1D5");

  await lensInteractions.deployed();

  console.log(
    `lensInteractions deployed to ${lensInteractions.address}`
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
