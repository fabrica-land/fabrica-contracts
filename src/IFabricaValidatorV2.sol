// SPDX-License-Identifier: MIT
// Validator smart contract interface for Fabrica

pragma solidity ^0.8.12;

interface IValidator {
    function uri(uint256 id) external view returns (string memory);
    function score(uint256 id) external view returns (uint256);
}
