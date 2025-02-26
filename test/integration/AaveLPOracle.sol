// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.25;

import { LPOracle } from "src/LPOracle.sol";

/// @dev Aave V3 expects asset sources to be AggregateInterface contracts, so this
/// is a workaround for integration testing.
contract AaveLPOracle {
    LPOracle internal lpOracle;

    constructor(address _lpOracle) {
        lpOracle = LPOracle(_lpOracle);
    }

    /// @dev Returns an answer for LP token price with 8 decimals.
    /// Consistent with all USD oracles used in Aave V3.
    function latestAnswer() external view returns (int256) {
        (, int256 answer,,,) = lpOracle.latestRoundData();
        return answer / 1e10;
    }
}
