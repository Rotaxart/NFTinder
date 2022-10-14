// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import {DataTypes} from "./DataTypes.sol";

interface ILensInteractions {
    function setDefaultProfileWithSig(DataTypes.SetDefaultProfileWithSigData calldata vars)
        external;

    function setFollowModule(uint256 profileId, address followModule, bytes calldata followModuleData) external;

    function setFollowModuleWithSig(DataTypes.SetFollowModuleWithSigData calldata vars) external;

    function setDispatcher(uint256 profileId, address dispatcher) external;

    function setDispatcherWithSig(DataTypes.SetDispatcherWithSigData calldata vars) external;

    function setProfileImageURI(uint256 profileId, string calldata imageURI) external;

    function setProfileImageURIWithSig(DataTypes.SetProfileImageURIWithSigData calldata vars)
        external;

    function post(DataTypes.PostData calldata vars) external;

    function postWithSig(DataTypes.PostWithSigData calldata vars) external returns (uint256);

    function comment(DataTypes.CommentData calldata vars) external;

    function commentWithSig(DataTypes.CommentWithSigData calldata vars) external returns (uint256);

    function mirror(DataTypes.MirrorData calldata vars) external;

    function mirrorWithSig(DataTypes.MirrorWithSigData calldata vars) external returns (uint256);

    function setFollowNFTURI(uint256 profileId, string calldata followNFTURI) external;

    function follow(uint256[] calldata profileIds, bytes[] calldata datas) external;

    function followWithSig(DataTypes.FollowWithSigData calldata vars)
        external
        returns (uint256[] memory);

    function collect(uint256 profileId, uint256 pubId, bytes calldata data) external;

    function collectWithSig(DataTypes.CollectWithSigData calldata vars) external returns (uint256);

    function burn(uint256 profileId) external;

    function getProfile(uint256 profileId) external view returns (DataTypes.ProfileStruct memory);

}
