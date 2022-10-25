// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import {LensInteractions} from "./LensInteractions.sol";
import {DataTypes} from "./DataTypes.sol";
import {INFTinLogic} from "./INFTinLogic.sol";
import {TinToken} from "./TinToken.sol";

contract NFTinLogic is LensInteractions, TinToken, INFTinLogic {
    function onboardNewProfile(uint256 _profileId) external {
        require(ownerOf(_profileId) == msg.sender, "not an owner");
        profiles[msg.sender] = _profileId;
        _registrationBonus(msg.sender);
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
        uint256 _cost = getActivityCost(_profileIdPointed, _postId);
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

    function _registrationBonus(address _newUser) internal {
        // ??
        balances[_newUser] += registrationBonus;
        balances[thisOwner] -= registrationBonus;
    }

    function getReward(uint256 _profileId) profileOwner(_profileId) public {
        uint256 rewardsAlready;
        uint256 rewardAvailable = getRewardValue(_profileId);
        require(rewardAvailable > 0, "Not available reards");
        for (uint256 i = 0; i < rewardsTime[_profileId].length; i++) {
            if (rewardsTime[_profileId][i] > block.timestamp - 1 days) {
                rewardsAlready += rewardsValue[_profileId][i];
            }
        }
        require(rewardsAlready < dailyRewardLimit, "No more rewards today");
        if (rewardsAlready + rewardAvailable >= 100 ether) {
            balances[msg.sender] += dailyRewardLimit - rewardsAlready;
            balances[thisOwner] -= dailyRewardLimit - rewardsAlready;
            rewardsValue[_profileId].push(dailyRewardLimit - rewardsAlready);
        } else {
            balances[msg.sender] += rewardAvailable;
             balances[thisOwner] -= rewardAvailable;
            rewardsValue[_profileId].push(rewardAvailable);
        }
        rewardsTime[_profileId].push(block.timestamp);
        
        lastRewardRating[_profileId] = rating[_profileId];
    }

    function getRewardValue(uint256 _profileId) internal view returns (uint256) {
        uint256 _rating = rating[_profileId] - lastRewardRating[_profileId];
        return (_rating * 1 ether) / rewardsScaler;
    }

    function getPostCost(uint256 _profileId) internal view returns (uint256) {
        if (rating[_profileId] != 0) {
            return (rating[_profileId] * 1 ether) / postPriceScaler;
        } else {
            return 1 ether / postPriceScaler;
        }
    }

    function getActivityCost(uint256 _profileIdPointed, uint256 _pubIdPointed)
        internal
        view
        returns (uint256)
    {
        return (1 ether + pubRating[_profileIdPointed][_pubIdPointed]) / activityPriceScaler;
    }
}

//     Пользователь:
//  r = A1 + A2 + … + An
//  где r - рейтинг NFT, А - активность (коммент, лайк)

//  UR = r1 + r2 + … + rn,
//  где UR - рейтинг пользователя, rn - рейтинг каждой NFT

//  К = 0.0001 * UR,
//  где K - коэффициент пользователя

// Ограничения:
//  В сутки:
//  - получить не более 100 токенов
//  - сделать не более 24 активностей
//  В неделю:
//  - не больше 1 активности к одной и той же NFT

// Стоимость:
//  цена размещения NFT = 1 токен * K
//  цена 1 актиности = (1 токен + r) / 100

// Награды:
//  забрать токены = 0.01 * r