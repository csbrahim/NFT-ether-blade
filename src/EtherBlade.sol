// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC721} from "openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import {Ownable} from "openzeppelin-contracts/contracts/access/Ownable.sol";
import {Base64} from "openzeppelin-contracts/contracts/utils/Base64.sol";
import {Strings} from "openzeppelin-contracts/contracts/utils/Strings.sol";

contract EtherBlade is ERC721, Ownable {
    using Strings for uint256;

    // =============================================================
    //                           ERRORS
    // =============================================================
    error EtherBlade__TokenDoesNotExist();
    error EtherBlade__NotTokenOwner();
    error EtherBlade__MaxLevelReached();

    // =============================================================
    //                      STATE VARIABLES
    // =============================================================
    uint256 private s_tokenCounter;

    struct BladeStats {
        uint256 level;
        uint256 attackPower;
    }

    mapping(uint256 => BladeStats) private s_tokenIdToStats;

    // =============================================================
    //                           EVENTS
    // =============================================================
    event BladeMinted(address indexed owner, uint256 indexed tokenId);
    event BladeLeveledUp(
        uint256 indexed tokenId,
        uint256 newLevel,
        uint256 newAttackPower
    );

    // =============================================================
    //                        CONSTRUCTOR
    // =============================================================
    constructor() ERC721("EtherBlade On-Chain", "EBLADE") Ownable(msg.sender) {
        s_tokenCounter = 0;
    }

    // =============================================================
    //                      GAMEPLAY FUNCTIONS
    // =============================================================

    /// @notice Mints a new Level 1 EtherBlade
    function mintBlade() external {
        uint256 tokenId = s_tokenCounter;
        s_tokenCounter++;

        s_tokenIdToStats[tokenId] = BladeStats({level: 1, attackPower: 10});

        _safeMint(msg.sender, tokenId);
        emit BladeMinted(msg.sender, tokenId);
    }

    /// @notice Allows the blade owner to train and level up their blade
    function trainBlade(uint256 tokenId) external {
        if (_ownerOf(tokenId) == address(0)) {
            revert EtherBlade__TokenDoesNotExist();
        }
        if (ownerOf(tokenId) != msg.sender) {
            revert EtherBlade__NotTokenOwner();
        }

        BladeStats storage stats = s_tokenIdToStats[tokenId];
        if (stats.level >= 100) {
            revert EtherBlade__MaxLevelReached();
        }

        stats.level += 1;
        stats.attackPower += 15;

        emit BladeLeveledUp(tokenId, stats.level, stats.attackPower);
    }

    // =============================================================
    //                    DYNAMIC SVG GENERATION
    // =============================================================

    /// @notice Generates raw SVG string based on current stats
    function generateSVG(uint256 tokenId) public view returns (string memory) {
        BladeStats memory stats = s_tokenIdToStats[tokenId];

        string memory bladeColor;
        string memory glowColor;
        string memory rankTitle;

        if (stats.level < 10) {
            bladeColor = "#C0C0C0"; // Silver
            glowColor = "#808080";
            rankTitle = "Novice";
        } else if (stats.level < 20) {
            bladeColor = "#00E5FF"; // Radiant Cyan
            glowColor = "#0088FF";
            rankTitle = "Adept";
        } else {
            bladeColor = "#FFD700"; // Legendary Gold
            glowColor = "#FF4500";
            rankTitle = "Legendary";
        }

        return
            string.concat(
                '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 400 400" width="100%" height="100%">',
                '<rect width="400" height="400" fill="#0A0A1A"/>',
                // Glow Filter
                '<defs><filter id="glow"><feGaussianBlur stdDeviation="6" result="coloredBlur"/>',
                '<feMerge><feMergeNode in="coloredBlur"/><feMergeNode in="SourceGraphic"/></feMerge></filter></defs>',
                // Blade Geometry
                '<path d="M200 40 L215 260 L200 280 L185 260 Z" fill="',
                bladeColor,
                '" filter="url(#glow)"/>',
                '<path d="M200 40 L200 270" stroke="',
                glowColor,
                '" stroke-width="3"/>',
                // Guard & Hilt
                '<rect x="160" y="275" width="80" height="12" rx="4" fill="#555"/>',
                '<rect x="193" y="287" width="14" height="50" rx="2" fill="#333"/>',
                '<circle cx="200" cy="345" r="10" fill="',
                bladeColor,
                '"/>',
                // Text UI Overlay
                '<text x="200" y="375" text-anchor="middle" fill="#FFF" font-family="monospace" font-size="16" font-weight="bold">',
                rankTitle,
                " | Level ",
                stats.level.toString(),
                "</text></svg>"
            );
    }

    // =============================================================
    //                  ON-CHAIN TOKEN URI (JSON)
    // =============================================================

    function tokenURI(
        uint256 tokenId
    ) public view override returns (string memory) {
        if (_ownerOf(tokenId) == address(0)) {
            revert EtherBlade__TokenDoesNotExist();
        }

        BladeStats memory stats = s_tokenIdToStats[tokenId];

        string memory rankTitle;
        if (stats.level < 10) rankTitle = "Novice";
        else if (stats.level < 20) rankTitle = "Adept";
        else rankTitle = "Legendary";

        // 1. Build raw SVG and encode to base64 image data URI
        string memory svg = generateSVG(tokenId);
        string memory imageURI = string.concat(
            "data:image/svg+xml;base64,",
            Base64.encode(bytes(svg))
        );

        // 2. Build OpenSea-compliant JSON metadata
        bytes memory jsonBytes = abi.encodePacked(
            '{"name": "EtherBlade #',
            tokenId.toString(),
            '", ',
            '"description": "100% On-Chain Dynamic GameFi Weapon that levels up through smart contract interactions.", ',
            '"attributes": [',
            '{"trait_type": "Rank", "value": "',
            rankTitle,
            '"}, ',
            '{"trait_type": "Level", "value": ',
            stats.level.toString(),
            "}, ",
            '{"trait_type": "Attack Power", "value": ',
            stats.attackPower.toString(),
            "}",
            "], ",
            '"image": "',
            imageURI,
            '"}'
        );

        // 3. Encode full JSON as base64 data URI
        return
            string.concat(
                "data:application/json;base64,",
                Base64.encode(jsonBytes)
            );
    }

    // =============================================================
    //                      VIEW FUNCTIONS
    // =============================================================

    function getStats(
        uint256 tokenId
    ) external view returns (BladeStats memory) {
        if (_ownerOf(tokenId) == address(0)) {
            revert EtherBlade__TokenDoesNotExist();
        }
        return s_tokenIdToStats[tokenId];
    }

    function getTokenCounter() external view returns (uint256) {
        return s_tokenCounter;
    }
}
