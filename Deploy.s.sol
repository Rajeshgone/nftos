// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/NFTOS.sol";

/// @notice Deploys NFTOS to Base Mainnet.
/// Usage:
///   forge script script/Deploy.s.sol:Deploy \
///     --rpc-url $BASE_RPC_URL \
///     --broadcast \
///     --verify \
///     --etherscan-api-key $BASESCAN_API_KEY
contract Deploy is Script {
    // Set your desired max supply here before deploying (0 = unlimited)
    uint256 constant MAX_SUPPLY = 10_000;

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);

        vm.startBroadcast(deployerPrivateKey);

        // royaltyReceiver = deployer wallet (as decided)
        NFTOS nftos = new NFTOS(deployer);
        nftos.setMaxSupply(MAX_SUPPLY);

        vm.stopBroadcast();

        console.log("NFTOS deployed at:", address(nftos));
        console.log("Owner / royalty receiver:", deployer);
        console.log("Max supply:", MAX_SUPPLY);
    }
}
