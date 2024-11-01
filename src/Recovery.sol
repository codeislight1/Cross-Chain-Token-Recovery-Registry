// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {Owned} from "solmate/src/auth/Owned.sol";
import {ERC20} from "solmate/src/tokens/ERC20.sol";
import {SafeTransferLib} from "solmate/src/utils/SafeTransferLib.sol";

/**
 * Funds Recovery Contract
 * @author CodeIsLight1
 * @dev includes Native, ERC20 and general multicall as a backup.
 */
contract Recovery is Owned {
    constructor(address _owner) Owned(_owner) {}

    function recoverNative() external onlyOwner {
        uint256 balance = address(this).balance;
        SafeTransferLib.safeTransferETH(owner, balance);
    }

    function recoverERC20(address[] calldata tokens) external onlyOwner {
        for (uint256 i; i < tokens.length; i++) {
            ERC20 token = ERC20(tokens[i]);
            uint256 balance = token.balanceOf(address(this));
            SafeTransferLib.safeTransfer(token, owner, balance);
        }
    }

    struct BackupData {
        address to;
        uint256 value;
        bytes data;
    }

    function backup(BackupData[] calldata inputs) external onlyOwner {
        uint256 len = inputs.length;
        for (uint256 i; i < len; i++) {
            (bool success,) = inputs[i].to.call{value: inputs[i].value}(inputs[i].data);
            require(success, "!CALL");
        }
    }
}
