// SPDX-License-Identifier: MIT

pragma solidity ^0.8.28;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Address} from "@openzeppelin/contracts/utils/Address.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {PausableUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";
import {FabricaUUPSUpgradeable} from "./FabricaUUPSUpgradeable.sol";
import {IFabricaToken} from "./IFabricaToken.sol";

contract FabricaFeeCollector is Initializable, OwnableUpgradeable, PausableUpgradeable, FabricaUUPSUpgradeable {
    using Address for address;

    address private _protocolContractAddress;
    uint8 private _protocolSharePercent;
    address private _protocolFeeRecipient;

    event ProtocolSharePercentChanged(
        uint256 indexed newProtocolSharePercent
    );
    event ProtocolFeeRecipientChanged(
        address indexed newFeeRecipient
    );
    event FeeCollected(
        uint256 indexed tokenId,
        string indexed feeType,
        address indexed obligor,
        address erc20Currency,
        uint256 protocolReceived,
        address validatorAddress,
        uint256 validatorReceived
    );

    error InsufficientAllowance(
        uint256 approval,
        uint256 feeAmount
    );
    error InsufficientBalance(
        uint256 balance,
        uint256 feeAmount
    );

    constructor() {
        _disableInitializers();
    }

    function initialize(
        address protocolContractAddress_,
        uint8 protocolSharePercent_,
        address protocolFeeRecipient_
    ) external initializer {
        __FabricaUUPSUpgradeable_init();
        __Ownable_init(_msgSender());
        __Pausable_init();
        _protocolContractAddress = protocolContractAddress_;
        _protocolSharePercent = protocolSharePercent_;
        _protocolFeeRecipient = protocolFeeRecipient_;
    }

    function pause() external onlyOwner whenNotPaused {
        _pause();
    }

    function unpause() external onlyOwner whenPaused {
        _unpause();
    }

    function protocolContractAddress() external view returns (address) {
        return _protocolContractAddress;
    }

    function protocolFeeRecipient() external view returns (address) {
        return _protocolFeeRecipient;
    }

    function setProtocolFeeRecipient(
        address newProtocolFeeRecipient
    ) external onlyOwner {
        _protocolFeeRecipient = newProtocolFeeRecipient;
        emit ProtocolFeeRecipientChanged(newProtocolFeeRecipient);
    }

    function protocolSharePercent() external view returns (uint8) {
        return _protocolSharePercent;
    }

    function setProtocolSharePercent(
        uint8 newProtocolSharePercent
    ) external onlyOwner {
        _protocolSharePercent = newProtocolSharePercent;
        emit ProtocolSharePercentChanged(newProtocolSharePercent);
    }

    function collectFee(
        uint256 tokenId,
        string calldata feeType,
        address obligor,
        address erc20CurrencyAddress,
        uint256 amount
    ) external onlyOwner whenNotPaused {
        IERC20 currency = IERC20(erc20CurrencyAddress);
        uint256 allowance = currency.allowance(obligor, address(this));
        if (allowance < amount) {
            revert InsufficientAllowance(allowance, amount);
        }
        uint256 balance = currency.balanceOf(obligor);
        if (balance < amount) {
            revert InsufficientBalance(balance, amount);
        }
        currency.transferFrom(obligor, address(this), amount);
        IFabricaToken protocolContract = IFabricaToken(_protocolContractAddress);
        (,,,,address validatorAddress) = protocolContract._property(tokenId);
        if (validatorAddress == address(0)) {
            validatorAddress = protocolContract.defaultValidator();
        }
        uint256 protocolShare = amount * _protocolSharePercent / 100;
        uint256 validatorShare = amount - protocolShare;
        if (protocolShare > 0) {
            currency.transfer(
                _protocolFeeRecipient,
                protocolShare
            );
        }
        if (validatorShare > 0) {
            currency.transfer(
                validatorAddress,
                validatorShare
            );
        }
        emit FeeCollected(
            tokenId,
            feeType,
            obligor,
            erc20CurrencyAddress,
            protocolShare,
            validatorAddress,
            validatorShare
        );
    }
}
