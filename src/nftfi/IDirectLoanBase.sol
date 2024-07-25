// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.26;

import "./LoanData.sol";

interface IDirectLoanBase {
    function hub() external view returns (address);

    function maximumLoanDuration() external view returns (uint256);

    function adminFeeInBasisPoints() external view returns (uint16);

    // solhint-disable-next-line func-name-mixedcase
    function LOAN_COORDINATOR() external view returns (bytes32);

    function loanIdToLoan(uint32)
    external
    view
    returns (
        uint256,
        uint256,
        uint256,
        address,
        uint32,
        uint16,
        uint16,
        address,
        uint64,
        address,
        address
    );

    function loanRepaidOrLiquidated(uint32) external view returns (bool);

    function getWhetherNonceHasBeenUsedForUser(address _user, uint256 _nonce) external view returns (bool);

    function mintObligationReceipt(uint32 _loanId) external;
}