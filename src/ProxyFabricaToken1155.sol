// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (proxy/Proxy.sol)

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/proxy/Proxy.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Upgrade.sol";

contract FabricaToken1155Proxy is Proxy, ERC1967Upgrade {
    /**
     * @dev Sets the upgradeable proxy with an implementation specified by `_logic`.
     */
    function upgradeTo(address _logic) public {
        assert(_IMPLEMENTATION_SLOT == bytes32(uint256(keccak256("eip1967.proxy.implementation")) - 1));
        _upgradeTo(_logic);
    }

    /**
     * @dev Sets the upgradeable proxy with an implementation specified by `_logic`.
     *
     * If `_data` is nonempty, it's used as data in a delegate call to `_logic`. This will typically be an encoded
     * function call, and allows initializing the storage of the proxy like a Solidity constructor.
     */
    function upgradeToAndCall(address _logic, bytes memory _data, bool _forceCall) public {
        assert(_IMPLEMENTATION_SLOT == bytes32(uint256(keccak256("eip1967.proxy.implementation")) - 1));
        _upgradeToAndCall(_logic, _data, _forceCall);(_logic);
    }

    /**
     * @dev Perform implementation upgrade with security checks for UUPS proxies, and additional setup call.
     *
     * If `_data` is nonempty, it's used as data in a delegate call to `_logic`. This will typically be an encoded
     * function call, and allows initializing the storage of the proxy like a Solidity constructor.
     */
    function setImplementationAndCallUUPS(address _logic, bytes memory _data, bool _forceCall) public {
        assert(_IMPLEMENTATION_SLOT == bytes32(uint256(keccak256("eip1967.proxy.implementation")) - 1));
        _upgradeToAndCallUUPS(_logic, _data, _forceCall);(_logic);
    }

    /**
     * @dev Returns the current implementation address.
     */
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
        return ERC1967Upgrade._changeAdmin(_newAdmin);
    }

    /**
     * @dev Returns the current beacon address.
     */
    function getBeacon() public view returns (address) {
        return ERC1967Upgrade._getBeacon();
    }

    function upgradeBeaconToAndCall(address _newBeacon, bytes memory _data, bool _forceCall) public {
        return ERC1967Upgrade._upgradeBeaconToAndCall(_newBeacon, _data, _forceCall);
    }

    /**
     * @dev Returns the current implementation address. Override needed for the Proxy interface.
     */
    function _implementation() internal view virtual override returns (address impl) {
        return ERC1967Upgrade._getImplementation();
    }
}
