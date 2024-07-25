// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

interface IFabricaValidatorRegistry {
    function name(address addr) external view returns (string memory);
}
