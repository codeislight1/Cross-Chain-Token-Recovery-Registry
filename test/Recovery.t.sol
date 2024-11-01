// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {Test} from "forge-std/src/Test.sol";
import {ERC20} from "solmate/src/tokens/ERC20.sol";
import {ERC721} from "solmate/src/tokens/ERC721.sol";
import {ERC1155} from "solmate/src/tokens/ERC1155.sol";
import {Recovery} from "../src/Recovery.sol";
import { IRecovery } from "../src/interfaces/IRecovery.sol";

contract MockERC20 is ERC20 {
    constructor() ERC20("", "", 18) {}
}

contract MockERC721 is ERC721 {
    constructor() ERC721("", "") {}

    function tokenURI(uint256) public pure override returns (string memory) {
        return "";
    }

    function mint(address _to, uint256 _id) external {
        _mint(_to, _id);
    }
}

contract MockERC1155 is ERC1155 {
    function mint(address to, uint256 id, uint256 amount) external {
        _mint(to, id, amount, "");
    }

    function uri(uint256) public pure override returns (string memory) {
        return "";
    }
}

contract RecoveryTest is Test {
    Recovery recovery;
    MockERC20 mockERC20;
    MockERC721 mockERC721;
    MockERC1155 mockERC1155;
    address constant owner = address(123);

    function setUp() public {
        recovery = new Recovery(owner);
        mockERC20 = new MockERC20();
        mockERC721 = new MockERC721();
        mockERC1155 = new MockERC1155();
    }

    function test_owner() public {
        vm.expectRevert("UNAUTHORIZED");
        recovery.recoverNative();

        address[] memory empty_addresses = new address[](0);
        IRecovery.MulticallData[] memory empty_multicalls = new IRecovery.MulticallData[](0);

        vm.expectRevert("UNAUTHORIZED");
        recovery.recoverERC20(empty_addresses);

        IRecovery.ERC721Data[] memory empty_erc721Data = new IRecovery.ERC721Data[](0);
        vm.expectRevert("UNAUTHORIZED");
        recovery.recoverERC721(empty_erc721Data);

        IRecovery.ERC1155Data[] memory empty_erc1155Data = new IRecovery.ERC1155Data[](0);
        vm.expectRevert("UNAUTHORIZED");
        recovery.recoverERC1155(empty_erc1155Data);

        vm.expectRevert("UNAUTHORIZED");
        recovery.multicall(empty_multicalls);
    }

    function test_native(uint256 value) public {
        deal(address(recovery), value);

        vm.prank(owner);
        recovery.recoverNative();

        assertEq(owner.balance, value);
    }

    function test_erc20(uint256 value) public {
        deal(address(mockERC20), address(recovery), value);

        address[] memory tokens = new address[](1);
        tokens[0] = address(mockERC20);

        vm.prank(owner);
        recovery.recoverERC20(tokens);

        assertEq(mockERC20.balanceOf(owner), value);
    }

    function test_erc721(uint256 value) public {
        uint256 tokenIdStart = 1;
        uint256 size = bound(value, 1, 10);
        IRecovery.ERC721Data[] memory inputs = new IRecovery.ERC721Data[](1);
        inputs[0].token = address(mockERC721);
        inputs[0].tokenIds = new uint256[](size);

        
        for (uint256 i; i < size; i++) {
            uint256 tokenId = tokenIdStart + i;
            inputs[0].tokenIds[i] = tokenId;
            
            mockERC721.mint(address(recovery), tokenId);
            assertEq(mockERC721.ownerOf(tokenId), address(recovery));
        }

        vm.prank(owner);
        recovery.recoverERC721(inputs);

        for (uint256 i; i < size; i++) {
            uint256 tokenId = tokenIdStart + i;
            assertEq(mockERC721.ownerOf(tokenId), owner);
        }
    }

    function test_erc1155_mismatchArrayLength() public {
        uint256 size = 1;
        IRecovery.ERC1155Data[] memory inputs = new IRecovery.ERC1155Data[](1);
        inputs[0].ids = new uint256[](size);
        inputs[0].values = new uint256[](size - 1);

        vm.prank(owner);
        vm.expectRevert(IRecovery.ArrayLengthMismatch.selector);
        recovery.recoverERC1155(inputs);
    }

    function test_erc1155(uint256 value) public {
        uint256 idStart = 1;
        uint256 size = bound(value, 1, 10);
        uint256 amount = 1e18;
        IRecovery.ERC1155Data[] memory inputs = new IRecovery.ERC1155Data[](1);
        inputs[0].token = address(mockERC1155);
        inputs[0].ids = new uint256[](size);
        inputs[0].values = new uint256[](size);

        for (uint256 i; i < size; i++) {
            uint256 id = idStart + i;
            inputs[0].ids[i] = id;
            inputs[0].values[i] = amount;

            mockERC1155.mint(address(recovery), id, amount);
            assertEq(mockERC1155.balanceOf(address(recovery), id), amount);
        }

        vm.prank(owner);
        recovery.recoverERC1155(inputs);

        for (uint256 i; i < size; i++) {
            uint256 id = idStart + i;
            assertEq(mockERC1155.balanceOf(address(owner), id), amount);
        }
    }

    function test_multicall(uint256 value) public {
        value = bound(value, 1, type(uint256).max);
        deal(address(mockERC20), address(recovery), value);

        IRecovery.MulticallData[] memory inputs = new IRecovery.MulticallData[](1);
        inputs[0] = IRecovery.MulticallData({
            to: address(mockERC20),
            value: 0,
            data: abi.encodeWithSignature("transfer(address,uint256)", address(owner), value)
        });

        vm.prank(owner);
        recovery.multicall(inputs);

        assertEq(mockERC20.balanceOf(owner), value);

        vm.prank(owner);
        vm.expectRevert("!CALL");
        recovery.multicall(inputs);
    }
}
