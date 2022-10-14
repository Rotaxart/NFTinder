// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import {DataTypes} from "./DataTypes.sol";
import {ILensInteractions} from "./ILensInteractions.sol";
import {NFTinStorage} from "./NFTinStorage.sol";

contract LensInteractions is NFTinStorage {
    address public lensAddress;

    ILensInteractions lensHub;

    function setLensHubAddress(address _lensHub) public {
        //for develop
        lensHub = ILensInteractions(_lensHub);
        lensAddress = _lensHub;
    }

    function setDefaultProfileWithSig(
        DataTypes.SetDefaultProfileWithSigData calldata vars
    ) external {
        (bool success, ) = lensAddress.call(
            abi.encodeWithSignature(
                "setDefaultProfileWithSig((address,uint256,(uint8,bytes32,bytes32,uint256)))",
                vars
            )
        );
        require(success, "Transaction failed");
    }

    function setFollowModule(
        uint256 profileId,
        address followModule,
        bytes calldata followModuleData
    ) external {
        (bool success, ) = lensAddress.call(
            abi.encodeWithSignature(
                "setFollowModule(uint256,address,bytes)",
                profileId,
                followModule,
                followModuleData
            )
        );
        require(success, "Transaction failed");
    }

    function setFollowModuleWithSig(
        DataTypes.SetFollowModuleWithSigData calldata vars
    ) external {
        (bool success, ) = lensAddress.call(
            abi.encodeWithSignature(
                "setFollowModuleWithSig((uint256,address,bytes,(uint8,bytes32,bytes32,uint256)))",
                vars
            )
        );
        require(success, "Transaction failed");
    }

    function setDispatcher(uint256 profileId, address dispatcher) external {
        lensHub.setDispatcher(profileId, dispatcher);
    }

    function setDispatcherWithSig(
        DataTypes.SetDispatcherWithSigData calldata vars
    ) external {
        lensHub.setDispatcherWithSig(vars);
    }

    function setProfileImageURI(uint256 profileId, string calldata imageURI)
        external
    {
        lensHub.setProfileImageURI(profileId, imageURI);
    }

    function setProfileImageURIWithSig(
        DataTypes.SetProfileImageURIWithSigData calldata vars
    ) external {
        lensHub.setProfileImageURIWithSig(vars);
    }

    function post(DataTypes.PostData calldata vars)
        public
        returns (bool, uint256)
    {
        (bool success, bytes memory data) = lensAddress.call(
            abi.encodeWithSignature(
                "post((uint256,string,address,bytes,address,bytes))",
                vars
            )
        );

        return (success, uint256(bytes32(data))
            // abi.decode(data, (uint256))
        );
    }

    function postWithSig(DataTypes.PostWithSigData calldata vars) external {
        lensHub.postWithSig(vars);
    }

    function comment(DataTypes.CommentData calldata vars) external {
        lensHub.comment(vars);
    }

    function commentWithSig(DataTypes.CommentWithSigData calldata vars)
        external
    {
        lensHub.commentWithSig(vars);
    }

    function mirror(DataTypes.MirrorData calldata vars) external {
        lensHub.mirror(vars);
    }

    function mirrorWithSig(DataTypes.MirrorWithSigData calldata vars) external {
        lensHub.mirrorWithSig(vars);
    }

    function setFollowNFTURI(uint256 profileId, string calldata followNFTURI)
        external
    {
        lensHub.setFollowNFTURI(profileId, followNFTURI);
    }

    function follow(uint256[] calldata profileIds, bytes[] calldata datas)
        external
    {
        lensHub.follow(profileIds, datas);
    }

    function followWithSig(DataTypes.FollowWithSigData calldata vars) external {
        lensHub.followWithSig(vars);
    }

    function collect(
        uint256 profileId,
        uint256 pubId,
        bytes calldata data
    ) external {
        lensHub.collect(profileId, pubId, data);
    }

    function collectWithSig(DataTypes.CollectWithSigData calldata vars)
        external
    {
        lensHub.collectWithSig(vars);
    }

    function burn(uint256 profileId) external {
        lensHub.burn(profileId);
    }

    function getProfile(uint256 profileId)
        public
        returns (bool, DataTypes.ProfileStruct memory)
    {
        (bool success, bytes memory data) = lensAddress.call(
            abi.encodeWithSignature("getProfile(uint256)", profileId)
        );

        return (success, abi.decode(data, (DataTypes.ProfileStruct)));
    }

    function getPub(uint256 profileId, uint256 pubId)
        public
        returns (DataTypes.PublicationStruct memory)
    {
        (bool success, bytes memory data) = lensAddress.call(
            abi.encodeWithSignature("getPub(uint256,uint256)", profileId, pubId)
        );
        require(success, "Transaction failed");

        return abi.decode(data, (DataTypes.PublicationStruct));
    }

    function getPubType(uint256 profileId, uint256 pubId)
        public
        returns (bool, DataTypes.PubType)
    {
        (bool success, bytes memory data) = lensAddress.call(
            abi.encodeWithSignature(
                "getPubType(uint256,uint256)",
                profileId,
                pubId
            )
        );

        return (success, abi.decode(data, (DataTypes.PubType)));
    }
}
