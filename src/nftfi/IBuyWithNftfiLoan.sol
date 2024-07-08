// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {ISeaport} from "../seaport/ISeaport.sol";

import {INftfiDirectLoanFixedOffer} from "./INftfiDirectLoanFixedOffer.sol";

interface IBuyWithNftfiLoan {

    function calculateFlashLoanInterest(
        INftfiDirectLoanFixedOffer.Offer memory offer
    ) external view returns (uint256);

    function buyWithLoan(
        ISeaport.BasicOrderParameters calldata orderParams,
        INftfiDirectLoanFixedOffer.Offer calldata offer,
        INftfiDirectLoanFixedOffer.Signature calldata signature,
        INftfiDirectLoanFixedOffer.BorrowerSettings calldata borrowerSettings
    ) external;
}
