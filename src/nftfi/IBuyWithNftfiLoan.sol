// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {Order} from "../seaport/ConsiderationStructs.sol";

import {INftfiDirectLoanFixedOffer} from "./INftfiDirectLoanFixedOffer.sol";

interface IBuyWithNftfiLoan {

    function calculateFlashLoanInterest(
        uint256 loanPrincipalAmount
    ) external view returns (uint256);

    function buyWithLoan(
        Order calldata order,
        INftfiDirectLoanFixedOffer.Offer calldata offer,
        INftfiDirectLoanFixedOffer.Signature calldata signature,
        INftfiDirectLoanFixedOffer.BorrowerSettings calldata borrowerSettings
    ) external;
}
