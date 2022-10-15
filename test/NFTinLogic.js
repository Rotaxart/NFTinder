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
    const [owner, otherAccount,user1,user2] = await ethers.getSigners();

    const NFTinLogic = await hre.ethers.getContractFactory("NFTinLogic");
    const nFTinLogic = await NFTinLogic.deploy();
    const lensAddress = await nFTinLogic.setLensHubAddress(lensProxy);

    console.log(nFTinLogic.address);
    return { nFTinLogic, owner, otherAccount, lensAddress, user1, user2 };
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

      //console.log(profile);

      expect(profile[0]).to.eq(owner.address);
      expect(profile[2][3]).to.eq("zer0dot");
    });

    it("should set post", async () => {
      const { nFTinLogic, lensAddress, owner, user2 } = await loadFixture(
        deployNFTinLogic
      );
      
      const Lens = await hre.ethers.getContractFactory("LensHub", {libraries: {
        InteractionLogic: "0x0078371BDeDE8aAc7DeBfFf451B74c5EDB385Af7",
        ProfileTokenURILogic: '0x53369fd4680FfE3DfF39Fc6DDa9CfbfD43daeA2E',
        PublishingLogic: "0x8858eeB3DfffA017D4BCE9801D340D36Cf895CCf"

      }});
      // const Lens = await ethers.getContractFactory("TransparentUpgradeableProxy")
      
      const lens = await Lens.attach(lensProxy);
      console.log(nFTinLogic.address)
      console.log(user2.address)

      await lens.connect(user2).setDispatcher(1, nFTinLogic.address)

      const disp = await lens.connect(user2).getDispatcher(1);
      console.log({disp})

      const postStruct = [1,
       "https://ipfs.io/ipfs/Qmby8QocUU2sPZL46rZeMctAuF5nrCc7eR1PPkooCztWPz",
        "0x2D8553F9ddA85A9B3259F6Bf26911364B85556F5",
        '0x0000000000000000000000000000000000000000000000000000000000000001',
      ZERO_ADDRESS,
        []]

      const tx = await nFTinLogic.setPost(postStruct);
      

        const count = await lens.connect(user2).getPubCount(1)
        console.log(count.toNumber())

        const lensPost = await lens.connect(user2).getPub(1, count)

        const post = await nFTinLogic.posts(1, count);
        console.log(post.post)
        expect(post.post[2]).not.to.eq("");
        expect(post.post.toString()).to.eq(lensPost.toString());
        
      //const pub = await nFTinLogic.getPub(1, 2)
      

      //onsole.log({pub})
      
      // console.log();
      // tx.wait();

       //const post = await nFTinLogic.profiles.posts(tx);

     // console.log(post);

      // expect(profile[0]).to.eq(owner.address);
      // expect(profile[2][3]).to.eq("zer0dot");
    });
  });
});
