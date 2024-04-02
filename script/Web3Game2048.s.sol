// SPDX-License-Identifier: GPL-3.0-only
// @author: Jason Yapri
// @website: https://jasonyapri.com
// @linkedIn: https://linkedin.com/in/jasonyapri
// Contract: Web3 Game - 2048
pragma solidity ^0.8.24;

import {Script, console} from "forge-std/Script.sol";
import {Web3Game2048} from "../src/Web3Game2048.sol";

contract Web3Game2048Script is Script {
    Web3Game2048 web3Game;

    function setUp() public {
        vm.createSelectFork(vm.rpcUrl("optimism_sepolia"));
        // vm.createSelectFork(vm.rpcUrl("optimism_mainnet"));
    }

    function run() public {
        uint256 privateKey = vm.envUint("DEPLOYER_WALLET_PRIVATE_KEY");
        vm.startBroadcast(privateKey);
        web3Game = new Web3Game2048(vm.envAddress("OWNER_WALLET_ADDRESS"));
        vm.stopBroadcast();
    }
}
