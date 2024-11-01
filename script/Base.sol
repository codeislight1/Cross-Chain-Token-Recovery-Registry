// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {Recovery} from "../src/Recovery.sol";
import {IRecovery} from "../src/interfaces/IRecovery.sol";
import {console} from "forge-std/src/console.sol";
import {IERC20} from "forge-std/src/interfaces/IERC20.sol";
import {IERC721} from "forge-std/src/interfaces/IERC721.sol";
import {IERC1155} from "forge-std/src/interfaces/IERC1155.sol";
import {Script} from "../lib/forge-std/src/Script.sol";
import "./constants.sol";

abstract contract Base is Script {
    // Storage
    Recovery recovery;
    uint256 selectedFork;

    function _deployRecovery() internal {
        selectedFork = vm.createSelectFork(vm.rpcUrl(ORIGINAL_CHAIN));
        require(TARGETED_CONTRACT.code.length > 0, "!contract"); // ensure contract
        require(vm.computeCreateAddress(BROADCASTER, TARGETED_NONCE) == TARGETED_CONTRACT, "!computeTarget");

        selectedFork = vm.createSelectFork(vm.rpcUrl(TARGETED_CHAIN));
        uint256 deployerNonce = vm.getNonce(BROADCASTER);
        require(deployerNonce <= TARGETED_NONCE, "!nonce");

        uint256 txCount = deployerNonce;

        vm.startBroadcast(BROADCASTER);
        while (txCount <= TARGETED_NONCE) {
            if (txCount == TARGETED_NONCE) {
                // deploy recovery contract
                recovery = new Recovery(BROADCASTER);
            } else {
                // send self transaction
                (bool success,) = BROADCASTER.call{value: 0}("");
                require(success, "!SELF");
            }
            txCount++;
        }
        vm.stopBroadcast();

        console.log("> Deployed Recovery:", address(recovery));

        require(address(recovery) == TARGETED_CONTRACT && address(recovery) != address(0), "!target");
    }

    function _recoverNative() public {
        if (selectedFork == 0) vm.createSelectFork(vm.rpcUrl(TARGETED_CHAIN));

        require(address(recovery) != address(0), "0 recovery");
        uint256 balance = recovery.owner().balance;
        vm.startBroadcast(BROADCASTER);
        recovery.recoverNative();
        vm.stopBroadcast();
        uint256 difference = recovery.owner().balance - balance;
        require(difference > 0, "0 native");
        uint256 wholePart = difference / 1e18;
        uint256 decimalPart = difference % 1e18;
        console.log("> Recovered Native: %s.%s %s", wholePart, decimalPart, _getChainTicker());
    }

    function _recoverERC20(address[] memory tokens) public {
        if (selectedFork == 0) vm.createSelectFork(vm.rpcUrl(TARGETED_CHAIN));

        require(address(recovery) != address(0), "0 recovery");
        uint256 length = tokens.length;
        require(length > 0, "erc20 zero length");

        for (uint256 i; i < length; i++) {
            require(tokens[i] != address(0), "ERC20 token 0 address");
        }

        uint256[] memory balances = new uint256[](length);

        address owner = recovery.owner();
        for (uint256 i; i < length; i++) {
            balances[i] = IERC20(tokens[i]).balanceOf(owner);
        }

        vm.startBroadcast(BROADCASTER);
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

    function _recoverERC721(IRecovery.ERC721Data[] memory inputs) public {
        if (selectedFork == 0) vm.createSelectFork(vm.rpcUrl(TARGETED_CHAIN));

        require(address(recovery) != address(0), "0 recovery");
        uint256 length = inputs.length;
        require(length > 0, "ERC721 zero length");

        for (uint256 i; i < length; i++) {
            require(inputs[i].token != address(0), "ERC721 token 0 address");
            require(inputs[i].tokenIds.length > 0, "ERC721 empty tokenIds");
        }

        vm.startBroadcast(BROADCASTER);
        recovery.recoverERC721(inputs);
        
        address owner = recovery.owner();
        console.log("> Recovered ERC721 tokens:");
        for (uint256 i; i < length; i++) {
            IERC721 token = IERC721(inputs[i].token);
            console.log(" > token %s tokenIds:", i + 1);
            uint256 tokenIdsLength = inputs[i].tokenIds.length;
            for (uint256 j; j < tokenIdsLength; j++) {
                uint256 tokenId = inputs[i].tokenIds[j];
                require(token.ownerOf(tokenId) == owner, "owner not recieved tokenId");
                console.log("  > #%s", tokenId);
            }
        }
    }

    function _recoverERC1155(IRecovery.ERC1155Data[] memory inputs) public {
        if (selectedFork == 0) vm.createSelectFork(vm.rpcUrl(TARGETED_CHAIN));

        require(address(recovery) != address(0), "0 recovery");
        uint256 length = inputs.length;
        require(length > 0, "ERC1155 zero length");

        for (uint256 i; i < length; i++) {
            require(inputs[i].token != address(0), "ERC1155 token 0 address");
            require(inputs[i].ids.length > 0, "ERC1155 empty ids");
        }

        vm.startBroadcast(BROADCASTER);
        recovery.recoverERC1155(inputs);

        address owner = recovery.owner();
        console.log("> Recovered ERC1155 tokens:");
        for (uint256 i; i < length; i++) {
            IERC1155 token = IERC1155(inputs[i].token);
            console.log(" > token %s ids:", i + 1);
            uint256 tokenIdsLength = inputs[i].ids.length;
            for (uint256 j; j < tokenIdsLength; j++) {
                uint256 id = inputs[i].ids[j];
                uint256 value = inputs[i].values[j];
                require(token.balanceOf(owner, id) == value, "");
                console.log("  > #%s: %s", id, value);
            }
        }
    }
}
