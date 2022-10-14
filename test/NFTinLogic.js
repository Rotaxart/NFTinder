const {
  time,
  loadFixture,
} = require("@nomicfoundation/hardhat-network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");
const { defaultAbiCoder } = require("ethers/lib/utils");
const lensProxy = "0x1A1FEe7EeD918BD762173e4dc5EfDB8a78C924A8";
const ZERO_ADDRESS = "0x0000000000000000000000000000000000000000";

describe("NFTinLogic", function () {
  // We define a fixture to reuse the same setup in every test.
  // We use loadFixture to run this setup once, snapshot that state,
  // and reset Hardhat Network to that snapshot in every test.
  async function deployNFTinLogic() {
    // Contracts are deployed using the first signer/account by default
    const [owner, otherAccount,,user] = await ethers.getSigners();

    const NFTinLogic = await hre.ethers.getContractFactory("NFTinLogic");
    const nFTinLogic = await NFTinLogic.deploy();
    const lensAddress = await nFTinLogic.setLensHubAddress(lensProxy);

    console.log(nFTinLogic.address);
    return { nFTinLogic, owner, otherAccount, lensAddress };
  }

  describe("set lens", () => {
    it("Should set the right lensAddress", async function () {
      const { nFTinLogic, lensAddress } = await loadFixture(deployNFTinLogic);

      expect(await nFTinLogic.lensAddress()).to.equal(lensProxy);
    });

    it("should set profile", async () => {
      const { nFTinLogic, lensAddress, owner } = await loadFixture(
        deployNFTinLogic
      );
      tx = await nFTinLogic.onboardNewProfile(1);
      await tx.wait();
      const profile = await nFTinLogic.profiles(1);

      console.log(profile);

      expect(profile[0]).to.eq(owner.address);
      expect(profile[2][3]).to.eq("zer0dot");
    });

    it("should set post", async () => {
      const { nFTinLogic, lensAddress, owner, user } = await loadFixture(
        deployNFTinLogic
      );
      
      const Lens = await hre.ethers.getContractFactory("TransparentUpgradeableProxy");
      // const Lens = await ethers.getContractFactory("TransparentUpgradeableProxy")
      
      const lens = await Lens.attach(lensProxy);

      await lens.setDispatcher(1, nFTinLogic.address)

      const tx = await nFTinLogic.post([1,
        "https://ipfs.io/ipfs/Qmby8QocUU2sPZL46rZeMctAuF5nrCc7eR1PPkooCztWPz",
        "0x2D8553F9ddA85A9B3259F6Bf26911364B85556F5",
        '0x0000000000000000000000000000000000000000000000000000000000000001',
        ZERO_ADDRESS,
        []]);
      tx.wait();

      console.log(lens.address)

      const pub = await nFTinLogic.getPub(1, 1)
      

      console.log({pub})
      
      // console.log();
      // tx.wait();

      // const post = await nFTinLogic.profiles.posts(tx);

      // console.log(post);

      // expect(profile[0]).to.eq(owner.address);
      // expect(profile[2][3]).to.eq("zer0dot");
    });
  });
});
