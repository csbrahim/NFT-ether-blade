// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";

contract HelperConfig is Script {
    struct NetworkConfig {
        address deployer;
    }

    NetworkConfig public activeNetworkConfig;

    address public constant ANVIL_DEFAULT_ACCOUNT =
        0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaConfig();
        } else {
            activeNetworkConfig = getOrCreateAnvilConfig();
        }
    }

    function getSepoliaConfig() public pure returns (NetworkConfig memory) {
        return
            NetworkConfig({
                deployer: 0xadeBd71604AC927D0ca67BDd99a3f9127192aeC9
            });
    }

    function getOrCreateAnvilConfig()
        public
        pure
        returns (NetworkConfig memory)
    {
        return NetworkConfig({deployer: ANVIL_DEFAULT_ACCOUNT});
    }

    function getConfig() external view returns (NetworkConfig memory) {
        return activeNetworkConfig;
    }
}
