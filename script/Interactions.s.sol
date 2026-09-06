// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {EtherBlade} from "../src/EtherBlade.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";

/// @notice Script to mint a new EtherBlade on the latest deployment
contract MintBladeScript is Script {
    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("EtherBlade", block.chainid);
        mintBlade(mostRecentlyDeployed);
    }

    function mintBlade(address contractAddress) public {
        vm.startBroadcast();
        EtherBlade(contractAddress).mintBlade();
        vm.stopBroadcast();
        console.log("Minted EtherBlade from contract:", contractAddress);
    }
}

/// @notice Script to train/level up an existing EtherBlade
contract TrainBladeScript is Script {
    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("EtherBlade", block.chainid);
        trainBlade(mostRecentlyDeployed, 0);
    }

    function trainBlade(address contractAddress, uint256 tokenId) public {
        vm.startBroadcast();
        EtherBlade(contractAddress).trainBlade(tokenId);
        vm.stopBroadcast();
        console.log("Trained EtherBlade #", tokenId);
    }
}
