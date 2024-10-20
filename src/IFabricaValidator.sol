// SPDX-License-Identifier: MIT
// Validator smart contract interface for Fabrica

pragma solidity ^0.8.28;

interface IFabricaValidator {
    function defaultOperatingAgreement() external view returns (string memory);
    function operatingAgreementName(string memory uri_) external view returns (string memory);
    function uri(uint256 id) external view returns (string memory);
}
