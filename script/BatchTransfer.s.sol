// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.24;

import {Script, console} from "forge-std/Script.sol";

contract BatchTransferScript is Script {
    address[] recipients;

    function setUp() public {
        // vm.createSelectFork(vm.rpcUrl("optimism_sepolia"));
        // vm.createSelectFork(vm.rpcUrl("optimism_mainnet"));
        // vm.createSelectFork(vm.rpcUrl("manta_sepolia"));
        vm.createSelectFork(vm.rpcUrl("lisk_sepolia"));
    }

    function addRecipients() public {
        recipients.push(0x79EA174C1Fa59fa765308Cd31B6Bb9A889F12F0a);
        recipients.push(0x34D65601c602c0A379122F0d9aFAdD8F54b8b708);
    }

    function run() public {
        uint256 privateKey = vm.envUint("DEPLOYER_WALLET_PRIVATE_KEY");
        vm.startBroadcast(privateKey);

        addRecipients();

        for (uint256 i = 0; i < recipients.length; i++) {
            (bool success, ) = payable(recipients[i]).call{
                value: 0.00002 ether
            }("");
            require(success, "Transfer failed.");
        }

        vm.stopBroadcast();
    }
}
