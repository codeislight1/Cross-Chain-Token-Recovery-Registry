// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import {Test} from "forge-std/src/Test.sol";
import {ERC20} from "@solmate/src/tokens/ERC20.sol";
import {Recovery} from "../src/Recovery.sol";

contract MockERC20 is ERC20 {
    constructor() ERC20("", "", 18) {}
}

contract RecoveryTest is Test {
    Recovery recovery;
    address constant owner = address(123);
    MockERC20 mock;

    function setUp() public {
        recovery = new Recovery(owner);
        mock = new MockERC20();
    }

    function test_owner() public {
        vm.expectRevert("UNAUTHORIZED");
        recovery.recoverNative();

        address[] memory empty_addresses = new address[](0);
        Recovery.BackupData[]
            memory empty_backupDatas = new Recovery.BackupData[](0);

        vm.expectRevert("UNAUTHORIZED");
        recovery.recoverERC20(empty_addresses);

        vm.expectRevert("UNAUTHORIZED");
        recovery.backup(empty_backupDatas);
    }

    function test_native(uint256 value) public {
        deal(address(recovery), value);

        vm.prank(owner);
        recovery.recoverNative();

        assertEq(owner.balance, value);
    }

    function test_erc20(uint256 value) public {
        deal(address(mock), address(recovery), value);

        address[] memory tokens = new address[](1);
        tokens[0] = address(mock);

        vm.prank(owner);
        recovery.recoverERC20(tokens);

        assertEq(mock.balanceOf(owner), value);
    }

    function test_backup(uint256 value) public {
        value = bound(value, 1, type(uint256).max);
        deal(address(mock), address(recovery), value);

        Recovery.BackupData[] memory inputs = new Recovery.BackupData[](1);
        inputs[0] = Recovery.BackupData({
            to: address(mock),
            value: 0,
            data: abi.encodeWithSignature(
                "transfer(address,uint256)",
                address(owner),
                value
            )
        });

        vm.prank(owner);
        recovery.backup(inputs);

        assertEq(mock.balanceOf(owner), value);

        vm.prank(owner);
        vm.expectRevert("!CALL");
        recovery.backup(inputs);
    }
}
