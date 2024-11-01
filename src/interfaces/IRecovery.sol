// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

interface IRecovery {
    error ArrayLengthMismatch();

    struct ERC721Data {
        address token;
        uint256[] tokenIds;
    }

    struct ERC1155Data {
        address token;
        uint256[] ids;
        uint256[] values;
    }

    struct MulticallData {
        address to;
        uint256 value;
        bytes data;
    }

    function recoverNative() external;

    function recoverERC20(address[] calldata tokens) external;

    function recoverERC721(ERC721Data[] calldata inputs) external;

    function recoverERC1155(ERC1155Data[] calldata inputs) external;

    function multicall(MulticallData[] calldata inputs) external;
}