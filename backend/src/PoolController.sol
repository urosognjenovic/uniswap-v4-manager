// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {PoolKey, Currency, IHooks} from "v4-core/types/PoolKey.sol";
import {IPoolManager} from "v4-core/interfaces/IPoolManager.sol";
import {IPositionManager} from "v4-periphery/interfaces/IPositionManager.sol";
import {Actions} from "v4-periphery/libraries/Actions.sol";
import {IPermit2} from "permit2/src/interfaces/IPermit2.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IAllowanceTransfer} from "permit2/src/interfaces/IAllowanceTransfer.sol";

contract PoolController {
    IPoolManager private immutable i_poolManager;
    IPositionManager private immutable i_positionManager;
    IPermit2 private immutable i_permit2;

    constructor(address poolManager, address positionManager, address permit2) {
        i_poolManager = IPoolManager(poolManager);
        i_positionManager = IPositionManager(positionManager);
        i_permit2 = IPermit2(permit2);
    }

    function createPool(
        address token0Address,
        address token1Address,
        uint24 fee,
        int24 tickSpacing,
        address hooksAddress,
        uint160 startingPrice
    ) external {
        PoolKey memory poolKey = getPoolKey(token0Address, token1Address, fee, tickSpacing, hooksAddress);
        // TODO Sort the currencies
        // TODO Add support for native currency

        i_poolManager.initialize(poolKey, startingPrice);
    }

    function createPoolAndAddLiquidity(
        address token0Address,
        address token1Address,
        uint24 fee,
        int24 tickSpacing,
        address hooksAddress,
        uint160 startingPrice,
        int24 tickLower,
        int24 tickUpper,
        uint256 liquidity,
        uint128 amount0Max,
        address recipient,
        bytes memory hookData
    ) external {
        // TODO Sort the currencies
        // TODO Add support for native currency
        PoolKey memory poolKey = getPoolKey(token0Address, token1Address, fee, tickSpacing, hooksAddress);

        bytes[] memory params = encodeCreatePoolAndAddLiquidityMulticall(
            poolKey, startingPrice, tickLower, tickUpper, liquidity, amount0Max, recipient, hookData
        );

        approvePermit2AndAllowanceTransfer(token0Address);
        approvePermit2AndAllowanceTransfer(token1Address);

        i_positionManager.multicall(params);
        // TODO Add support for native currency
        // i_positionManager.multicall{value: valueToSend}(params);
    }

    function encodeCreatePoolAndAddLiquidityMulticall(
        PoolKey memory poolKey,
        uint160 startingPrice,
        int24 tickLower,
        int24 tickUpper,
        uint256 liquidity,
        uint128 amount0Max,
        address recipient,
        bytes memory hookData
    ) internal view returns (bytes[] memory) {
        bytes[] memory params = new bytes[](2);
        params[0] = abi.encodeWithSelector(i_positionManager.initializePool.selector, poolKey, startingPrice);

        bytes memory actions = abi.encodePacked(uint8(Actions.MINT_POSITION), uint8(Actions.SETTLE_PAIR));
        bytes[] memory mintParams = new bytes[](2);
        mintParams[0] = abi.encode(poolKey, tickLower, tickUpper, liquidity, amount0Max, recipient, hookData);
        mintParams[1] = abi.encode(poolKey.currency0, poolKey.currency1);
        uint256 deadline = block.timestamp + 60;
        params[1] = abi.encodeWithSelector(
            i_positionManager.modifyLiquidities.selector, abi.encode(actions, mintParams), deadline
        );

        return params;
    }

    function approvePermit2AndAllowanceTransfer(address token) internal {
        IERC20(token).approve(address(i_permit2), type(uint256).max);
        IAllowanceTransfer(address(i_permit2)).approve(
            token, address(i_positionManager), type(uint160).max, type(uint48).max
        );
    }

    function getPoolKey(
        address token0Address,
        address token1Address,
        uint24 fee,
        int24 tickSpacing,
        address hooksAddress
    ) internal pure returns (PoolKey memory poolKey) {
        Currency currency0 = Currency.wrap(token0Address);
        Currency currency1 = Currency.wrap(token1Address);
        IHooks hooks = IHooks(hooksAddress);

        return PoolKey({currency0: currency0, currency1: currency1, fee: fee, tickSpacing: tickSpacing, hooks: hooks});
    }
}
