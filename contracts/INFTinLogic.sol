// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import {DataTypes} from "./DataTypes.sol";
import {NFTinStorage} from "./NFTinStorage.sol";
interface INFTinLogic {
    function setPost(DataTypes.PostData calldata vars) external;

    function setComment(DataTypes.CommentData calldata vars) external;

    function setMirror(DataTypes.MirrorData calldata vars) external;

    function setLike(
        uint256 _profileId,
        uint256 _profileIdPointed,
        uint256 _postId
    ) external;

    function getPostList(uint256 _profileId)
        external
        view
        returns (uint256[] memory);

    function getMirrors(uint256 _profileId)
        external
        view
        returns (NFTinStorage.Mirrors[] memory);

    function getComments(uint256 _profileId, uint256 _postId)
        external
        view
        returns (NFTinStorage.Comments[] memory);

    function getProfile(address _profileAddress)
        external
        view
        returns (uint256);  
}
