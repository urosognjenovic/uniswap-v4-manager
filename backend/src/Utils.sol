// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Currency} from "v4-core/types/Currency.sol";

library Utils {
    function sortCurrencies(Currency currency0, Currency currency1) internal pure {
        (currency0, currency1) = currency0 < currency1 ? (currency0, currency1) : (currency1, currency0);
    }
}
