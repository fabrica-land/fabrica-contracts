// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Order} from "../seaport/ConsiderationStructs.sol";

import {INftfiDirectLoanFixedOffer} from "./INftfiDirectLoanFixedOffer.sol";

interface IBuyWithNftfiLoan {

    function calculateFlashLoanInterest(
        uint256 loanPrincipalAmount
    ) external view returns (uint256);

    function buyWithLoan(
        address receiver,
        Order calldata order,
        INftfiDirectLoanFixedOffer.Offer calldata offer,
        INftfiDirectLoanFixedOffer.Signature calldata signature,
        INftfiDirectLoanFixedOffer.BorrowerSettings calldata borrowerSettings
    ) external;
}
