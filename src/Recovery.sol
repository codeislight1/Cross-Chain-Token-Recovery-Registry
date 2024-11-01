// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {Owned} from "solmate/src/auth/Owned.sol";
import {ERC20} from "solmate/src/tokens/ERC20.sol";
import {ERC721, ERC721TokenReceiver} from "solmate/src/tokens/ERC721.sol";
import {ERC1155, ERC1155TokenReceiver} from "solmate/src/tokens/ERC1155.sol";
import {SafeTransferLib} from "solmate/src/utils/SafeTransferLib.sol";
import { IRecovery } from "./interfaces/IRecovery.sol";

/**
 * Funds Recovery Contract
 * @author CodeIsLight1
 * @dev includes Native, ERC20, ERC721, ERC1155 recovery, and general multicall as a backup.
 */
contract Recovery is IRecovery, Owned, ERC721TokenReceiver, ERC1155TokenReceiver {
    constructor(address _owner) Owned(_owner) {}

    function recoverNative() external override onlyOwner {
        uint256 balance = address(this).balance;
        SafeTransferLib.safeTransferETH(msg.sender, balance);
    }

    function recoverERC20(address[] calldata tokens) external override onlyOwner {
        for (uint256 i; i < tokens.length; i++) {
            ERC20 token = ERC20(tokens[i]);
            uint256 balance = token.balanceOf(address(this));
            SafeTransferLib.safeTransfer(token, msg.sender, balance);
        }
    }

    function recoverERC721(ERC721Data[] calldata inputs) external override onlyOwner {
        uint256 tokensLength = inputs.length;
        for (uint256 i; i < tokensLength; i++) {
            uint256 tokenIdsLength = inputs[i].tokenIds.length;
            for (uint256 j; j < tokenIdsLength; j++) {
                ERC721(inputs[i].token).safeTransferFrom(address(this), msg.sender, inputs[i].tokenIds[j]);
            }
        }
    }

    function recoverERC1155(ERC1155Data[] calldata inputs) external override onlyOwner {
        uint256 len = inputs.length;
        for (uint256 i; i < len; i++) {
            if (inputs[i].ids.length != inputs[i].values.length) revert ArrayLengthMismatch();
            ERC1155(inputs[i].token).safeBatchTransferFrom(address(this), msg.sender, inputs[i].ids, inputs[i].values, "");
        }
    }

    function multicall(MulticallData[] calldata inputs) external override onlyOwner {
        uint256 len = inputs.length;
        for (uint256 i; i < len; i++) {
            (bool success,) = inputs[i].to.call{value: inputs[i].value}(inputs[i].data);
            require(success, "!CALL");
        }
    }
}
