// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
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
        uint256 paybackAmount = nftfiV3LoanContract.getPayoffAmount(loanId);
        usdcContract.transferFrom(msg.sender, address(this), paybackAmount);
        address nftfiV3Erc20TransferManagerAddress = nftfiV3LoanContract.getERC20TransferManagerAddress();
        usdcContract.approve(nftfiV3Erc20TransferManagerAddress, paybackAmount);
        nftfiV3LoanContract.payBackLoan(loanId);
    }
}
