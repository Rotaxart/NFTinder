// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import {DataTypes} from "./DataTypes.sol";
import {NFTinStorage} from "./NFTinStorage.sol";

contract LensInteractions is NFTinStorage {


    function setLensHubAddress(address _lensHub) external {
        //for develop
        lensAddress = _lensHub;
    }

    function setTinToken(address _tinToken) external {
        tinToken = _tinToken;
    }

    function post(DataTypes.PostData memory vars)
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
