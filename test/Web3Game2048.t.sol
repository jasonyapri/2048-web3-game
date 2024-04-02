// SPDX-License-Identifier: GPL-3.0-only
// @author: Jason Yapri
// @website: https://jasonyapri.com
// @linkedIn: https://linkedin.com/in/jasonyapri
// Contract: Web3 Game - 2048
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import {Web3Game2048} from "../src/Web3Game2048.sol";
import {ModifiedWeb3Game2048} from "../src/ModifiedWeb3Game2048.sol";

contract Web3Game2048BaseTest is Test {
    Web3Game2048 public web3Game;
    ModifiedWeb3Game2048 public modifiedWeb3Game;
    uint internal constant STARTING_PRIZE_POOL = 1 ether; // 1 Ether or 1e18 wei
    uint internal constant TIMESTAMP = 1710490910; // Fri, Mar 15 2024 | 15:21:50 GMT+0700

    function setUp() public {
        vm.warp(TIMESTAMP); // set block.timestamp
        web3Game = new Web3Game2048{value: STARTING_PRIZE_POOL}(address(this));
        modifiedWeb3Game = new ModifiedWeb3Game2048{value: STARTING_PRIZE_POOL}(
            address(this)
        );
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

    function _printModifiedGameBoard(string memory caption) internal view {
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
                    Strings.toString(
                        uint256(modifiedWeb3Game.getGameBoardTile(i, j))
                    ),
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

    function _caclulateModifiedGameTilesSum() public view returns (uint256) {
        uint256 sum = 0;
        for (uint256 i = 0; i < 4; i++) {
            for (uint256 j = 0; j < 4; j++) {
                if (modifiedWeb3Game.getGameBoardTile(i, j) != 0) {
                    sum += modifiedWeb3Game.getGameBoardTile(i, j);
                }
            }
        }
        return sum;
    }

    function _tileExists(uint16 tileNumber) public view returns (bool) {
        bool found = false;
        for (uint256 i = 0; i < 4; i++) {
            for (uint256 j = 0; j < 4; j++) {
                if (web3Game.getGameBoardTile(i, j) == tileNumber) {
                    found = true;
                    break;
                }
            }
            if (found) break;
        }
        return found;
    }

    function _modifiedGameTileExists(
        uint16 tileNumber
    ) public view returns (bool) {
        bool found = false;
        for (uint256 i = 0; i < 4; i++) {
            for (uint256 j = 0; j < 4; j++) {
                if (modifiedWeb3Game.getGameBoardTile(i, j) == tileNumber) {
                    found = true;
                    break;
                }
            }
            if (found) break;
        }
        return found;
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
        assertEq(web3Game.COMMISSION_PERCENTAGE(), 5);
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
    error NoValidMoveMade();

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

    function test_MakeMoveLeft() public {
        // _printGameBoard("BEFORE");
        /*
            Game Board - BEFORE:
            0 2 0 0
            2 0 0 0
            0 0 0 0
            0 0 0 0
        */

        web3Game.makeMove(Web3Game2048.Move.LEFT);
        assertEq(web3Game.moveCount(), 1); // First Move
        assertEq(_caclulateTilesSum(), 6); // 2 x 2 (Initial Tiles) + 2 (New Tile)
        assertEq(web3Game.getGameBoardTile(0, 0), 2);
        assertEq(web3Game.getGameBoardTile(1, 0), 2);

        // _printGameBoard("AFTER");
        /*
            Game Board - AFTER:
            2 0 0 0
            2 0 0 0
            2 0 0 0
            0 0 0 0
        */
    }

    function test_MakeMoveRight() public {
        // _printGameBoard("BEFORE");
        /*
            Game Board - BEFORE:
            0 2 0 0
            2 0 0 0
            0 0 0 0
            0 0 0 0
        */

        web3Game.makeMove(Web3Game2048.Move.RIGHT);
        assertEq(web3Game.moveCount(), 1); // First Move
        assertEq(_caclulateTilesSum(), 6); // 2 x 2 (Initial Tiles) + 2 (New Tile)
        assertEq(web3Game.getGameBoardTile(0, 3), 2);
        assertEq(web3Game.getGameBoardTile(1, 3), 2);

        // _printGameBoard("AFTER");
        /*
            Game Board - AFTER:
            0 0 0 2
            0 0 0 2
            2 0 0 0
            0 0 0 0
        */
    }

    function test_RevertIf_NoValidMoveMade() public {
        // _printGameBoard("BEFORE");
        /*
            Game Board - BEFORE:
            0 2 0 0
            2 0 0 0
            0 0 0 0
            0 0 0 0
        */

        web3Game.makeMove(Web3Game2048.Move.LEFT);
        assertEq(web3Game.moveCount(), 1); // First Move
        assertEq(_caclulateTilesSum(), 6); // 2 x 2 (Initial Tiles) + 2 (New Tile)
        assertEq(web3Game.getGameBoardTile(0, 0), 2);
        assertEq(web3Game.getGameBoardTile(1, 0), 2);

        // _printGameBoard("AFTER");
        /*
            Game Board - AFTER:
            2 0 0 0
            2 0 0 0
            2 0 0 0
            0 0 0 0
        */

        vm.expectRevert(abi.encodeWithSelector(NoValidMoveMade.selector));
        web3Game.makeMove(Web3Game2048.Move.LEFT);
    }

    function test_RevertIf_CircuitBreakerActivated() public {
        web3Game.toggleCircuitBreaker();

        vm.expectRevert();
        web3Game.makeMove(Web3Game2048.Move.LEFT);
    }
}

contract Web3Game2048ResetGameTest is Web3Game2048BaseTest {
    function test_ResetGame() public {
        // no more valid moves after making last move, so game should be reset
        modifiedWeb3Game.hackGameBoard_ResetGame();

        // _printModifiedGameBoard("BEFORE");
        /*
            Game Board - BEFORE:
            0 32 64 32
            4 2 8 64
            64 32 16 8
            128 256 512 1024
        */

        modifiedWeb3Game.makeMove(Web3Game2048.Move.LEFT);

        // _printModifiedGameBoard("AFTER");
        /*
            Game Board - AFTER:
            0 2 0 0
            2 0 0 0
            0 0 0 0
            0 0 0 0
        */

        assertEq(web3Game.moveCount(), 0); // No move has been made after game is reset
        assertEq(_caclulateTilesSum(), 4); // 2 x 2 (Initial Tiles)
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

    function test_RevertIf_CircuitBreakerActivated() public {
        web3Game.toggleCircuitBreaker();

        deal(address(1), 2 ether);
        vm.startPrank(address(1));

        vm.expectRevert();
        web3Game.donateToPrizePool{value: 1 ether}("Jason Yapri");
    }
}

contract Web3Game2048DonateToAuthorTest is Web3Game2048BaseTest {
    error NoAmountSent();

    function test_DonateToAuthor() public {
        deal(address(1), 2 ether);
        vm.startPrank(address(1));

        uint contractBalanceBefore = address(web3Game).balance;
        uint ownerBalanceBefore = address(this).balance;
        uint donatorBalanceBefore = address(1).balance;

        web3Game.donateToAuthor{value: 1 ether}("Theodora");

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
        web3Game.donateToAuthor("Theodora");
    }

    function test_RevertIf_CircuitBreakerActivated() public {
        web3Game.toggleCircuitBreaker();

        deal(address(1), 2 ether);
        vm.startPrank(address(1));

        vm.expectRevert();
        web3Game.donateToAuthor{value: 1 ether}("Theodora");
    }
}

contract Web3Game2048EmergencyExitTest is Web3Game2048BaseTest {
    error NotAuthorized(address sender);
    error InvalidPercentage();

    function test_EmergencyExit_100() public {
        uint contractBalanceBefore = address(web3Game).balance;
        uint ownerBalanceBefore = address(this).balance;

        web3Game.emergencyExit(100);

        uint contractBalanceAfter = address(web3Game).balance;
        uint ownerBalanceAfter = address(this).balance;

        assertEq(
            contractBalanceBefore - contractBalanceAfter,
            STARTING_PRIZE_POOL
        );
        assertEq(ownerBalanceAfter - ownerBalanceBefore, STARTING_PRIZE_POOL);
    }

    function test_EmergencyExit_50() public {
        uint contractBalanceBefore = address(web3Game).balance;
        uint ownerBalanceBefore = address(this).balance;

        web3Game.emergencyExit(50);

        uint contractBalanceAfter = address(web3Game).balance;
        uint ownerBalanceAfter = address(this).balance;

        assertEq(
            contractBalanceBefore - contractBalanceAfter,
            STARTING_PRIZE_POOL / 2
        );
        assertEq(
            ownerBalanceAfter - ownerBalanceBefore,
            STARTING_PRIZE_POOL / 2
        );
    }

    function test_RevertIf_InvalidPercentage() public {
        vm.startPrank(address(1));
        vm.expectRevert();
        web3Game.emergencyExit(101);
        vm.expectRevert();
        web3Game.emergencyExit(0);
    }

    function test_RevertIf_NotCalledByOwner() public {
        vm.startPrank(address(1));
        vm.expectRevert();
        web3Game.emergencyExit(50);
    }

    function test_RevertIf_CircuitBreakerActivated() public {
        web3Game.toggleCircuitBreaker();
        vm.expectRevert();
        web3Game.emergencyExit(50);
    }
}

contract Web3Game2048CircuitBreakerTest is Web3Game2048BaseTest {
    function test_toggleCircuitBreaker() public {
        assertEq(web3Game.stopped(), false);
        web3Game.toggleCircuitBreaker();
        assertEq(web3Game.stopped(), true);
        web3Game.toggleCircuitBreaker();
        assertEq(web3Game.stopped(), false);
    }

    function test_RevertIf_NotCalledByOwner() public {
        vm.startPrank(address(1));
        vm.expectRevert();
        web3Game.toggleCircuitBreaker();
    }
}

contract Web3Game2048ReceivePrizeTest is Web3Game2048BaseTest {
    function test_ReceiveGrandPrize() public {
        vm.startPrank(address(1));
        deal(address(1), 1 ether);

        uint256 prizePool = web3Game.prizePool();
        uint256 totalPrize = (prizePool *
            modifiedWeb3Game.GRAND_PRIZE_PERCENTAGE()) / 100;
        uint256 commission = (totalPrize *
            modifiedWeb3Game.COMMISSION_PERCENTAGE()) / 100;
        uint256 winnerPrize = totalPrize - commission;

        modifiedWeb3Game.hackGameBoard_PriorToReceiveGrandPrize();

        // _printModifiedGameBoard("BEFORE");
        /*
            Game Board - BEFORE:
            0 0 0 0
            0 2 0 0
            0 0 0 0
            0 0 1024 1024
        */

        modifiedWeb3Game.makeMove(Web3Game2048.Move.RIGHT);

        // _printModifiedGameBoard("AFTER");
        /*
            Game Board - AFTER:
            0 2 0 0
            2 0 0 0
            0 0 0 0
            0 0 0 0
        */

        assertEq(modifiedWeb3Game.moveCount(), 0); // No move has been made after game is reset
        assertEq(_caclulateModifiedGameTilesSum(), 4); // 2 x 2 (Initial Tiles)
        assertEq(modifiedWeb3Game.firstPrizeDistributed(), false);
        assertEq(modifiedWeb3Game.secondPrizeDistributed(), false);
        assertEq(modifiedWeb3Game.thirdPrizeDistributed(), false);
        assertEq(modifiedWeb3Game.winnerPrizeBalance(address(1)), winnerPrize);

        uint256 startingPlayerWalletBalance = address(1).balance;
        modifiedWeb3Game.withdrawWinnerPrize();
        uint256 endingPlayerWalletBalance = address(1).balance;
        assertEq(modifiedWeb3Game.winnerPrizeBalance(address(1)), 0);
        assertEq(
            endingPlayerWalletBalance,
            startingPlayerWalletBalance + winnerPrize
        );

        vm.stopPrank();
        assertEq(modifiedWeb3Game.getCommissionPool(), commission);
        uint256 startingOwnerWalletBalance = address(this).balance;
        modifiedWeb3Game.withdrawCommission();
        uint256 endingOwnerWalletBalance = address(this).balance;
        assertEq(
            endingOwnerWalletBalance,
            startingOwnerWalletBalance + commission
        );
    }
    function test_ReceiveFirstPrize() public {
        vm.startPrank(address(1));
        deal(address(1), 1 ether);

        uint256 prizePool = web3Game.prizePool();
        uint256 totalPrize = (prizePool *
            modifiedWeb3Game.FIRST_PRIZE_PERCENTAGE()) / 100;
        uint256 commission = (totalPrize *
            modifiedWeb3Game.COMMISSION_PERCENTAGE()) / 100;
        uint256 winnerPrize = totalPrize - commission;

        modifiedWeb3Game.hackGameBoard_PriorToReceiveFirstPrize();

        // _printModifiedGameBoard("BEFORE");
        /*
            Game Board - BEFORE:
            0 0 0 0
            0 2 0 0
            0 0 0 0
            0 0 512 512
        */

        modifiedWeb3Game.makeMove(Web3Game2048.Move.RIGHT);

        // _printModifiedGameBoard("AFTER");
        /*
            Game Board - AFTER:
            0 0 0 0
            0 0 2 2
            0 0 0 0
            0 0 0 1024
        */

        assertEq(_modifiedGameTileExists(1024), true);
        assertEq(modifiedWeb3Game.moveCount(), 1); // No move has been made after game is reset
        assertEq(_caclulateModifiedGameTilesSum(), 1028); // 2 x 2 (Initial Tiles)
        assertEq(modifiedWeb3Game.firstPrizeDistributed(), true);
        assertEq(modifiedWeb3Game.secondPrizeDistributed(), false);
        assertEq(modifiedWeb3Game.thirdPrizeDistributed(), false);
        assertEq(modifiedWeb3Game.winnerPrizeBalance(address(1)), winnerPrize);

        uint256 startingPlayerWalletBalance = address(1).balance;
        modifiedWeb3Game.withdrawWinnerPrize();
        uint256 endingPlayerWalletBalance = address(1).balance;
        assertEq(modifiedWeb3Game.winnerPrizeBalance(address(1)), 0);
        assertEq(
            endingPlayerWalletBalance,
            startingPlayerWalletBalance + winnerPrize
        );

        vm.stopPrank();
        assertEq(modifiedWeb3Game.getCommissionPool(), commission);
        uint256 startingOwnerWalletBalance = address(this).balance;
        modifiedWeb3Game.withdrawCommission();
        uint256 endingOwnerWalletBalance = address(this).balance;
        assertEq(
            endingOwnerWalletBalance,
            startingOwnerWalletBalance + commission
        );

        modifiedWeb3Game.hackGameBoard_PriorToReceiveFirstPrize();
        modifiedWeb3Game.makeMove(Web3Game2048.Move.RIGHT);

        assertEq(_modifiedGameTileExists(1024), true);
        assertEq(modifiedWeb3Game.firstPrizeDistributed(), true);
        assertEq(modifiedWeb3Game.winnerPrizeBalance(address(1)), 0);
    }
}
