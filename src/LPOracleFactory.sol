// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.25;

import { LPOracle } from "./LPOracle.sol";

/// @title LPOracle Factory
/// @notice Factory contract for deploying LPOracle instances with deterministic addresses
contract LPOracleFactory {
    error OracleAlreadyExists();
    error DeployFailed();

    /// @notice Creation code hash for LPOracle contract
    bytes public constant ORACLE_CREATION_CODE = type(LPOracle).creationCode;

    /// @notice Emitted when a new oracle is deployed
    event OracleDeployed(address indexed pool, address indexed oracle);

    /// @notice Computes the deterministic address for an oracle
    /// @param pool BCoWPool address
    /// @param feed0 Chainlink USD price feed for pool token at index 0
    /// @param feed1 Chainlink USD price feed for pool token at index 1
    /// @return predictedAddress The address where the oracle would be deployed
    /// @return salt The salt used for the deployment
    function computeOracleAddress(
        address pool,
        address feed0,
        address feed1
    )
        public
        view
        returns (address predictedAddress, bytes32 salt)
    {
        salt = keccak256(abi.encodePacked(pool, feed0, feed1));
        bytes memory bytecode = abi.encodePacked(ORACLE_CREATION_CODE, abi.encode(pool, feed0, feed1));

        predictedAddress = address(
            uint160(
                uint256(
                    keccak256(
                        abi.encodePacked(
                            bytes1(0xff), // 0xff prefix
                            address(this), // Factory contract address
                            salt, // Salt
                            keccak256(bytecode) // Hash of the final bytecode
                        )
                    )
                )
            )
        );
    }

    /// @notice Deploys a new LPOracle with a deterministic address
    /// @param pool BCoWPool address
    /// @param feed0 Chainlink USD price feed for pool token at index 0
    /// @param feed1 Chainlink USD price feed for pool token at index 1
    /// @return oracle Address of the newly deployed oracle
    function deployOracle(address pool, address feed0, address feed1) external returns (address oracle) {
        (address oracleAddress, bytes32 salt) = computeOracleAddress(pool, feed0, feed1);

        // Check if there's already code at this address
        if (oracleAddress.code.length > 0) revert OracleAlreadyExists();

        oracle = address(new LPOracle{ salt: salt }(pool, feed0, feed1));

        emit OracleDeployed(pool, oracle);
    }
}
