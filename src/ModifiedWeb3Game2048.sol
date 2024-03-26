// SPDX-License-Identifier: GPL-3.0-only
// @author: Jason Yapri
// @website: https://jasonyapri.com
// @linkedIn: https://linkedin.com/in/jasonyapri
pragma solidity ^0.8.24;

import "./Web3Game2048.sol";

contract ModifiedWeb3Game2048 is Web3Game2048 {
    constructor(address owner) payable Web3Game2048(owner) {}

    function hackGameBoard_ResetGame() external {
        gameBoard[0] = [0, 32, 64, 32];
        gameBoard[1] = [4, 2, 8, 64];
        gameBoard[2] = [64, 32, 16, 8];
        gameBoard[3] = [128, 256, 512, 1024];
    }
}
