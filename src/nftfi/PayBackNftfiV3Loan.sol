// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {INftfiV3LoanBase} from "./INftfiV3LoanBase.sol";

contract PayBackNftfiV3Loan {

    INftfiV3LoanBase public immutable nftfiV3LoanContract;
    IERC20 public immutable usdcContract;

    constructor(
        address nftfiV3LoanContractAddress,
        address usdcContractAddress
    ) {
        nftfiV3LoanContract = INftfiV3LoanBase(nftfiV3LoanContractAddress);
        usdcContract = IERC20(usdcContractAddress);
    }

    function payBackLoan(uint32 loanId) external {
        _payBackLoanAmount(loanId, 0);
    }

    function payBackLoanAmount(uint32 loanId, uint256 amountToCollect) public {
        _payBackLoanAmount(loanId, amountToCollect);
    }

    function _payBackLoanAmount(uint32 loanId, uint256 amountToCollect) private {
        uint256 actualPaybackAmount = nftfiV3LoanContract.getPayoffAmount(loanId);
        if (amountToCollect == 0) {
            amountToCollect = actualPaybackAmount;
        } else if (amountToCollect < actualPaybackAmount) {
            revert(string.concat("Amount to collect is less than required payback amount ", Strings.toString(actualPaybackAmount)));
        }
        usdcContract.transferFrom(msg.sender, address(this), amountToCollect);
        address nftfiV3Erc20TransferManagerAddress = nftfiV3LoanContract.getERC20TransferManagerAddress();
        usdcContract.approve(nftfiV3Erc20TransferManagerAddress, actualPaybackAmount);
        nftfiV3LoanContract.payBackLoan(loanId);
        uint256 amountToReturn = amountToCollect - actualPaybackAmount;
        if (amountToReturn > 0) {
            address borrower = nftfiV3LoanContract.getLoanTerms(loanId).borrower;
            usdcContract.transfer(borrower, amountToReturn);
        }
    }
}
