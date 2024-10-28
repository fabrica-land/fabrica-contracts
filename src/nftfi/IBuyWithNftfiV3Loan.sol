// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Order} from "../seaport/ConsiderationStructs.sol";

import {INftfiV3LoanOffer} from "./INftfiV3LoanOffer.sol";

interface IBuyWithNftfiV3Loan {

    function calculateFlashLoanInterest(
        uint256 loanPrincipalAmount
    ) external view returns (uint256);

    function buyWithLoan(
        address receiver,
        Order calldata order,
        INftfiV3LoanOffer.Offer calldata offer,
        INftfiV3LoanOffer.Signature calldata signature
    ) external;
}
