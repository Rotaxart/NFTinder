// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import {LensInteractions} from "./LensInteractions.sol";
import {DataTypes} from "./DataTypes.sol";

contract Onboarding is LensInteractions{
    
    function onboardNewProfile(uint256 _profileId) external{
        DataTypes.ProfileStruct memory _profile = getProfile(_profileId);
        


    }
}