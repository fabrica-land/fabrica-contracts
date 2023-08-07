// SPDX-License-Identifier: MIT
// Validator smart contract for Fabrica version 1.0

pragma solidity ^0.8.21;

import "@openzeppelin/contracts/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "./IFabricaValidator.sol";

/**
 * @dev Implementation of the Fabrica validator smart contract
 *      Delegates the metadata `uri` function to this contract
 *      May add other fields in newer versions
 */
contract FabricaValidator is IFabricaValidator, UUPSUpgradeable, Initializable, OwnableUpgradeable {

    string private _baseUri;

    function initialize() public initializer {
        __Ownable_init();
    }

    function _authorizeUpgrade(address) internal view override {
        // Check if the caller matches the admin address of the ERC1967Proxy contract.
        require(msg.sender == _getAdmin(), "Only the proxy admin can authorize upgrades.");
    }

    function getImplementation() public view returns (address) {
        return _getImplementation();
    }

    /**
     * @dev Returns the current admin address.
     */
    function getAdmin() public view returns (address) {
        return ERC1967Upgrade._getAdmin();
    }

    /**
     * @dev Updates the current admin address.
     */
    function changeAdmin(address _newAdmin) public {
        // Check if the caller matches the admin address of the ERC1967Proxy contract.
        require(msg.sender == _getAdmin(), "Only the proxy admin can change the proxy admin.");
        ERC1967Upgrade._changeAdmin(_newAdmin);
    }

    function setBaseUri(string memory baseUri) public onlyOwner {
        _baseUri = baseUri;
    }

    function uri(uint256 id) public view returns (string memory) {
        return string.concat(_baseUri, Strings.toString(id));
    }
}
