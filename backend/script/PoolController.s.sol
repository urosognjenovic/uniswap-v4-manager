// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Script} from "forge-std/Script.sol";
import {PoolController} from "../src/PoolController.sol";
import {HelperDeploy} from "./HelperDeploy.s.sol";

contract DeployPoolController is Script {
    PoolController private s_poolController;
    HelperDeploy private s_helperDeploy;
    address private s_poolManager;
    address private s_positionManager;
    address private s_permit2;

    function run() external returns (PoolController) {
        s_helperDeploy = new HelperDeploy();
        (s_poolManager, s_positionManager, s_permit2) = s_helperDeploy.s_helperConfig();
        vm.startBroadcast();
        s_poolController =
            new PoolController({poolManager: s_poolManager, positionManager: s_positionManager, permit2: s_permit2});
        vm.stopBroadcast();
        return s_poolController;
    }
}
