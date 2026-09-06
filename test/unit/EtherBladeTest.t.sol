// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {EtherBlade} from "../../src/EtherBlade.sol";
import {DeployEtherBlade} from "../../script/DeployEtherBlade.s.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {stdStorage, StdStorage} from "forge-std/StdStorage.sol";

contract EtherBladeTest is Test {
    using stdStorage for StdStorage;

    EtherBlade public blade;
    HelperConfig public helperConfig;

    address public owner;
    address public player = makeAddr("player");

    function setUp() public {
        DeployEtherBlade deployer = new DeployEtherBlade();
        (blade, helperConfig) = deployer.run();
        owner = blade.owner();
    }

    // =============================================================
    //                       MINT TESTS
    // =============================================================

    function test_InitialStateAndMint() public {
        assertEq(blade.name(), "EtherBlade On-Chain");
        assertEq(blade.symbol(), "EBLADE");
        assertEq(blade.getTokenCounter(), 0);

        vm.prank(player);
        blade.mintBlade();

        assertEq(blade.ownerOf(0), player);
        assertEq(blade.getTokenCounter(), 1);

        EtherBlade.BladeStats memory stats = blade.getStats(0);
        assertEq(stats.level, 1);
        assertEq(stats.attackPower, 10);
    }

    // =============================================================
    //                      TRAINING TESTS
    // =============================================================

    function test_TrainBladeSuccess() public {
        vm.prank(player);
        blade.mintBlade();

        vm.prank(player);
        blade.trainBlade(0);

        EtherBlade.BladeStats memory stats = blade.getStats(0);
        assertEq(stats.level, 2);
        assertEq(stats.attackPower, 25);
    }

    function test_TrainBladeRevertsIfNotOwner() public {
        vm.prank(player);
        blade.mintBlade();

        address hacker = makeAddr("hacker");
        vm.prank(hacker);
        vm.expectRevert(EtherBlade.EtherBlade__NotTokenOwner.selector);
        blade.trainBlade(0);
    }

    function test_TrainBladeRevertsForNonExistentToken() public {
        vm.prank(player);
        vm.expectRevert(EtherBlade.EtherBlade__TokenDoesNotExist.selector);
        blade.trainBlade(999);
    }

    function test_TrainBladeRevertsWhenMaxLevelReached() public {
        vm.prank(player);
        blade.mintBlade();

        // Level up to 100 via stdstore or loop
        // We'll train 99 times to reach level 100
        vm.startPrank(player);
        for (uint256 i = 0; i < 99; i++) {
            blade.trainBlade(0);
        }

        EtherBlade.BladeStats memory stats = blade.getStats(0);
        assertEq(stats.level, 100);

        // 101st train attempt reverts
        vm.expectRevert(EtherBlade.EtherBlade__MaxLevelReached.selector);
        blade.trainBlade(0);
        vm.stopPrank();
    }

    // =============================================================
    //                 URI & VISUAL TIER TESTS
    // =============================================================

    function test_TokenURIRevertsForNonExistentToken() public {
        vm.expectRevert(EtherBlade.EtherBlade__TokenDoesNotExist.selector);
        blade.tokenURI(999);
    }

    function test_GetStatsRevertsForNonExistentToken() public {
        vm.expectRevert(EtherBlade.EtherBlade__TokenDoesNotExist.selector);
        blade.getStats(999);
    }

    function test_NoviceTierVisualsAndMetadata() public {
        vm.prank(player);
        blade.mintBlade(); // Level 1

        string memory uri = blade.tokenURI(0);
        assertTrue(bytes(uri).length > 0);

        string memory svg = blade.generateSVG(0);
        assertTrue(bytes(svg).length > 0);
    }

    function test_AdeptTierVisualsAndMetadata() public {
        vm.prank(player);
        blade.mintBlade();

        // Train 9 times -> Level 10 (Adept)
        vm.startPrank(player);
        for (uint256 i = 0; i < 9; i++) {
            blade.trainBlade(0);
        }
        vm.stopPrank();

        EtherBlade.BladeStats memory stats = blade.getStats(0);
        assertEq(stats.level, 10);

        string memory uri = blade.tokenURI(0);
        assertTrue(bytes(uri).length > 0);
    }

    function test_LegendaryTierVisualsAndMetadata() public {
        vm.prank(player);
        blade.mintBlade();

        // Train 19 times -> Level 20 (Legendary)
        vm.startPrank(player);
        for (uint256 i = 0; i < 19; i++) {
            blade.trainBlade(0);
        }
        vm.stopPrank();

        EtherBlade.BladeStats memory stats = blade.getStats(0);
        assertEq(stats.level, 20);

        string memory uri = blade.tokenURI(0);
        assertTrue(bytes(uri).length > 0);
    }
}
