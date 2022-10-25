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

    function post(DataTypes.PostData calldata vars)
        internal
        returns (bool, uint256)
    {
        (bool success, bytes memory data) = lensAddress.call(
            abi.encodeWithSignature(
                "post((uint256,string,address,bytes,address,bytes))",
                vars
            )
        );

        return (success, abi.decode(data, (uint256)));
    }

    function comment(DataTypes.CommentData calldata vars)
        internal
        returns (bool, uint256)
    {
        (bool success, bytes memory data) = lensAddress.call(
            abi.encodeWithSignature(
                "comment((uint256,string,uint256,uint256,bytes,address,bytes,address,bytes))",
                vars
            )
        );
        return (success, abi.decode(data, (uint256)));
    }

    function mirror(DataTypes.MirrorData calldata vars)
        internal
        returns (bool, uint256)
    {
        (bool success, bytes memory data) = lensAddress.call(
            abi.encodeWithSignature(
                "mirror((uint256,uint256,uint256,bytes,address,bytes))",
                vars
            )
        );
        return (success, abi.decode(data, (uint256)));
    }

    function collect(
        uint256 profileId,
        uint256 pubId,
        bytes calldata data
    ) internal {
        lensHub.collect(profileId, pubId, data);
    }

    function ownerOf(uint256 tokenId) internal returns (address){
        (, bytes memory data) = lensAddress.call(
            abi.encodeWithSignature(
                "ownerOf(uint256)",
                tokenId
            )
        );
        return  abi.decode(data, (address));
    }
}
