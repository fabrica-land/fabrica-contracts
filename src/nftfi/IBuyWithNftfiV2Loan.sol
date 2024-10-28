// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Order} from "../seaport/ConsiderationStructs.sol";

import {INftfiV2LoanOffer} from "./INftfiV2LoanOffer.sol";

interface IBuyWithNftfiV2Loan {

    function calculateFlashLoanInterest(
        uint256 loanPrincipalAmount
    ) external view returns (uint256);

    function buyWithLoan(
        address receiver,
        Order calldata order,
        INftfiV2LoanOffer.Offer calldata offer,
        INftfiV2LoanOffer.Signature calldata signature,
        INftfiV2LoanOffer.BorrowerSettings calldata borrowerSettings
    ) external;
}
