// SPDX-License-Identifier: MIT
// Validator smart contract interface for Fabrica

pragma solidity ^0.8.23;

interface IFabricaValidator {
    function uri(uint256 id) external view returns (string memory);
}
