// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";

contract HelperConfigTest is Test {
    function test_AnvilConfigDefault() public {
        HelperConfig config = new HelperConfig();
        HelperConfig.NetworkConfig memory netConfig = config.getConfig();
        assertEq(netConfig.deployer, config.ANVIL_DEFAULT_ACCOUNT());
    }

    function test_SepoliaConfigDirect() public {
        vm.chainId(11155111);
        HelperConfig config = new HelperConfig();
        HelperConfig.NetworkConfig memory netConfig = config.getConfig();
        assertEq(netConfig.deployer, 0xadeBd71604AC927D0ca67BDd99a3f9127192aeC9);
    }
}
