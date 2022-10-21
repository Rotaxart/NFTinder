// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import {LensInteractions} from "./LensInteractions.sol";
import {DataTypes} from "./DataTypes.sol";
import {INFTinLogic} from "./INFTinLogic.sol";
import {TinToken} from "./TinToken.sol";

contract NFTinLogic is LensInteractions, TinToken, INFTinLogic {
    function onboardNewProfile(uint256 _profileId) external {
        profiles[msg.sender] = _profileId;
        balances[msg.sender] += 10 ether;
        balances[thisOwner] -= 10 ether;
        emit profileOnboarded(msg.sender, _profileId);
    }

    function setPost(DataTypes.PostData calldata vars)
        external
        profileOwner(vars.profileId)
    {
        uint256 _cost = getPostCost(vars.profileId);
        require(balances[msg.sender] >= _cost, "not enough token");
        (bool success, uint256 _postId) = post(vars);
        require(success, "Transaction failed");
        balances[msg.sender] -= _cost;
        balances[thisOwner] += _cost;
        postList[vars.profileId].push(_postId);
        emit posted(msg.sender, vars);
    }

    function setComment(DataTypes.CommentData calldata vars)
        external
        profileOwner(vars.profileId)
        pubExist(vars.profileIdPointed, vars.pubIdPointed)
        activityCount(vars.profileId)
    {
        uint256 _cost = getActivityCost(
            vars.profileIdPointed,
            vars.pubIdPointed
        );
          require(balances[msg.sender] >= _cost, "not enough token");
        (bool success, uint256 _commentId) = comment(vars);
        require(success, "transaction failed");
        balances[msg.sender] -= _cost;
        balances[thisOwner] += _cost;

        Comments memory _comment;
        _comment.profileId = vars.profileId;
        _comment.profileIdPointed = vars.profileIdPointed;
        _comment.pubId = _commentId;
        _comment.pubIdPointed = vars.pubIdPointed;

        comments[vars.profileIdPointed][vars.pubIdPointed].push(_comment);
        addRating(vars.profileIdPointed, vars.pubIdPointed);
        activityPerDay[vars.profileId].push(block.timestamp);
        emit commented(msg.sender, vars);
    }

    function setMirror(DataTypes.MirrorData calldata vars)
        external
        profileOwner(vars.profileId)
        pubExist(vars.profileIdPointed, vars.pubIdPointed)
        activityCount(vars.profileId)
    {
         uint256 _cost = getActivityCost(
            vars.profileIdPointed,
            vars.pubIdPointed
        );
          require(balances[msg.sender] >= _cost, "not enough token");
        (bool success, uint256 _mirrorId) = mirror(vars);
        require(success, "transaction failed");

        balances[msg.sender] -= _cost;
        balances[thisOwner] += _cost;
        Mirrors memory _mirror;
        _mirror.profileIdPointed = vars.profileIdPointed;
        _mirror.pubIdPointed = vars.pubIdPointed;
        _mirror.mirrorId = _mirrorId;
        mirrors[vars.profileId].push(_mirror);

        addRating(vars.profileIdPointed, vars.pubIdPointed);
        activityPerDay[vars.profileId].push(block.timestamp);
        emit mirrored(msg.sender, vars);
    }

    function setLike(
        uint256 _profileId,
        uint256 _profileIdPointed,
        uint256 _postId
    )
        external
        profileOwner(_profileId)
        pubExist(_profileIdPointed, _postId)
        activityCount(_profileId)
    {
         uint256 _cost = getActivityCost(
            _profileIdPointed,
            _postId
        );
          require(balances[msg.sender] >= _cost, "not enough token");
        require(
            !likes[_profileIdPointed][_postId][_profileId],
            "Like setted yet"
        );
                balances[msg.sender] -= _cost;
        balances[thisOwner] += _cost;
        likes[_profileIdPointed][_postId][_profileId] = true;
        likesCount[_profileIdPointed][_postId]++;
        addRating(_profileIdPointed, _postId);
        activityPerDay[_profileId].push(block.timestamp);
        emit liked(msg.sender, _profileIdPointed, _postId);
    }

    function getPostList(uint256 _profileId)
        external
        view
        returns (uint256[] memory)
    {
        return postList[_profileId];
    }

    function getMirrors(uint256 _profileId)
        external
        view
        returns (Mirrors[] memory)
    {
        return mirrors[_profileId];
    }

    // function getPost(uint256 _profileId, uint256 _pubId) public view returns (Posts calldata){
    //     return posts[_profileId][_pubId];
    // }

    function getComments(uint256 _profileId, uint256 _postId)
        external
        view
        returns (Comments[] memory)
    {
        return comments[_profileId][_postId];
    }

    function getProfile(address _profileAddress)
        external
        view
        returns (uint256)
    {
        return profiles[_profileAddress];
    }

    function addRating(uint256 _profile, uint256 _pubId) internal {
        rating[_profile]++;
        pubRating[_profile][_pubId]++;
    }

    function registrationBonus(address _newUser) public {
        // ??
        balances[_newUser] += 10 ether;
        balances[thisOwner] -= 10 ether;
    }

    function getReward(uint256 _profileId) public {
        uint256 rewardsAlready;
        uint256 rewardAvailable = getRewardValue(_profileId);
        require(rewardAvailable > 0, "Not available reards");
        for (uint256 i = 0; i < rewardsTime[_profileId].length; i++) {
            if (rewardsTime[_profileId][i] > block.timestamp - 1 days) {
                rewardsAlready += rewardsValue[_profileId][i];
            }
        }
        require(rewardsAlready < 100 ether, "No more rewards today");
        if (rewardsAlready + rewardAvailable >= 100) {
            balances[msg.sender] += 100 ether - rewardsAlready;
        } else {
            balances[msg.sender] += rewardBalances[_profileId];
        }

        lastRewardRating[_profileId] = rating[_profileId];
    }

    function getRewardValue(uint256 _profileId) public view returns (uint256) {
        uint256 _rating = rating[_profileId] - lastRewardRating[_profileId];
        return (_rating * 1 ether) / 100;
    }

    function getPostCost(uint256 _profileId) internal view returns (uint256) {
        if (rating[_profileId] != 0) {
            return (rating[_profileId] * 1 ether) / 10000;
        } else {
            return 1 ether / 10000;
        }
    }

    function getActivityCost(uint256 _profileIdPointed, uint256 _pubIdPointed)
        internal
        view
        returns (uint256)
    {
        return (1 ether + pubRating[_profileIdPointed][_pubIdPointed]) / 100;
    }
}
// Стоимость:
//  цена размещения NFT = 1 токен * UR /10000,
//  цена 1 актиности = (1 токен + r) / 100
//  К = 0.0001 * UR,
//  где K - коэффициент пользователя
