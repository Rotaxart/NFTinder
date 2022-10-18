const {
  time,
  loadFixture,
} = require("@nomicfoundation/hardhat-network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");
const { defaultAbiCoder } = require("ethers/lib/utils");
const lensProxy = "0x1A1FEe7EeD918BD762173e4dc5EfDB8a78C924A8";
const ZERO_ADDRESS = "0x0000000000000000000000000000000000000000";
const postStruct = [
  1,
  "https://ipfs.io/ipfs/Qme7ss3ARVgxv6rXqVPiikMJ8u2NLgmgszg13pYrDKEoiu",
  "0x2D8553F9ddA85A9B3259F6Bf26911364B85556F5",
  "0x0000000000000000000000000000000000000000000000000000000000000001",
  ZERO_ADDRESS,
  [],
];

const commentStruct = [
  1,
  "https://ipfs.io/ipfs/QmbWqxBEKC3P8tqsKc98xmWNzrzDtRLMiMPL8wBuTGsMnR",
  1,
  1,
  [],
  "0x2D8553F9ddA85A9B3259F6Bf26911364B85556F5",
  "0x0000000000000000000000000000000000000000000000000000000000000001",
  ZERO_ADDRESS,
  []
];

describe("NFTinLogic", function () {
  // We define a fixture to reuse the same setup in every test.
  // We use loadFixture to run this setup once, snapshot that state,
  // and reset Hardhat Network to that snapshot in every test.
  async function deployNFTinLogic() {
    // Contracts are deployed using the first signer/account by default
    const [owner, otherAccount, user1, user2] = await ethers.getSigners();

    const NFTinLogic = await hre.ethers.getContractFactory("NFTinLogic");
    const nFTinLogic = await NFTinLogic.deploy();
    const lensAddress = await nFTinLogic.setLensHubAddress(lensProxy);
    return { nFTinLogic, owner, otherAccount, lensAddress, user1, user2 };
  }

  async function connectionToLens() {
    const Lens = await hre.ethers.getContractFactory("LensHub", {
      libraries: {
        InteractionLogic: "0x0078371BDeDE8aAc7DeBfFf451B74c5EDB385Af7",
        ProfileTokenURILogic: "0x53369fd4680FfE3DfF39Fc6DDa9CfbfD43daeA2E",
        PublishingLogic: "0x8858eeB3DfffA017D4BCE9801D340D36Cf895CCf",
      },
    });
    const lens = await Lens.attach(lensProxy);
    return lens;
  }

  describe("set lens", () => {
    it("Should set the right lensAddress", async function () {
      const { nFTinLogic, lensAddress } = await loadFixture(deployNFTinLogic);

      expect(await nFTinLogic.lensAddress()).to.equal(lensProxy);
    });

    it("should set profile", async () => {
      const { nFTinLogic, lensAddress, owner, user2 } = await loadFixture(
        deployNFTinLogic
      );
      await nFTinLogic.connect(user2).onboardNewProfile(1);
      const profile = await nFTinLogic.connect(user2).getProfile(user2.address);
      expect(profile).to.eq(1);
    });

    it("should set post", async () => {
      const { nFTinLogic, lensAddress, owner, user2 } = await loadFixture(
        deployNFTinLogic
      );
      const lens = await loadFixture(connectionToLens);
      await lens.connect(user2).setDispatcher(1, nFTinLogic.address);
      await nFTinLogic.connect(user2).onboardNewProfile(1);
      await nFTinLogic.connect(user2).setPost(postStruct);
      const postCount = await lens.connect(user2).getPubCount(1);
      const pub = await nFTinLogic.getPostList(1);
      expect(pub.toString()).to.eq(postCount.toString());
    });

    it("should set comment", async () => {
      const { nFTinLogic, lensAddress, owner, user2 } = await loadFixture(
        deployNFTinLogic
      );

      const Lens = await hre.ethers.getContractFactory("LensHub", {
        libraries: {
          InteractionLogic: "0x0078371BDeDE8aAc7DeBfFf451B74c5EDB385Af7",
          ProfileTokenURILogic: "0x53369fd4680FfE3DfF39Fc6DDa9CfbfD43daeA2E",
          PublishingLogic: "0x8858eeB3DfffA017D4BCE9801D340D36Cf895CCf",
        },
      });
      const lens = await Lens.attach(lensProxy);
      console.log("ok");
      await lens.connect(user2).setDispatcher(1, nFTinLogic.address);

      await nFTinLogic.connect(user2).onboardNewProfile(1);
       await nFTinLogic.connect(user2).setPost(postStruct);
       await nFTinLogic.connect(user2).setComment(commentStruct);

       const comment = await nFTinLogic.getComments(1, 1);
       console.log({comment})
    });
  });
});
