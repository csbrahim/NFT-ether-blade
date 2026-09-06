// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {EtherBlade} from "../../src/EtherBlade.sol";
import {DeployEtherBlade} from "../../script/DeployEtherBlade.s.sol";
import {MintBladeScript, TrainBladeScript} from "../../script/Interactions.s.sol";

contract InteractionsTest is Test {
    EtherBlade public blade;

    function setUp() public {
        DeployEtherBlade deployer = new DeployEtherBlade();
        (blade,) = deployer.run();
    }

    function test_ScriptInteractions_MintAndTrain() public {
        // Step 1: Mint via script
        MintBladeScript mintScript = new MintBladeScript();
        mintScript.mintBlade(address(blade));

        assertEq(blade.balanceOf(DEFAULT_SENDER), 1);

        // Step 2: Train via script
        TrainBladeScript trainScript = new TrainBladeScript();
        trainScript.trainBlade(address(blade), 0);

        EtherBlade.BladeStats memory stats = blade.getStats(0);
        assertEq(stats.level, 2);
    }
}
