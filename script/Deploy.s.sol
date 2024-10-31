// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import {Recovery} from "../src/Recovery.sol";
import {Base} from "./Base.sol";

/// @dev deploys Recovery contract, recovers Native, and ERC20s
contract FullRecovery is Base {
    // 1. list ERC20 tokens
    address[] updatedTokens = [
        0x4Fabb145d64652a948d72533023f6E7A623C7C53, // BUSD
        0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48, // USDC
        0xdAC17F958D2ee523a2206206994597C13D831ec7, // USDT
        0x0f51bb10119727a7e5eA3538074fb341F56B09Ad, // DAO
        0xF57e7e7C23978C3cAEC3C3548E3D615c346e79fF // IMX
    ];

    function run() public {
        for (uint256 i; i < updatedTokens.length; i++) {
            tokens.push(updatedTokens[i]);
        }
        _deployRecovery();
        _recoverNative();
        _recoverERC20();
    }
}

contract DeployRecovery is Base {
    function run() public {
        _deployRecovery();
    }
}

contract NativeRecovery is Base {
    function run() public {
        // 1. update deployed recovery contract
        recovery = Recovery(address(0));
        _recoverNative();
    }
}

contract ERC20Recovery is Base {
    // 1. list ERC20 tokens
    address[] updatedTokens = [
        0x4Fabb145d64652a948d72533023f6E7A623C7C53, // BUSD
        0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48, // USDC
        0xdAC17F958D2ee523a2206206994597C13D831ec7, // USDT
        0x0f51bb10119727a7e5eA3538074fb341F56B09Ad, // DAO
        0xF57e7e7C23978C3cAEC3C3548E3D615c346e79fF // IMX
    ];

    function run() public {
        for (uint256 i; i < updatedTokens.length; i++) {
            tokens.push(updatedTokens[i]);
        }
        // 2. update deployed recovery contract
        recovery = Recovery(address(0));
        _recoverERC20();
    }
}
