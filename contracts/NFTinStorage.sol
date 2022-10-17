// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import {DataTypes} from "./DataTypes.sol";

contract NFTinStorage{

    constructor(){}

    address signer;

    mapping (address => bool) public isOnboarded;
    mapping (address => bool) public withProfile;
    mapping (uint256 => uint256) public rating;       //???
    // mapping (uint256 => ProfileInfo) public profiles;
    // mapping (uint256 => mapping(uint256 => Posts)) public posts;

    mapping (address => uint256) public profiles; //wallet => profile
    mapping (uint256 => Posts[]) public posts; // profile => post
    mapping (uint256 => uint256[]) public postList; //profile => [postId]
    mapping (uint256 => uint256[]) public collections; //profile => posts
    mapping (uint256 => uint256[]) public comments; //???
    mapping (uint256 => Mirrors[]) public mirrors; //profile => mirrors

    // struct ProfileInfo{
    //     address profileOwner;
    //     uint256 profileRating;
    //     DataTypes.ProfileStruct profile;
    //     Posts[] posts;
    // }
    struct Mirrors{
        uint256 profileIdPointed;
        uint256 pubIdPointed;
    }
    struct Comments{
        uint256 profileId;
        uint256 profileIdPointed; //??
        uint256 pubId;
        uint256 pubIdPointed;
    }

    struct Posts{
        uint256 postRating;  //???
        uint256 commentsCount;
        uint256 likesCount;
        uint256 mirrorsCount;
        Comments[] comments;
        mapping (uint256 => bool) likes; //profileId
        // mapping (uint256 => uint256[]) comments; //profile => comments
        mapping (uint256 => uint256) mirrors; // profile => mirror
    }

    modifier profileOwner(uint256 _profileId){
        require(profiles[msg.sender] == _profileId, "Not an owner");
        _;
    }
}

// todo:
    // remove profile storage
    // write main funcs
    // write get functions
    // write tests
    // remove not needed functions
    // rating logic
    // revards logic
    // control mechanism
    // owner, profile owner