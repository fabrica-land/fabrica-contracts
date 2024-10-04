// SPDX-License-Identifier: MIT

pragma solidity ^0.8.27;

import {ERC1967Utils} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Utils.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {ContextUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";

abstract contract FabricaUUPSUpgradeable is Initializable, ContextUpgradeable, UUPSUpgradeable {
    function __FabricaUUPSUpgradeable_init() internal onlyInitializing {
        __Context_init();
        __UUPSUpgradeable_init();
    }

    function __FabricaUUPSUpgradeable_init_unchained() internal onlyInitializing {
        __Context_init();
        __UUPSUpgradeable_init_unchained();
    }

    function _authorizeUpgrade(address) internal view override {
        _checkProxyAdmin();
    }

    function implementation() public view returns (address) {
        return ERC1967Utils.getImplementation();
    }

    /**
     * @dev Throws if called by any account other than the proxy admin
     */
    modifier onlyProxyAdmin() {
        _checkProxyAdmin();
        _;
    }

    /**
     * @dev Throws if the sender is not the proxy admin.
     */
    function _checkProxyAdmin() internal view virtual {
        require(ERC1967Utils.getAdmin() == _msgSender(), "FabricaUUPSUpgradeable: caller is not the proxy admin");
    }

    /**
     * @dev Returns the current proxy admin address.
     */
    function proxyAdmin() public view returns (address) {
        return ERC1967Utils.getAdmin();
    }

    /**
     * @dev Updates the current admin address.
     */
    function setProxyAdmin(address _newProxyAdmin) public onlyProxyAdmin {
        // _setAdmin() doesn't emit the Upgraded event; _changeAdmin() does.
        ERC1967Utils.changeAdmin(_newProxyAdmin);
    }
}
