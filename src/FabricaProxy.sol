// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (proxy/Proxy.sol)

pragma solidity ^0.8.28;

import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {ERC1967Utils} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Utils.sol";

contract FabricaProxy is ERC1967Proxy {
    constructor(address _logic, address _admin, bytes memory _data) ERC1967Proxy(_logic, _data) {
        ERC1967Utils.changeAdmin(_admin == address(0) ? msg.sender : _admin);
    }
}
