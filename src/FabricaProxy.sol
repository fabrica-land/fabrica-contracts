// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (proxy/Proxy.sol)

pragma solidity ^0.8.25;

import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract FabricaProxy is ERC1967Proxy {
    constructor(address _logic, address _admin, bytes memory _data) ERC1967Proxy(_logic, _data) {
        ERC1967Upgrade._changeAdmin(_admin == address(0) ? msg.sender : _admin);
    }
}
