// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.24;

import "./Web3Game2048.sol";

contract ModifiedWeb3Game2048 is Web3Game2048 {
    constructor() payable Web3Game2048() {}

    function hackGameBoard_ResetGame() external {
        gameBoard[0] = [0, 32, 64, 32];
        gameBoard[1] = [4, 2, 8, 64];
        gameBoard[2] = [64, 32, 16, 8];
        gameBoard[3] = [128, 256, 512, 1024];
    }
}
