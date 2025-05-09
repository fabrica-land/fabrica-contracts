// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.28;

import {NftfiV3LoanData} from "./NftfiV3LoanData.sol";

interface INftfiV3LoanBase {
    function hub() external view returns (address);

    function maximumLoanDuration() external view returns (uint256);

    function adminFeeInBasisPoints() external view returns (uint16);

    // solhint-disable-next-line func-name-mixedcase
    function LOAN_COORDINATOR() external view returns (bytes32);

    function getLoanTerms(uint32) external view returns (NftfiV3LoanData.LoanTerms memory);

    function loanRepaidOrLiquidated(uint32) external view returns (bool);

    function getWhetherRenegotiationNonceHasBeenUsedForUser(address _user, uint256 _nonce) external view returns (bool);

    function getPayoffAmount(uint32 _loanId) external view returns (uint256);

    function payBackLoan(uint32 _loanId) external;

    function getERC20TransferManagerAddress() external view returns (address);
}