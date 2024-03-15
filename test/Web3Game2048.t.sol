// SPDX-License-Identifier: GPL-3.0-only
// @author: Jason Yapri
// @website: https://jasonyapri.com
// @linkedIn: https://linkedin.com/in/jasonyapri
// @version: 0.2.2 (2024.03.15)
// Contract: Web3 Game - 2048
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import {Web3Game2048} from "../src/Web3Game2048.sol";

contract Web3Game2048BaseTest is Test {
    Web3Game2048 public web3Game;
    uint internal constant STARTING_PRIZE_POOL = 1000000000000000000; // 1 Ether or 1e18 wei

    function setUp() public {
        // vm.warp(1000);
        web3Game = new Web3Game2048{value: STARTING_PRIZE_POOL}();
    }

    function _printGameBoard() public view {
        console.log("Game Board:");
        for (uint256 i = 0; i < 4; i++) {
            string memory row;
            for (uint256 j = 0; j < 4; j++) {
                row = string.concat(
                    row,
                    Strings.toString(uint256(web3Game.getGameBoardTile(i, j))),
                    " "
                );
            }
            console.log(row);
        }
        console.log("End of Game Board");
    }

    function _getFilledTilesCount() public view returns (uint256) {
        uint256 count = 0;
        for (uint256 i = 0; i < 4; i++) {
            for (uint256 j = 0; j < 4; j++) {
                if (web3Game.getGameBoardTile(i, j) != 0) {
                    count++;
                }
            }
        }
        return count;
    }

    receive() external payable {}
}

contract Web3Game2048ConstructorTest is Web3Game2048BaseTest {
    function test_PrizeVariables() public view {
        assertEq(web3Game.prizePool(), STARTING_PRIZE_POOL);
        assertEq(web3Game.firstPrizeDistributed(), false);
        assertEq(web3Game.secondPrizeDistributed(), false);
        assertEq(web3Game.thirdPrizeDistributed(), false);
        assertEq(web3Game.GRAND_PRIZE_PERCENTAGE(), 50);
        assertEq(web3Game.FIRST_PRIZE_PERCENTAGE(), 10);
        assertEq(web3Game.SECOND_PRIZE_PERCENTAGE(), 5);
        assertEq(web3Game.THIRD_PRIZE_PERCENTAGE(), 3);
        assertEq(web3Game.COMMISSION_PERCENTAGE(), 10);
    }

    function test_AuthorVariables() public view {
        assertEq(web3Game.AUTHOR_NAME(), "Jason Yapri");
        assertEq(web3Game.AUTHOR_WEBSITE(), "https://jasonyapri.com");
        assertEq(
            web3Game.AUTHOR_LINKEDIN(),
            "https://linkedin.com/in/jasonyapri"
        );
    }

    function test_GameLogicVariables() public view {
        assertEq(web3Game.owner(), address(this));
        assertEq(web3Game.moveCount(), 0);
        assertEq(_getFilledTilesCount(), 2);
        _printGameBoard();
    }
}

contract Web3Game2048EmergencyExitTest is Web3Game2048BaseTest {
    error NotAuthorized(address sender);

    function test_EmergencyExit() public {
        uint contractBalanceBefore = address(web3Game).balance;
        uint ownerBalanceBefore = address(this).balance;
        web3Game.emergencyExit();
        uint contractBalanceAfter = address(web3Game).balance;
        uint ownerBalanceAfter = address(this).balance;
        assertEq(
            contractBalanceBefore - contractBalanceAfter,
            STARTING_PRIZE_POOL
        );
        assertEq(ownerBalanceAfter - ownerBalanceBefore, STARTING_PRIZE_POOL);
    }

    function test_RevertIf_NotCalledByOwner() public {
        vm.startPrank(address(1));
        vm.expectRevert(
            abi.encodeWithSelector(NotAuthorized.selector, address(1))
        );
        web3Game.emergencyExit();
    }
}
