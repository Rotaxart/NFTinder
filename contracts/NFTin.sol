// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

contract NFTin{

    constructor(){}

    mapping (address => bool) isOnboarded;
    mapping (address => bool) withProfile;
    mapping (address => uint) rating;

    function userInfo(address _user) external view returns(bool, bool, uint){
        return (isOnboarded[_user], withProfile[_user], rating[_user]);
    }

    function setRating(address _user, uint _newRating) internal {
        rating[_user] = _newRating;
    }

    function onboarding(address _user) internal{
        isOnboarded[_user] = true;
    }
}