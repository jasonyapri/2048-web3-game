// SPDX-License-Identifier: GPL-3.0-only
// @author: Jason Yapri
// @website: https://jasonyapri.com
// @linkedIn: https://linkedin.com/in/jasonyapri
// @version: 0.1.1 2024.03.12
// Contract: Web3 Game - 2048
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import {Web3Game2048} from "../src/Web3Game2048.sol";

contract Web3Game2048BaseTest is Test {
    Web3Game2048 public web3Game;

    function setUp() public {
        web3Game = new Web3Game2048();
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
}
