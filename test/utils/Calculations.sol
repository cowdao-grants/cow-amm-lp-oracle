// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.25 < 0.9.0;

import { wadMul, wadDiv, wadPow } from "solmate/utils/SignedWadMath.sol";

/// @dev Helper contract for calculations required in testing.
contract Calculations {
    function calcInGivenOutSignedWadMath(
        uint256 tokenBalanceIn,
        uint256 tokenWeightIn,
        uint256 tokenBalanceOut,
        uint256 tokenWeightOut,
        uint256 tokenAmountOut
    )
        internal
        pure
        returns (uint256)
    {
        int256 exponent = wadDiv(int256(tokenWeightOut), int256(tokenWeightIn));
        return uint256(
            wadMul(
                int256(tokenBalanceIn),
                wadPow(wadDiv(int256(tokenBalanceOut), int256(tokenBalanceOut - tokenAmountOut)), exponent) - 1e18
            )
        );
    }

    function calcOutGivenInSignedWadMath(
        uint256 tokenBalanceIn,
        uint256 tokenWeightIn,
        uint256 tokenBalanceOut,
        uint256 tokenWeightOut,
        uint256 tokenAmountIn
    )
        internal
        pure
        returns (uint256)
    {
        int256 exponent = wadDiv(int256(tokenWeightIn), int256(tokenWeightOut));
        return uint256(
            wadMul(
                int256(tokenBalanceOut),
                wadPow(1e18 - wadDiv(int256(tokenBalanceIn), int256(tokenBalanceIn + tokenAmountIn)), exponent)
            )
        );
    }

    function calculateNaivePrice(
        uint8 feed0Decimals,
        uint8 feed1Decimals,
        int256 answer0,
        int256 answer1,
        uint256 token0Balance,
        uint256 token1Balance
    )
        internal
        pure
        returns (uint256)
    {
        if (feed0Decimals == feed1Decimals) {
            return (token0Balance * uint256(answer0) + token1Balance * uint256(answer1)) / 1e18;
        } else {
            return (
                token0Balance * uint256(answer0) * 10 ** (18 - feed0Decimals)
                    + token1Balance * uint256(answer1) * 10 ** (18 - feed1Decimals)
            ) / 1e18;
        }
    }
}
