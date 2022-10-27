// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../../node_modules/@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract Test721 is ERC721 {
    constructor(address _addr) ERC721("Test721", "MTK") {
        _safeMint(_addr, 1);
    }

    function _baseURI() internal pure override returns (string memory) {
        return "https://123.123";
    }

    // function transfer(
    //     // address from,
    //     address to,
    //     uint256 tokenId
    // ) public  {
    //     // //solhint-disable-next-line max-line-length
    //     // require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller is not token owner nor approved");

    //     // _transfer(from, to, tokenId);
    //     _owners[tokenId] = to;
    // }
}