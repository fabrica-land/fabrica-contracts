// Root file: src/IFabricaValidator.sol

// SPDX-License-Identifier: MIT
// Validator smart contract interface for Fabrica

pragma solidity ^0.8.17;

interface IValidator {
    function uri(uint256 id) external view returns (string memory);
}
