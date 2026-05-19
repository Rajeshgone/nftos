// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/NFTOS.sol";

contract DeployNFTOS is Script {
    function run() external {
        vm.startBroadcast();

        NFTOS nftos = new NFTOS();
        console.log("NFTOS deployed at:", address(nftos));

        vm.stopBroadcast();
    }
}
