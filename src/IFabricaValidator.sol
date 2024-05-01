// SPDX-License-Identifier: MIT
// Validator smart contract interface for Fabrica

pragma solidity ^0.8.25;

interface IFabricaValidator {
    function operatingAgreementName(string memory uri_) external view returns (string memory);
    function uri(uint256 id) external view returns (string memory);
}
