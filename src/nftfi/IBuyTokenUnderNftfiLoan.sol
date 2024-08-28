// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Order} from "../seaport/ConsiderationStructs.sol";

interface IBuyTokenUnderNftfiLoan {

    function calculateFlashLoanInterest(
        uint256 loanPrincipalAmount
    ) external view returns (uint256);

    function buyTokenUnderLoan(
        address receiver,
        uint32 loanId,
        Order calldata order
    ) external;
}
