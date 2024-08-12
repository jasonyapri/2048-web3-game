// SPDX-License-Identifier: GPL-3.0-only
// @author: Jason Yapri
// @website: https://jasonyapri.com
// @linkedIn: https://linkedin.com/in/jasonyapri
pragma solidity ^0.8.24;

import {Script, console} from "forge-std/Script.sol";
import {Counter} from "../src/Counter.sol";

contract CounterScript is Script {
    Counter counter;

    function setUp() public {
        vm.createSelectFork(vm.rpcUrl("optimism_sepolia"));
        // vm.createSelectFork(vm.rpcUrl("optimism_mainnet"));
        // vm.createSelectFork(vm.rpcUrl("manta_sepolia"));
    }

    function run() public {
        uint256 privateKey = vm.envUint("DEPLOYER_WALLET_PRIVATE_KEY");
        vm.startBroadcast(privateKey);
        counter = new Counter();
        vm.stopBroadcast();
    }
}
