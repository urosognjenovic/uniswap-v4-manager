// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Script} from "forge-std/Script.sol";
import {PoolController} from "../src/PoolController.sol";
import {DevOpsTools} from "foundry-devops/DevOpsTools.sol";

contract CreatePool is Script {
    PoolController private s_poolController;

    function run(
        address token0Address,
        address token1Address,
        uint24 fee,
        int24 tickSpacing,
        address hooksAddress,
        uint160 startingPrice
    ) external {
        address contractAddress = DevOpsTools.get_most_recent_deployment("PoolController", block.chainid);
        s_poolController = PoolController(contractAddress);

        vm.startBroadcast();
        s_poolController.createPool(token0Address, token1Address, fee, tickSpacing, hooksAddress, startingPrice);
        vm.stopBroadcast();
    }
}
