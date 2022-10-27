// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../../node_modules/@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract Test1155 is ERC1155 {
    constructor() ERC1155("https://321.321") {
        _mint(msg.sender, 1, 1, "0x00");
    }
}