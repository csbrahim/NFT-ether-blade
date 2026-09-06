// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {EtherBlade} from "../src/EtherBlade.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployEtherBlade is Script {
    function run() external returns (EtherBlade, HelperConfig) {
        HelperConfig helperConfig = new HelperConfig();

        vm.startBroadcast();
        EtherBlade blade = new EtherBlade();
        vm.stopBroadcast();

        console.log("EtherBlade deployed at:", address(blade));
        return (blade, helperConfig);
    }
}
