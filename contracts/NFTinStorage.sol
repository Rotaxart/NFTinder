// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import {DataTypes} from "./DataTypes.sol";

contract NFTinStorage{

    constructor(){}

    mapping (address => bool) public isOnboarded;
    mapping (address => bool) public withProfile;
    mapping (uint256 => uint) public rating;       //???
    mapping (uint256 => ProfileInfo) public profiles;

    struct ProfileInfo{
        address profileOwner;
        uint256 profileRating;
        DataTypes.ProfileStruct profile;
        Posts[] posts;
    }

    struct Posts{
        DataTypes.PublicationStruct post;
        DataTypes.PubType pubType;
    }

    modifier profileOwner(uint256 _profileId){
        require(msg.sender == profiles[_profileId].profileOwner);
        _;
    }
}