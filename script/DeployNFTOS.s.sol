// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/Contract.sol";

contract DeployNFTOS is Script {
    function run() external {
        vm.startBroadcast();

        NFTOS nftos = new NFTOS();
        
        console.log("==================================");
        console.log("NFTOS deployed successfully!");
        console.log("Contract Address:", address(nftos));
        console.log("==================================");

        vm.stopBroadcast();
    }
}
