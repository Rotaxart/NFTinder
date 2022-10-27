// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import "../node_modules/@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract NFTsInteractions {
    function isNftOwner(
        address _nftAddress,
        address _user,
        uint256 _tokenId
    ) internal returns (bool) {
        (bool success, bytes memory result) = _nftAddress.call(
            abi.encodeWithSignature(
                "supportsInterface(bytes4)",
                type(IERC721).interfaceId
            )
        );
        if (success && abi.decode(result, (bool))) {
            (, bytes memory data) = _nftAddress.call(
                abi.encodeWithSignature("ownerOf(uint256)", _tokenId)
            );
            return abi.decode(data, (address)) == _user;
        } else {
            (success, result) = _nftAddress.call(
                abi.encodeWithSignature(
                    "supportsInterface(bytes4)",
                    type(IERC1155).interfaceId
                )
            );
            if (success && abi.decode(result, (bool))) {
                (, bytes memory data) = _nftAddress.call(
                    abi.encodeWithSignature(
                        "balanceOf(address,uint256)",
                        _user,
                        _tokenId
                    )
                );
                return abi.decode(data, (uint256)) != 0;
            }
        }
        require(success, "Can`t check NFTs type");
        return false;
    }

    function getNftUri(address _nftAddress, uint256 _tokenId)
        internal
        returns (string memory)
    {
        (bool success, bytes memory result) = _nftAddress.call(
            abi.encodeWithSignature(
                "supportsInterface(bytes4)",
                type(IERC721).interfaceId
            )
        );

        if (success && abi.decode(result, (bool))) {
            (, bytes memory data) = _nftAddress.call(
                abi.encodeWithSignature("tokenURI(uint256)", _tokenId)
            );
            return abi.decode(data, (string));
        }
        
            // (success, result) = _nftAddress.call(
            //     abi.encodeWithSignature(
            //         "supportsInterface(bytes4)",
            //         type(IERC1155).interfaceId
            //     )
            // );
            // if (success && abi.decode(result, (bool))) {
                (, bytes memory data1) = _nftAddress.call(
                    abi.encodeWithSignature(
                        "uri(uint256)",
                        _tokenId
                    )
                );
                 return abi.decode(data1, (string));
            // }
        
        // require(success, "Can`t check NFTs type");
      //  return "";
    }
}
