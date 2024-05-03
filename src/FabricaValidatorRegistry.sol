// SPDX-License-Identifier: MIT

pragma solidity ^0.8.25;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/utils/introspection/ERC165Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/introspection/ERC165CheckerUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import "./FabricaUUPSUpgradeable.sol";
import "./IFabricaValidatorRegistry.sol";

contract FabricaValidatorRegistry is IFabricaValidatorRegistry, Initializable, IERC165Upgradeable, ERC165Upgradeable, OwnableUpgradeable, FabricaUUPSUpgradeable {
    using AddressUpgradeable for address;

    constructor() {
        _disableInitializers();
    }

    function initialize() public initializer {
        __ERC165_init();
        __FabricaUUPSUpgradeable_init();
        __Ownable_init();
    }

    mapping(address => string) private _names;

    event ValidatorNameUpdated(address addr, string name);

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165Upgradeable, IERC165Upgradeable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function addName(address addr, string memory name_) public onlyOwner {
        require(bytes(_names[addr]).length < 1, "Validator name record for addr already exists");
        require(bytes(name_).length > 0, "name_ is required");
        _names[addr] = name_;
        emit ValidatorNameUpdated(addr, name_);
    }

    function removeName(address addr) public onlyOwner {
        require(bytes(_names[addr]).length > 0, "Validator name record for addr does not exist");
        delete _names[addr];
        emit ValidatorNameUpdated(addr, "");
    }

    function updateName(address addr, string memory name_) public onlyOwner {
        require(bytes(_names[addr]).length > 0, "Validator name record for addr does not exist");
        require(bytes(name_).length > 0, "Use removeValidatorName");
        _names[addr] = name_;
        emit ValidatorNameUpdated(addr, name_);
    }

    function name(address addr) public view returns (string memory) {
        return _names[addr];
    }
}
