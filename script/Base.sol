// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import {Recovery} from "../src/Recovery.sol";
import {console} from "forge-std/src/console.sol";
import {IERC20} from "forge-std/src/interfaces/IERC20.sol";
import {Script} from "../lib/forge-std/src/Script.sol";
import "./constants.sol";

abstract contract Base is Script {
    // Storage
    address[] tokens;
    Recovery recovery;
    uint256 selectedFork;

    function _deployRecovery() internal {
        selectedFork = vm.createSelectFork(vm.rpcUrl(original_chain));
        require(targetedContract.code.length > 0, "!contract"); // ensure contract
        require(
            computeCreateAddress(broadcaster, targetedNonce) ==
                targetedContract,
            "!computeTarget"
        );

        selectedFork = vm.createSelectFork(vm.rpcUrl(rescue_chain));
        uint256 deployerNonce = vm.getNonce(broadcaster);
        require(deployerNonce <= targetedNonce, "!nonce");

        uint256 txCount = deployerNonce;

        vm.startBroadcast(broadcaster);
        while (txCount <= targetedNonce) {
            if (txCount == targetedNonce) {
                // deploy recovery contract
                recovery = new Recovery(broadcaster);
            } else {
                // send self transaction
                (bool success, ) = broadcaster.call{value: 0}("");
                require(success, "!SELF");
            }
            txCount++;
        }
        vm.stopBroadcast();

        console.log("> Deployed Recovery:", address(recovery));

        require(
            address(recovery) == targetedContract &&
                address(recovery) != address(0),
            "!target"
        );
    }

    function _recoverNative() public {
        if (selectedFork == 0) vm.createSelectFork(vm.rpcUrl(rescue_chain));

        require(address(recovery) != address(0), "0 recovery");
        uint balance = recovery.owner().balance;
        vm.startBroadcast(broadcaster);
        recovery.recoverNative();
        vm.stopBroadcast();
        uint256 difference = recovery.owner().balance - balance;
        require(difference > 0, "0 native");
        uint256 wholePart = difference / 1e18;
        uint256 decimalPart = difference % 1e18;
        console.log(
            "> Recovered Native: %s.%s %s",
            wholePart,
            decimalPart,
            _getChainTicker()
        );
    }

    function _recoverERC20() public {
        if (selectedFork == 0) vm.createSelectFork(vm.rpcUrl(rescue_chain));

        uint256 length = tokens.length;
        require(address(recovery) != address(0), "0 recovery");
        require(length > 0, "zero length");

        for (uint256 i; i < length; i++) {
            require(tokens[i] != address(0), "token 0 address");
        }

        uint256[] memory balances = new uint256[](length);

        address owner = recovery.owner();
        for (uint256 i; i < length; i++) {
            balances[i] = IERC20(tokens[i]).balanceOf(owner);
        }

        vm.startBroadcast(broadcaster);
        recovery.recoverERC20(tokens);

        console.log("> Recovered ERC20 tokens:");
        for (uint256 i; i < length; i++) {
            IERC20 token = IERC20(tokens[i]);
            uint256 difference = token.balanceOf(owner) - balances[i];
            uint256 decimals = token.decimals();
            uint256 wholePart = difference / 10 ** decimals;
            uint256 decimalPart = difference % 10 ** decimals;
            console.log(" > %s.%s %s", wholePart, decimalPart, token.name());
            require(difference > 0, "0 amount rescued");
        }
    }

    function _getChainTicker() internal view returns (string memory) {
        uint256 chainId = block.chainid;

        if (chainId == 1) return "ETH"; // Ethereum
        if (chainId == 10) return "ETH"; // Optimism
        if (chainId == 56) return "BNB"; // BSC
        if (chainId == 100) return "XDAI"; // Gnosis
        if (chainId == 137) return "MATIC"; // Polygon
        if (chainId == 8453) return "ETH"; // Base
        if (chainId == 43114) return "AVAX"; // Avalanche
        if (chainId == 42161) return "ETH"; // Arbitrum

        return "";
    }
}