// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {PoolKey, Currency, IHooks} from "v4-core/types/PoolKey.sol";
import {IPoolManager} from "v4-core/interfaces/IPoolManager.sol";
import {IPositionManager} from "v4-periphery/interfaces/IPositionManager.sol";

contract PoolController {
    function createPool(
        Currency currency0,
        Currency currency1,
        uint24 fee,
        int24 tickSpacing,
        IHooks hooks,
        address poolManager,
        uint160 startingPrice
    ) external {
        PoolKey memory pool =
            PoolKey({currency0: currency0, currency1: currency1, fee: fee, tickSpacing: tickSpacing, hooks: hooks});

        IPoolManager(poolManager).initialize(pool, startingPrice);
    }
}
