// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import {LensInteractions} from "./LensInteractions.sol";
import {DataTypes} from "./DataTypes.sol";

contract NFTinLogic is LensInteractions {
    function onboardNewProfile(uint256 _profileId) external {
        (bool success, DataTypes.ProfileStruct memory _profile) = getProfile(
            _profileId
        );
        require(success, "Transaction failed");
        profiles[msg.sender] = _profileId;
        // profiles[_profileId].profile = _profile;
        // isOnboarded[msg.sender] = true;
    }

    function setPost(DataTypes.PostData calldata vars)
        external
        profileOwner(vars.profileId)
        returns (uint256)
    {
        (bool success, uint256 _postId) = post(vars);
        require(success && _postId != 0, "Transaction failed");

        postList[vars.profileId].push(_postId);

        return _postId;
    }

    function setComment(DataTypes.CommentData calldata vars)
        external
        profileOwner(vars.profileId)
    {
        bool pubExist;
        for (uint256 i = 0; i < postList[vars.profileIdPointed].length; i++) {
            // need gas op
            if (postList[vars.profileIdPointed][i] == vars.pubIdPointed)
                pubExist = true;
        }
        require(pubExist, "Pub doesn`t exist");
        (bool success, uint256 _commentId) = comment(vars);
        require(success && _commentId != 0, "transaction failed");

        Comments memory _comment;
        _comment.profileId = vars.profileId;
        _comment.profileIdPointed = vars.profileIdPointed;
        _comment.pubId = _commentId;
        _comment.pubIdPointed = vars.pubIdPointed;

        posts[vars.profileIdPointed][vars.pubIdPointed]
            .comments
            .push(_comment);

        posts[vars.profileIdPointed][vars.pubIdPointed].commentsCount++;

        addRating(vars.profileIdPointed);
    }

    function setMirror(DataTypes.MirrorData calldata vars)
        external
        profileOwner(vars.profileId)
    {
        bool pubExist;
        for (uint256 i = 0; i < postList[vars.profileIdPointed].length; i++) {
            // need gas op
            if (postList[vars.profileIdPointed][i] == vars.pubIdPointed)
                pubExist = true;
        }
        require(pubExist, "Pub doesn`t exist");
        (bool success, uint256 _mirrorId) = mirror(vars);
        require(success && _mirrorId != 0, "transaction failed");

        posts[vars.profileIdPointed][vars.pubIdPointed].mirrors[
            vars.profileId
        ] = _mirrorId;

        posts[vars.profileIdPointed][vars.pubIdPointed].mirrorsCount++;

        Mirrors memory _mirror;
        _mirror.profileIdPointed = vars.profileIdPointed;
        _mirror.pubIdPointed = vars.pubIdPointed;
        mirrors[vars.profileId].push(_mirror);

        addRating(vars.profileIdPointed);
    }

    function setLike(
        uint256 _profileId,
        uint256 _profileIdPointed,
        uint256 _postId
    ) external profileOwner(_profileId) {
        require(
            posts[_profileIdPointed][_postId].likes[_profileId],
            "Like setted yet"
        );
        posts[_profileIdPointed][_postId].likes[_profileId] = true;
        posts[_profileIdPointed][_postId].likesCount++;
        addRating(_profileIdPointed);
    }

    function getPosts(uint256 _profileId) external view returns(uint256[] memory){
        return postList[_profileId];
    }

    function getComments(uint256 _profileId, uint256 _postId) external view returns(Comments[] memory){
        return posts[_profileId][_postId].comments;
    }

    function getProfile(address _profileAddress) external view returns(uint256){
        return profiles[_profileAddress];
    }

    function addRating(uint256 _profile) internal {
        rating[_profile]++;
    }

    // function importPub(uint256 _profileId, uint256 _pubId) external {         //remove ???
    //     profiles[_profileId].posts[_pubId].post = getPub(_profileId, _pubId);
    //     profiles[_profileId].posts[_pubId].pubType = getPubType(
    //         _profileId,
    //         _pubId
    //     );
    // }

    // function userInfo(address _user) external view returns (bool, bool) {  //remove ???
    //     return (isOnboarded[_user], withProfile[_user]);
    // }

    // function _setRating(uint256 _profile, uint256 _newRating) external {
    //     //external by develop
    //     rating[_profile] = _newRating;
    //     profiles[_profile].profileRating = _newRating;
    // }

    // function _setProfile(ProfileInfo calldata _profile, uint256 _id) external {
    //     //external by develop
    //     profiles[_id] = _profile;
    // }

    // function _setLike(uint256 _postNum, uint256 _profile) external {     /// ???
    //     //external by develop
    //     // profiles[_profile].posts[_postNum].likes++;
    // }
}
