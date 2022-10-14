// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import {LensInteractions} from "./LensInteractions.sol";
import {DataTypes} from "./DataTypes.sol";

contract NFTinLogic is LensInteractions {

    function onboardNewProfile(uint256 _profileId) external {
        (bool success, DataTypes.ProfileStruct memory _profile) = getProfile(_profileId);
        require(success, "Transaction failed");
        profiles[_profileId].profileOwner = msg.sender;             //??
        profiles[_profileId].profile = _profile;
        isOnboarded[msg.sender] = true;
    }

    function setPost(DataTypes.PostData calldata vars) external returns(uint256){
        (bool success, uint256 _postId) = post(vars);
        require(success, "Transaction failed");
        //profiles[vars.profileId].posts[_postId].post = getPub(vars.profileId, _postId);

        return _postId;
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
