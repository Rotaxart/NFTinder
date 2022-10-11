// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import {DataTypes} from "./DataTypes.sol";
import {ILensInteractions} from "./ILensInteractions.sol";
import {NFTin} from "./NFTin.sol";

contract LensInteractions is NFTin{

    constructor(address _lensHub){
        lensHub = ILensInteractions(_lensHub);
    }

    ILensInteractions lensHub;

    function setLensHubAddress(address _lensHub) public{
        lensHub = ILensInteractions(_lensHub);
    }

    function setDefaultProfileWithSig(DataTypes.SetDefaultProfileWithSigData calldata vars) external{
        lensHub.setDefaultProfileWithSig(vars);
    }

    function setFollowModule(uint256 profileId, address followModule, bytes calldata followModuleData) external{
        lensHub.setFollowModule(profileId, followModule, followModuleData);
    }

    function setFollowModuleWithSig(DataTypes.SetFollowModuleWithSigData calldata vars) external{
        lensHub.setFollowModuleWithSig(vars);
    }

    function setDispatcher(uint256 profileId, address dispatcher) external{
        lensHub.setDispatcher(profileId, dispatcher);
    }

    function setDispatcherWithSig(DataTypes.SetDispatcherWithSigData calldata vars) external{
        lensHub.setDispatcherWithSig(vars);
    }

    function setProfileImageURI(uint256 profileId, string calldata imageURI) external{
        lensHub.setProfileImageURI(profileId, imageURI);
    }

    function setProfileImageURIWithSig(DataTypes.SetProfileImageURIWithSigData calldata vars)
        external{
            lensHub.setProfileImageURIWithSig(vars);
        }

    function post(DataTypes.PostData calldata vars) external{
        lensHub.post(vars);
    }

    function postWithSig(DataTypes.PostWithSigData calldata vars) external{
        lensHub.postWithSig(vars);

    }

    function comment(DataTypes.CommentData calldata vars) external{
        lensHub.comment(vars);
    }

    function commentWithSig(DataTypes.CommentWithSigData calldata vars) external{
        lensHub.commentWithSig(vars);
    }

    function mirror(DataTypes.MirrorData calldata vars) external{
        lensHub.mirror(vars);
    }

    function mirrorWithSig(DataTypes.MirrorWithSigData calldata vars) external{
        lensHub.mirrorWithSig(vars);
    }

    function setFollowNFTURI(uint256 profileId, string calldata followNFTURI) external{
        lensHub.setFollowNFTURI(profileId, followNFTURI);
    }

    function follow(uint256[] calldata profileIds, bytes[] calldata datas) external{
        lensHub.follow(profileIds, datas);
    }

    function followWithSig(DataTypes.FollowWithSigData calldata vars)
        external{
            lensHub.followWithSig(vars);
        }

    function collect(uint256 profileId, uint256 pubId, bytes calldata data) external{
        lensHub.collect(profileId, pubId, data);
    }

    function collectWithSig(DataTypes.CollectWithSigData calldata vars) external{
        lensHub.collectWithSig(vars);
    }

    function burn(uint256 profileId) external{
        lensHub.burn(profileId);
    }

}