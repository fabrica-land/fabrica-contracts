// SPDX-License-Identifier: MIT
// Validator smart contract for Fabrica version 1.0

pragma solidity ^0.8.21;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "./FabricaUUPSUpgradeable.sol";
import "./IFabricaValidator.sol";

/**
 * @dev Implementation of the Fabrica validator smart contract
 *      Delegates the metadata `uri` function to this contract
 *      May add other fields in newer versions
 */
contract FabricaValidator is IFabricaValidator, Initializable, FabricaUUPSUpgradeable, OwnableUpgradeable {
    using AddressUpgradeable for address;

    constructor() {
        _disableInitializers();
    }

    function initialize() public initializer {
        __Ownable_init();
        __UUPSUpgradeable_init();
    }

    string private _baseUri;

    function setBaseUri(string memory newBaseUri) public onlyOwner {
        _baseUri = newBaseUri;
    }

    function baseUri() public view returns (string memory) {
        return _baseUri;
    }

    function uri(uint256 id) public view returns (string memory) {
        return string.concat(_baseUri, Strings.toString(id));
    }
}
