// SPDX-License-Identifier: MIT
// Validator smart contract for Fabrica version 1.0

pragma solidity ^0.8.21;

import {Address} from "@openzeppelin/contracts/utils/Address.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {FabricaUUPSUpgradeable} from "./FabricaUUPSUpgradeable.sol";
import {IFabricaValidator} from "./IFabricaValidator.sol";

/**
 * @dev Implementation of the Fabrica validator smart contract
 *      Delegates the metadata `uri` function to this contract
 *      May add other fields in newer versions
 */
contract FabricaValidator is IFabricaValidator, Initializable, FabricaUUPSUpgradeable, OwnableUpgradeable {
    using Address for address;

    constructor() {
        _disableInitializers();
    }

    function initialize() public initializer {
        __Ownable_init(_msgSender());
        __UUPSUpgradeable_init();
    }

    string private _baseUri;
    mapping(string => string) private _operatingAgreementNames;
    string private _defaultOperatingAgreement;

    event OperatingAgreementNameUpdated(string uri, string name);

    function setDefaultOperatingAgreement(string memory uri_) public onlyOwner {
        _defaultOperatingAgreement = uri_;
    }

    function defaultOperatingAgreement() public view returns (string memory) {
        return _defaultOperatingAgreement;
    }

    function addOperatingAgreementName(string memory uri_, string memory name) public onlyOwner {
        require(bytes(_operatingAgreementNames[uri_]).length < 1, "Operating Agreement name record for uri_ already exists");
        require(bytes(name).length > 0, "name is required");
        _operatingAgreementNames[uri_] = name;
        emit OperatingAgreementNameUpdated(uri_, name);
    }

    function removeOperatingAgreementName(string memory uri_) public onlyOwner {
        require(bytes(_operatingAgreementNames[uri_]).length > 0, "Operating Agreement name record for uri_ does not exist");
        delete _operatingAgreementNames[uri_];
        emit OperatingAgreementNameUpdated(uri_, "");
    }

    function updateOperatingAgreementName(string memory uri_, string memory name) public onlyOwner {
        require(bytes(_operatingAgreementNames[uri_]).length > 0, "Operating Agreement name record for uri_ does not exist");
        require(bytes(name).length > 0, "Use removeOperatingAgreementName");
        _operatingAgreementNames[uri_] = name;
        emit OperatingAgreementNameUpdated(uri_, name);
    }

    function operatingAgreementName(string memory uri_) public view returns (string memory) {
        return _operatingAgreementNames[uri_];
    }

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
