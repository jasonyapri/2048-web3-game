// SPDX-License-Identifier: GPL-3.0-only
// @author: Jason Yapri
// @website: https://jasonyapri.com
// @linkedIn: https://linkedin.com/in/jasonyapri
// @version: 0.2.4 (2024.03.15)
// Contract: Web3 Game - 2048
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import {Web3Game2048} from "../src/Web3Game2048.sol";

contract Web3Game2048BaseTest is Test {
    Web3Game2048 public web3Game;
    uint internal constant STARTING_PRIZE_POOL = 1000000000000000000; // 1 Ether or 1e18 wei

    function setUp() public {
        vm.warp(1710490910); // set block.timestamp to Fri, Mar 15 2024 | 15:21:50 GMT+0700
        web3Game = new Web3Game2048{value: STARTING_PRIZE_POOL}();
    }

    function _printGameBoard(string memory caption) internal view {
        console.log(
            string.concat(
                "Game Board",
                !_stringIsTheSame(caption, "")
                    ? string.concat(" - ", caption)
                    : "",
                ":"
            )
        );
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
        console.log("");
    }

    function _stringIsTheSame(
        string memory s1,
        string memory s2
    ) internal pure returns (bool) {
        return
            keccak256(abi.encodePacked(s1)) == keccak256(abi.encodePacked(s2));
    }

    function _getFilledTilesCount() internal view returns (uint256) {
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

    function _caclulateTilesSum() public view returns (uint256) {
        uint256 sum = 0;
        for (uint256 i = 0; i < 4; i++) {
            for (uint256 j = 0; j < 4; j++) {
                if (web3Game.getGameBoardTile(i, j) != 0) {
                    sum += web3Game.getGameBoardTile(i, j);
                }
            }
        }
        return sum;
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
        // _printGameBoard("");
    }
}

contract Web3Game2048MakeMoveTest is Web3Game2048BaseTest {
    function test_MakeMoveUp() public {
        // _printGameBoard("BEFORE");
        /*
            Game Board - BEFORE:
            0 2 0 0
            2 0 0 0
            0 0 0 0
            0 0 0 0
        */

        web3Game.makeMove(Web3Game2048.Move.UP);
        assertEq(web3Game.moveCount(), 1); // First Move
        assertEq(_caclulateTilesSum(), 6); // 2 x 2 (Initial Tiles) + 2 (New Tile)
        assertEq(web3Game.getGameBoardTile(0, 0), 2);
        assertEq(web3Game.getGameBoardTile(0, 1), 2);

        // _printGameBoard("AFTER");
        /*
            Game Board - AFTER:
            2 2 0 0
            0 0 0 0
            2 0 0 0
            0 0 0 0
        */
    }

    function test_MakeMoveDown() public {
        // _printGameBoard("BEFORE");
        /*
            Game Board - BEFORE:
            0 2 0 0
            2 0 0 0
            0 0 0 0
            0 0 0 0
        */

        web3Game.makeMove(Web3Game2048.Move.DOWN);
        assertEq(web3Game.moveCount(), 1); // First Move
        assertEq(_caclulateTilesSum(), 6); // 2 x 2 (Initial Tiles) + 2 (New Tile)
        assertEq(web3Game.getGameBoardTile(3, 0), 2);
        assertEq(web3Game.getGameBoardTile(3, 1), 2);

        // _printGameBoard("AFTER");
        /*
            Game Board - AFTER:
            0 0 0 0
            0 0 2 0
            0 0 0 0
            2 2 0 0
        */
    }
}

contract Web3Game2048DonateToPrizePoolTest is Web3Game2048BaseTest {
    error NoAmountSent();

    function test_donateToPrizePool() public {
        deal(address(1), 2 ether);
        vm.startPrank(address(1));

        uint contractBalanceBefore = address(web3Game).balance;
        uint donatorBalanceBefore = address(1).balance;

        web3Game.donateToPrizePool{value: 1 ether}("Jason Yapri");

        uint contractBalanceAfter = address(web3Game).balance;
        uint donatorBalanceAfter = address(1).balance;

        assertEq(contractBalanceBefore + 1 ether, contractBalanceAfter);
        assertEq(donatorBalanceAfter < donatorBalanceBefore, true);
    }

    function test_RevertIf_NoAmountSent() public {
        vm.prank(address(1));
        vm.expectRevert(abi.encodeWithSelector(NoAmountSent.selector));
        web3Game.donateToPrizePool("Jason Yapri");
    }
}

contract Web3Game2048DonateToOwnerTest is Web3Game2048BaseTest {
    error NoAmountSent();

    function test_DonateToOwner() public {
        deal(address(1), 2 ether);
        vm.startPrank(address(1));

        uint contractBalanceBefore = address(web3Game).balance;
        uint ownerBalanceBefore = address(this).balance;
        uint donatorBalanceBefore = address(1).balance;

        web3Game.donateToOwner{value: 1 ether}();

        uint contractBalanceAfter = address(web3Game).balance;
        uint ownerBalanceAfter = address(this).balance;
        uint donatorBalanceAfter = address(1).balance;

        assertEq(contractBalanceBefore, contractBalanceAfter);
        assertEq(ownerBalanceBefore + 1 ether, ownerBalanceAfter);
        assertEq(donatorBalanceBefore > donatorBalanceAfter, true);
    }

    function test_RevertIf_NoAmountSent() public {
        vm.prank(address(1));
        vm.expectRevert(abi.encodeWithSelector(NoAmountSent.selector));
        web3Game.donateToOwner();
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
