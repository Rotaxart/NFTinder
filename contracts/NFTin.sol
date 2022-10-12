// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import {DataTypes} from "./DataTypes.sol";

contract NFTin{

    constructor(){}

    mapping (address => bool) public isOnboarded;
    mapping (address => bool) public withProfile;
    mapping (uint256 => uint) public rating;
    mapping (uint256 => ProfileInfo) public profiles;

    struct ProfileInfo{
        DataTypes.ProfileStruct profile;
        Posts[] posts;
    }

    struct Posts{
        DataTypes.PublicationStruct post;
        uint256 likes;
        uint256 rating;
    }

    function userInfo(address _user) external view returns(bool, bool){
        return (isOnboarded[_user], withProfile[_user]);
    }

    function _setRating(uint256 _user, uint _newRating) external {  //external by develop
        rating[_user] = _newRating;
        profiles[_user].profileRating = _newRating;
    }

    function _onboarding(address _user) external{ //external by develop
        isOnboarded[_user] = true;
    }

    function _setProfile(ProfileInfo calldata _profile) external{ //external by develop
        require(withProfile[_profile.profileAddress], "User without lens profile");
        profiles[_profile.profileId] = _profile;
    }

    function _setLike(uint _postNum, uint256 _profile) external { //external by develop
        profiles[_profile].posts[_postNum].likes++;
    }
}