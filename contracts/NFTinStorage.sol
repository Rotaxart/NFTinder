// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import {DataTypes} from "./DataTypes.sol";

contract NFTinStorage {
    constructor() {}
uint256 public testVar;  //dev

    uint256 public registrationBonus = 10 ether;
    uint256 public postPriceScaler = 10000;
    uint256 public activityPriceScaler = 100;
    uint256 public dailyRewardLimit = 100 ether;
    uint256 public rewardsScaler = 100;
    address public lensAddress;
    address public tinToken;
    address public owner;
    
    mapping(uint256 => uint256) public rating; //???
    mapping(address => uint256) public profiles; //wallet => profile
    mapping(address => bool) public isOnboarded;
    mapping(uint256 => uint256[]) public postList; //profile => [postId]
    mapping(uint256 => uint256[]) public collections; //profile => posts
    mapping(uint256 => mapping(uint256 => Comments[])) public comments; //profile => post => comments[]
    mapping(uint256 => Mirrors[]) public mirrors; //profile => mirrors
    mapping(uint256 => mapping(uint256 => mapping(uint256 => bool)))
        public likes; //profile => post => profile => like
    mapping(uint256 => mapping(uint256 => uint256)) public likesCount; //profile => pub => count
    mapping(uint256 => mapping(uint256 => uint256)) public pubRating; //profile => pub => rating
    mapping(uint256 => uint256[]) public activityPerDay; //profile => timestamp
    mapping(uint256 => uint256) public rewardBalances; //profile => avalable rewards    
    mapping(uint256 => uint256[]) public rewardsTime;   //profile => timestamp[]
    mapping(uint256 => uint256[]) public rewardsValue; //profile => value[]
    mapping(uint256 => uint256) public lastRewardRating;
    mapping(uint256 => NFTstruct[]) public nfts;
    mapping(uint256 => mapping(uint256 => bool)) public postEnable; //profile => post => on/off

    struct NFTstruct{
        address nftAddress;
        uint256 tokenId;
        uint256 postId;
        nftType nftType;
    }

    struct Mirrors {
        uint256 mirrorId;
        uint256 profileIdPointed;
        uint256 pubIdPointed;
    }

    struct Comments {
        uint256 profileId;
        uint256 profileIdPointed; //??
        uint256 pubId;
        uint256 pubIdPointed;
    }

    enum nftType{
        ERC721, ERC1155
    }

    modifier profileOwner(uint256 _profileId) {
        require(profiles[msg.sender] == _profileId, "Not an owner");
        _;
    }

    modifier pubExist(uint256 _profileIdPointed, uint256 _pubIdPointed) {
        uint256[] memory _postList = postList[_profileIdPointed];
        bool _pubExist;
        for (uint256 i = 0; i < _postList.length; i++) {
            // need gas op
            if (_postList[i] == _pubIdPointed) _pubExist = true;
        }
        require(_pubExist, "Pub doesn`t exist");
        _;
    }

    modifier activityCount(uint256 _profileId) {
        uint256 _activites;
        if (activityPerDay[_profileId].length > 24) {
            for (
                uint256 j = activityPerDay[_profileId].length - 25;
                j < activityPerDay[_profileId].length;
                j++
            ) {
                if (activityPerDay[_profileId][j] < block.timestamp - 1 days) {
                    _activites++;
                }
            }

            require(_activites > 0, "No more activities");
        }
        _;
    }


    event profileOnboarded(
        address indexed _profileAddress,
        uint256 indexed _profileId
    );

    event posted(
        address indexed _profileAddress,
        DataTypes.PostData indexed _data
    );

    event commented(
        address indexed _profileAddress,
        DataTypes.CommentData indexed _data
    );

    event mirrored(
        address indexed _profileAddress,
        DataTypes.MirrorData indexed _data
    );

    event liked(
        address indexed _profileAddress,
        uint256 indexed _profileIdPointed,
        uint256 indexed _pubIdPointed
    );
}

// todo:
// control mechanism
// owner, profile owner

//profile rating = 100 // 80
//last reward rating = 80 //60
//posts rating 10, 20, 30, 40 // 10, 30, 40