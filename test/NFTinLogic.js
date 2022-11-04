const {
  time,
  loadFixture,
} = require("@nomicfoundation/hardhat-network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");
const { defaultAbiCoder } = require("ethers/lib/utils");
require("@nomicfoundation/hardhat-chai-matchers");
const lensProxy = "0x1A1FEe7EeD918BD762173e4dc5EfDB8a78C924A8";
const bytesTrue =
  "0x0000000000000000000000000000000000000000000000000000000000000001";
const freeCollectModule = "0x2D8553F9ddA85A9B3259F6Bf26911364B85556F5";
const postURI =
  "https://ipfs.io/ipfs/Qme7ss3ARVgxv6rXqVPiikMJ8u2NLgmgszg13pYrDKEoiu";
const commentURI =
  "https://ipfs.io/ipfs/QmbWqxBEKC3P8tqsKc98xmWNzrzDtRLMiMPL8wBuTGsMnR";
const ZERO_ADDRESS = "0x0000000000000000000000000000000000000000";
const postStruct = [1, postURI, freeCollectModule, bytesTrue, ZERO_ADDRESS, []];

const commentStruct = [
  1,
  commentURI,
  1,
  1,
  [],
  freeCollectModule,
  bytesTrue,
  ZERO_ADDRESS,
  [],
];
console.log({postStruct})
const mirrorStruct = [1, 1, 1, [], ZERO_ADDRESS, []];

describe("NFTinLogic", function () {
  // We define a fixture to reuse the same setup in every test.
  // We use loadFixture to run this setup once, snapshot that state,
  // and reset Hardhat Network to that snapshot in every test.
  async function deployNFTinLogic() {
    // Contracts are deployed using the first signer/account by default
    const [owner, otherAccount, user1, user2, user3] =
      await ethers.getSigners();

    const TinTioken = await hre.ethers.getContractFactory("TinToken");
    const tinToken = await TinTioken.deploy();

    const NFTinLogic = await hre.ethers.getContractFactory("NFTinLogic");
    const nFTinLogic = await NFTinLogic.deploy();
    const lensAddress = await nFTinLogic.setLensHubAddress(lensProxy);
    await nFTinLogic.setTinToken(tinToken.address);
    await tinToken.approve(nFTinLogic.address, "1000000000000000000000000000");
    const balance = await tinToken.balanceOf(nFTinLogic.address);
    await tinToken
      .connect(user2)
      .approve(nFTinLogic.address, "1000000000000000000");
    await tinToken
      .connect(user3)
      .approve(nFTinLogic.address, "1000000000000000000");
    const Test721 = await hre.ethers.getContractFactory("Test721");
    const test721 = await Test721.deploy(user2.address);
    // await test721.transferFrom(owner.address, user2.address, 1) ;

    const address721 = test721.address;

    const Lens = await hre.ethers.getContractFactory("LensHub", {
      libraries: {
        InteractionLogic: "0x0078371BDeDE8aAc7DeBfFf451B74c5EDB385Af7",
        ProfileTokenURILogic: "0x53369fd4680FfE3DfF39Fc6DDa9CfbfD43daeA2E",
        PublishingLogic: "0x8858eeB3DfffA017D4BCE9801D340D36Cf895CCf",
      },
    });
    const lens = await Lens.attach(lensProxy);
    // const transfer = await test721.connect(user2).transferFrom(  user2.address, user3.address, 1) ;
    await lens.connect(user2).setDispatcher(1, nFTinLogic.address);
    await lens.connect(user3).setDispatcher(2, nFTinLogic.address);
    await nFTinLogic.connect(user2).onboardNewProfile(1);
    await nFTinLogic.connect(user3).onboardNewProfile(2);
    return {
      nFTinLogic,
      owner,
      otherAccount,
      lensAddress,
      user1,
      user2,
      user3,
      address721,
      tinToken,
      test721,
      lens,
    };
  }


  describe("Main functions", () => {
    it("Should set the right lensAddress", async function () {
      const { nFTinLogic, lens } = await loadFixture(deployNFTinLogic);
      expect(await nFTinLogic.lensAddress()).to.equal(lensProxy);
    });

    it("should set profile", async () => {
      const { nFTinLogic, lens, owner, user2, address721 } = await loadFixture(
        deployNFTinLogic
      );
      const profile = await nFTinLogic.connect(user2).getProfile(user2.address);
      expect(profile).to.eq(1);
    });

    it("should set post", async () => {
      const { nFTinLogic, lens, owner, user2, address721 } = await loadFixture(
        deployNFTinLogic
      );
      await nFTinLogic.connect(user2).setPost(postStruct, address721, 1, 0);
      const postCount = await lens.connect(user2).getPubCount(1);
      const pub = await nFTinLogic.getPostList(1);
      expect(pub.toString()).to.eq(postCount.toString());
    });

    it("should set comment", async () => {
      const { nFTinLogic, lens, owner, user2, address721 } = await loadFixture(
        deployNFTinLogic
      );

      await nFTinLogic.connect(user2).setPost(postStruct, address721, 1, 0);

      const postCount = await lens.connect(user2).getPubCount(1);
      await nFTinLogic
        .connect(user2)
        .setComment([
          1,
          commentURI,
          1,
          postCount.toString(),
          [],
          freeCollectModule,
          bytesTrue,
          ZERO_ADDRESS,
          [],
        ]);
      const postCount2 = await lens.connect(user2).getPubCount(1);

      const comment = await nFTinLogic.getComments(1, postCount);
      const commentInLens = await lens
        .connect(user2)
        .getPub(1, postCount2.toString());
      const pubType = await lens.connect(user2).getPubType(1, postCount2);
      expect(comment[0][2]).to.eq(postCount2);
      expect(commentInLens[2]).to.eq(commentStruct[1]);
      expect(pubType).to.eq(1);
    });

    it("should set mirror", async () => {
      const { nFTinLogic, lens, owner, user2, address721 } = await loadFixture(
        deployNFTinLogic
      );

      await nFTinLogic.connect(user2).setPost(postStruct, address721, 1, 0);

      const postCount = await lens.connect(user2).getPubCount(1);

      await nFTinLogic
        .connect(user2)
        .setMirror([1, 1, postCount.toString(), [], ZERO_ADDRESS, []]);
      const mirror = await nFTinLogic.getMirrors(1);
      const postCount2 = await lens.connect(user2).getPubCount(1);
      const lensMirror = await lens
        .connect(user2)
        .getPub(1, postCount2.toString());
      const pubType = await lens.connect(user2).getPubType(1, postCount2);
      expect(mirror[0][0]).to.eq(postCount2);
      expect(lensMirror[0]).to.eq(1);
      expect(pubType).to.eq(2);
    });

    it("should set like", async () => {
      const { nFTinLogic, lens, owner, user2, address721 } = await loadFixture(
        deployNFTinLogic
      );

      await nFTinLogic.connect(user2).setPost(postStruct, address721, 1, 0);

      const postCount = await lens.connect(user2).getPubCount(1);
      await nFTinLogic.connect(user2).setLike(1, 1, postCount);
      const like = await nFTinLogic.likes(1, postCount, 1);
      const likesCount = await nFTinLogic.likesCount(1, postCount);
      const pubRating = await nFTinLogic.pubRating(1, postCount);
      expect(like).to.eq(true);
      expect(likesCount).to.eq(1);
    });

    it("should disable publication", async () =>{
      const { nFTinLogic, lens, owner, user2, address721 } = await loadFixture(
        deployNFTinLogic
      );
      await nFTinLogic.connect(user2).setPost(postStruct, address721, 1, 0);
      const postCount = await lens.connect(user2).getPubCount(1);
      await nFTinLogic.disablePost(1, postCount);
      const postList = await nFTinLogic.getPostList(1);
      expect(postList[0]).to.eq(0)

    })
  });

  describe("Reward and fees", () => {
    it("should send registration bonus", async () => {
      const { nFTinLogic, lens, owner, user2, tinToken, address721 } =
        await loadFixture(deployNFTinLogic);
      const balance = await tinToken.balanceOf(user2.address);
      const bonus = await nFTinLogic.registrationBonus();
      const ownerBalance = await tinToken.balanceOf(owner.address);
      const totalSupply = await tinToken.totalSupply();

      const balance1 = await tinToken.balanceOf(user2.address);
      const newOwnerBalance = totalSupply.sub(balance.add(balance1));
      expect(balance).to.eq(bonus);
      expect(ownerBalance).to.eq(newOwnerBalance);
    });

    it("should get post fee", async () => {
      const { nFTinLogic, lens, owner, user2, address721, tinToken } =
        await loadFixture(deployNFTinLogic);

      const bonus = await nFTinLogic.registrationBonus();
      await nFTinLogic.connect(user2).setPost(postStruct, address721, 1, 0);

      const fee = await hre.ethers.utils
        .parseEther("1")
        .div(await nFTinLogic.postPriceScaler());
      const newBalance = await bonus.sub(fee);

      const ownerBalance = await tinToken.balanceOf(owner.address);
      const totalSupply = await tinToken.totalSupply();
      const balance = await tinToken.balanceOf(user2.address);
      const balance1 = await tinToken.balanceOf(user2.address);
      const newOwnerBalance = totalSupply.sub(balance.add(balance1));
      expect(balance).to.eq(newBalance);
      //  expect(ownerBalance).to.eq(newOwnerBalance);
    });

    it("should get comment fee", async () => {
      const { nFTinLogic, lens, owner, user2, user3, address721, tinToken } =
        await loadFixture(deployNFTinLogic);
      await nFTinLogic.connect(user2).setPost(postStruct, address721, 1, 0);

      const bonus = await nFTinLogic.registrationBonus();
      const fee = await hre.ethers.utils
        .parseEther("1")
        .div(await nFTinLogic.activityPriceScaler());
      const newBalance = await bonus.sub(fee);

      const postCount = await lens.connect(user2).getPubCount(1);
      await nFTinLogic
        .connect(user3)
        .setComment([
          2,
          commentURI,
          1,
          postCount.toString(),
          [],
          freeCollectModule,
          bytesTrue,
          ZERO_ADDRESS,
          [],
        ]);
      const balance = await tinToken.balanceOf(user3.address);
      const balance1 = await tinToken.balanceOf(user2.address);
      const ownerBalance = await tinToken.balanceOf(owner.address);
      const totalSupply = await tinToken.totalSupply();
      const newOwnerBalance = totalSupply.sub(balance.add(balance1));
      expect(balance).to.eq(newBalance);
      expect(ownerBalance).to.eq(newOwnerBalance);
    });

    it("should get mirror fee", async () => {
      const { nFTinLogic, lens, owner, user2, user3, address721, tinToken } =
        await loadFixture(deployNFTinLogic);
      await nFTinLogic.connect(user2).setPost(postStruct, address721, 1, 0);
      const bonus = await nFTinLogic.registrationBonus();
      const fee = await hre.ethers.utils
        .parseEther("1")
        .div(await nFTinLogic.activityPriceScaler());
      const newBalance = await bonus.sub(fee);

      const postCount = await lens.connect(user2).getPubCount(1);
      await nFTinLogic
        .connect(user3)
        .setMirror([2, 1, postCount.toString(), [], ZERO_ADDRESS, []]);
      const balance = await tinToken.balanceOf(user3.address);
      const balance1 = await tinToken.balanceOf(user2.address);
      const ownerBalance = await tinToken.balanceOf(owner.address);
      const totalSupply = await tinToken.totalSupply();
      const newOwnerBalance = totalSupply.sub(balance.add(balance1));

      expect(balance).to.eq(newBalance);
      expect(ownerBalance).to.eq(newOwnerBalance);
    });

    it("should get like fee", async () => {
      const { nFTinLogic, lens, owner, user2, user3, address721, tinToken } =
        await loadFixture(deployNFTinLogic);

      await lens.connect(user3).setDispatcher(2, nFTinLogic.address);
      await nFTinLogic.connect(user2).setPost(postStruct, address721, 1, 0);
      const bonus = await nFTinLogic.registrationBonus();
      const fee = await hre.ethers.utils
        .parseEther("1")
        .div(await nFTinLogic.activityPriceScaler());
      const newBalance = await bonus.sub(fee);

      const postCount = await lens.connect(user2).getPubCount(1);
      await nFTinLogic.connect(user3).setLike(2, 1, postCount.toString());
      const balance = await tinToken.balanceOf(user3.address);
      const balance1 = await tinToken.balanceOf(user2.address);
      const ownerBalance = await tinToken.balanceOf(owner.address);
      const totalSupply = await tinToken.totalSupply();
      const newOwnerBalance = totalSupply.sub(balance.add(balance1));

      expect(balance).to.eq(newBalance);
      expect(ownerBalance).to.eq(newOwnerBalance);
    });

    it("should get rewards", async () => {
      const { nFTinLogic, lens, owner, user2, user3, address721, tinToken } =
        await loadFixture(deployNFTinLogic);

      await lens.connect(user3).setDispatcher(2, nFTinLogic.address);
      await nFTinLogic.connect(user2).setPost(postStruct, address721, 1, 0);
      await nFTinLogic.connect(user3).onboardNewProfile(2);

      const bonus = await nFTinLogic.registrationBonus();
      const fee = await hre.ethers.utils
        .parseEther("1")
        .div(await nFTinLogic.postPriceScaler());
      const rewards = await hre.ethers.utils
        .parseEther("2")
        .div(await nFTinLogic.rewardsScaler());
      const newBalance = await bonus.sub(fee).add(rewards);
      const postCount = await lens.connect(user2).getPubCount(1);
      await nFTinLogic
        .connect(user3)
        .setMirror([2, 1, postCount.toString(), [], ZERO_ADDRESS, []]);
      await nFTinLogic
        .connect(user3)
        .setComment([
          2,
          commentURI,
          1,
          postCount.toString(),
          [],
          freeCollectModule,
          bytesTrue,
          ZERO_ADDRESS,
          [],
        ]);
      await nFTinLogic.connect(user2).getReward(1);
      const balance = await tinToken.balanceOf(user2.address);
      const value = await nFTinLogic.rewardsValue(1, 0);
      const balance1 = await tinToken.balanceOf(user3.address);
      const ownerBalance = await tinToken.balanceOf(owner.address);
      const totalSupply = await tinToken.totalSupply();
      const newOwnerBalance = totalSupply.sub(balance.add(balance1));

      expect(value).to.eq(rewards);
      expect(balance).to.eq(newBalance);
      expect(ownerBalance).to.eq(newOwnerBalance);
    });
  });
  describe("Limits and timelocks", () => {
    it("should be reverted after 24 activities", async () => {
      const { nFTinLogic, lens, owner, user2, user3, address721 } =
        await loadFixture(deployNFTinLogic);

      await lens.connect(user3).setDispatcher(2, nFTinLogic.address);
      await nFTinLogic.connect(user2).setPost(postStruct, address721, 1, 0);
      await nFTinLogic.connect(user3).onboardNewProfile(2);

      const bonus = await nFTinLogic.registrationBonus();
      const fee = await hre.ethers.utils
        .parseEther("1")
        .div(await nFTinLogic.activityPriceScaler());
      const postCount = await lens.connect(user2).getPubCount(1);
      const newBalance = await bonus.sub(fee);

      for (let i = 0; i <= 24; i++) {
        await nFTinLogic
          .connect(user3)
          .setComment([
            2,
            commentURI,
            1,
            postCount.toString(),
            [],
            freeCollectModule,
            bytesTrue,
            ZERO_ADDRESS,
            [],
          ]);
      }

      await expect(
        nFTinLogic
          .connect(user3)
          .setComment([
            2,
            commentURI,
            1,
            postCount.toString(),
            [],
            freeCollectModule,
            bytesTrue,
            ZERO_ADDRESS,
            [],
          ])
      ).to.be.rejectedWith("No more activities");
    });

    it("should not be reverted after 24 activities after 24 hours", async () => {
      const { nFTinLogic, lens, owner, user2, user3, address721 } =
        await loadFixture(deployNFTinLogic);
      await nFTinLogic.connect(user2).setPost(postStruct, address721, 1, 0);

      const bonus = await nFTinLogic.registrationBonus();
      const fee = await hre.ethers.utils
        .parseEther("1")
        .div(await nFTinLogic.activityPriceScaler());
      const postCount = await lens.connect(user2).getPubCount(1);
      const newBalance = await bonus.sub(fee);

      for (let i = 0; i <= 24; i++) {
        const tx = await nFTinLogic
          .connect(user3)
          .setComment([
            2,
            commentURI,
            1,
            postCount.toString(),
            [],
            freeCollectModule,
            bytesTrue,
            ZERO_ADDRESS,
            [],
          ]);
        await tx.wait();
      }
      // const now = await time.latest();
      // await time.increaseTo(now + 60 * 60 * 24);
      await network.provider.send("evm_increaseTime", [60 * 60 * 24]);
      await expect(
        nFTinLogic
          .connect(user3)
          .setComment([
            2,
            commentURI,
            1,
            postCount.toString(),
            [],
            freeCollectModule,
            bytesTrue,
            ZERO_ADDRESS,
            [],
          ])
      ).not.to.be.rejected;
    });

    it("should get 0 rewards after transfer nft", async () => {
      const {
        nFTinLogic,
        lens,
        owner,
        user2,
        user3,
        test721,
        address721,
        tinToken,
      } = await loadFixture(deployNFTinLogic);
      await nFTinLogic.connect(user2).setPost(postStruct, address721, 1, 0);
      const bonus = await nFTinLogic.registrationBonus();
      const fee = await hre.ethers.utils
        .parseEther("1")
        .div(await nFTinLogic.postPriceScaler());
      const rewards = 0;
      const newBalance = await bonus.sub(fee).add(rewards);
      const postCount = await lens.connect(user2).getPubCount(1);
      await nFTinLogic
        .connect(user3)
        .setMirror([2, 1, postCount.toString(), [], ZERO_ADDRESS, []]);
      await nFTinLogic
        .connect(user3)
        .setComment([
          2,
          commentURI,
          1,
          postCount.toString(),
          [],
          freeCollectModule,
          bytesTrue,
          ZERO_ADDRESS,
          [],
        ]);
      const tx = await test721
        .connect(user2)
        .transferFrom(user2.address, owner.address, 1);
      await tx.wait();
      await nFTinLogic.connect(user2).getReward(1);
      const balance = await tinToken.balanceOf(user2.address);
      const balance1 = await tinToken.balanceOf(user3.address);
      const ownerBalance = await tinToken.balanceOf(owner.address);
      const totalSupply = await tinToken.totalSupply();
      const newOwnerBalance = totalSupply.sub(balance.add(balance1));
      const rate = await nFTinLogic.getRating(1);
      expect(rate).to.eq(0);
      expect(balance).to.eq(newBalance);
      expect(ownerBalance).to.eq(newOwnerBalance);
    });
  });
});
