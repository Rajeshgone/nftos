// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/Contract.sol";   // Keep this as it is

contract DeployNFTOS is Script {
    function run() external {
        vm.startBroadcast();

        // Correct way - specify full path + contract name
        NFTOS nftos = new NFTOS();

        console.log("=====================================");
        console.log("✅ NFTOS Deployed Successfully!");
        console.log("📍 Contract Address:", address(nftos));
        console.log("=====================================");

        vm.stopBroadcast();
    }
}
