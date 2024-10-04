// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {Order} from "../seaport/ConsiderationStructs.sol";

interface IBuyWithMetaStreetLoan {
    function buyWithLoan(
        Order calldata order,
        uint256 downPayment,
        uint256 loanAmount,
        uint64 loanDuration,
        uint256 maxRepayment,
        uint128[] calldata loanTicks,
        bytes calldata loanOptions
    ) external;
}
