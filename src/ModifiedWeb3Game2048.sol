// SPDX-License-Identifier: GPL-3.0-only
// @author: Jason Yapri
// @website: https://jasonyapri.com
// @linkedIn: https://linkedin.com/in/jasonyapri
pragma solidity ^0.8.24;

import "./Web3Game2048.sol";

contract ModifiedWeb3Game2048 is Web3Game2048 {
    constructor(address owner) payable Web3Game2048(owner) {}

    function hackGameBoard_PriorToResetGame() external {
        gameBoard[0] = [0, 32, 64, 32];
        gameBoard[1] = [4, 2, 8, 64];
        gameBoard[2] = [64, 32, 16, 8];
        gameBoard[3] = [128, 256, 512, 1024];
    }

    function hackGameBoard_PriorToReceiveSixthPrize() external {
        gameBoard[0] = [0, 0, 0, 0];
        gameBoard[1] = [0, 2, 0, 0];
        gameBoard[2] = [0, 0, 0, 0];
        gameBoard[3] = [0, 0, 16, 16];
    }

    function hackGameBoard_PriorToReceiveFifthPrize() external {
        gameBoard[0] = [0, 0, 0, 0];
        gameBoard[1] = [0, 2, 0, 0];
        gameBoard[2] = [0, 0, 0, 0];
        gameBoard[3] = [0, 0, 32, 32];
    }

    function hackGameBoard_PriorToReceiveFourthPrize() external {
        gameBoard[0] = [0, 0, 0, 0];
        gameBoard[1] = [0, 2, 0, 0];
        gameBoard[2] = [0, 0, 0, 0];
        gameBoard[3] = [0, 0, 64, 64];
    }

    function hackGameBoard_PriorToReceiveThirdPrize() external {
        gameBoard[0] = [0, 0, 0, 0];
        gameBoard[1] = [0, 2, 0, 0];
        gameBoard[2] = [0, 0, 0, 0];
        gameBoard[3] = [0, 0, 128, 128];
    }

    function hackGameBoard_PriorToReceiveSecondPrize() external {
        gameBoard[0] = [0, 0, 0, 0];
        gameBoard[1] = [0, 2, 0, 0];
        gameBoard[2] = [0, 0, 0, 0];
        gameBoard[3] = [0, 0, 256, 256];
    }

    function hackGameBoard_PriorToReceiveFirstPrize() external {
        gameBoard[0] = [0, 0, 0, 0];
        gameBoard[1] = [0, 2, 0, 0];
        gameBoard[2] = [0, 0, 0, 0];
        gameBoard[3] = [0, 0, 512, 512];
    }

    function hackGameBoard_PriorToReceiveGrandPrize() external {
        gameBoard[0] = [0, 0, 0, 0];
        gameBoard[1] = [0, 2, 0, 0];
        gameBoard[2] = [0, 0, 0, 0];
        gameBoard[3] = [0, 0, 1024, 1024];
    }

    function hackCommissionPool(uint256 commission) external {
        commissionPool = commission;
    }

    function hackWinnerPrizeBalance(uint256 prize) external {
        winnerPrizeBalance[msg.sender] = prize;
    }

    function hackSetAllPrizesDistributed() external {
        firstPrizeDistributed = true;
        secondPrizeDistributed = true;
        thirdPrizeDistributed = true;
        fourthPrizeDistributed = true;
        fifthPrizeDistributed = true;
        sixthPrizeDistributed = true;
    }

    function hackSetThreePrizesDistributed() external {
        firstPrizeDistributed = false;
        secondPrizeDistributed = false;
        thirdPrizeDistributed = false;
        fourthPrizeDistributed = true;
        fifthPrizeDistributed = true;
        sixthPrizeDistributed = true;
    }

    function hackPrizePool(uint256 newPrizePool) external {
        prizePool = newPrizePool;
    }
}
