// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import {LensInteractions} from "./LensInteractions.sol";
import {DataTypes} from "./DataTypes.sol";
import {INFTinLogic} from "./INFTinLogic.sol";

contract NFTinLogic is LensInteractions, INFTinLogic{
    function onboardNewProfile(uint256 _profileId) external {
        profiles[msg.sender] = _profileId;
        emit profileOnboarded(msg.sender, _profileId);
    }

    function setPost(DataTypes.PostData calldata vars)
        external
        profileOwner(vars.profileId)
    {
        (bool success, uint256 _postId) = post(vars);
        require(success, "Transaction failed");
        postList[vars.profileId].push(_postId);
        emit posted(msg.sender, vars);
    }

    function setComment(DataTypes.CommentData calldata vars)
        external
        profileOwner(vars.profileId)
        pubExist(vars.profileIdPointed, vars.pubIdPointed)
        activityCount(vars.profileId)
    {
        (bool success, uint256 _commentId) = comment(vars);
        require(success, "transaction failed");

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
        (bool success, uint256 _mirrorId) = mirror(vars);
        require(success, "transaction failed");

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
    ) external profileOwner(_profileId) pubExist(_profileIdPointed, _postId) activityCount(_profileId){
        require(
            !likes[_profileIdPointed][_postId][_profileId],
            "Like setted yet"
        );
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

}
