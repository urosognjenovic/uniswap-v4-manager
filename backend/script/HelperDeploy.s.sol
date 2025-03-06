// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Script} from "forge-std/Script.sol";

contract HelperDeploy is Script {
    struct HelperConfig {
        address poolManager;
        address positionManager;
        address permit2;
    }

    HelperConfig public s_helperConfig;

    constructor() {
        if (block.chainid == 1) {
            s_helperConfig = getETHMainnetConfig();
        } else if (block.chainid == 11155111) {
            s_helperConfig = getETHSepoliaConfig();
        } else if (block.chainid == 31337) {
            s_helperConfig = getLocalETHConfig();
        }
    }

    function getETHMainnetConfig() public pure returns (HelperConfig memory) {
        return HelperConfig({
            poolManager: 0x000000000004444c5dc75cB358380D2e3dE08A90,
            positionManager: 0xbD216513d74C8cf14cf4747E6AaA6420FF64ee9e,
            permit2: 0x000000000022D473030F116dDEE9F6B43aC78BA3
        });
    }

    function getETHSepoliaConfig() public pure returns (HelperConfig memory) {
        return HelperConfig({
            poolManager: 0xE03A1074c86CFeDd5C142C4F04F1a1536e203543,
            positionManager: 0x429ba70129df741B2Ca2a85BC3A2a3328e5c09b4,
            permit2: 0x000000000022D473030F116dDEE9F6B43aC78BA3
        });
    }

    // TODO
    function getLocalETHConfig() public pure returns (HelperConfig memory) {}
}
