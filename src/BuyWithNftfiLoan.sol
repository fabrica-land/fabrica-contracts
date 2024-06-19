// SPDX-License-Identifier: MIT

pragma solidity ^0.8.25;

import {IERC1155} from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {BytesLib} from "./BytesLib.sol";
import {IAavePool} from "./IAavePool.sol";
import {IBuyWithNftfiLoan} from "./IBuyWithNftfiLoan.sol";
import {ISeaport} from "./ISeaport.sol";
import {INftfiDirectLoanFixedOffer} from "./INftfiDirectLoanFixedOffer.sol";

contract BuyWithNftfiLoan is IBuyWithNftfiLoan {

    address public aaveFlashLoanAddress;
    address public nftfiLoanAddress;
    address public seaportAddress;

    constructor(
        address aaveFlashLoanAddress_,
        address nftfiLoanAddress_,
        address seaportAddress_
    ) {
        aaveFlashLoanAddress = aaveFlashLoanAddress_;
        nftfiLoanAddress = nftfiLoanAddress_;
        seaportAddress = seaportAddress_;
    }

    function buyWithLoan(
        ISeaport.BasicOrderParameters calldata orderParams,
        INftfiDirectLoanFixedOffer.Offer calldata offer,
        INftfiDirectLoanFixedOffer.Signature calldata signature,
        INftfiDirectLoanFixedOffer.BorrowerSettings calldata borrowerSettings
    ) external {
        require(offer.loanERC20Denomination == orderParams.considerationToken, "Order consideration token does not match loan-offer denomination");
        require(offer.nftCollateralContract == orderParams.offerToken, "Order offer token does not match loan-offer collateral token");
        uint256 flashLoanInterest = offer.loanPrincipalAmount * IAavePool(aaveFlashLoanAddress).FLASHLOAN_PREMIUM_TOTAL();
        uint256 downPayment = orderParams.considerationAmount - offer.loanPrincipalAmount;
        uint256 additionalAmount = 0;
        for (uint256 i = 0 ; i < orderParams.additionalRecipients.length ; i++) {
            additionalAmount = additionalAmount + orderParams.additionalRecipients[i].amount;
        }
        uint256 totalRequiredFromOperator = downPayment + additionalAmount + flashLoanInterest;
        require(IERC20(orderParams.considerationToken).balanceOf(msg.sender) >= totalRequiredFromOperator, "Operator does not have sufficient consideration");
        // 1) Take out Aave Flash Loan
        bytes memory params = abi.encode(
            orderParams,
            offer,
            signature,
            borrowerSettings
        );
        IAavePool(aaveFlashLoanAddress).flashLoanSimple(
            msg.sender,
            orderParams.considerationToken,
            offer.loanPrincipalAmount,
            params,
            0
        );
        // Next steps are in executeOperation()
    }

    function executeOperation(
        address asset,
        uint256 amount,
        uint256 premium,
        address initiator,
        bytes calldata params
    ) public {
        (
            ISeaport.BasicOrderParameters memory orderParams,
            INftfiDirectLoanFixedOffer.Offer memory offer,
            INftfiDirectLoanFixedOffer.Signature memory signature,
            INftfiDirectLoanFixedOffer.BorrowerSettings memory borrowerSettings
        ) = abi.decode(
            params,
            (
                ISeaport.BasicOrderParameters,
                INftfiDirectLoanFixedOffer.Offer,
                INftfiDirectLoanFixedOffer.Signature,
                INftfiDirectLoanFixedOffer.BorrowerSettings
            )
        );
        require(asset == orderParams.considerationToken, "Flash-loan asset must equal the order's consideration token");
        require(premium == offer.loanPrincipalAmount, "Flash-loan amount must equal the loan offer's principal amount");
        require(initiator == msg.sender(), "Flash-loan initiator must be the operator");
        // 2) Buy the Fabrica token
        if (!ISeaport(seaportAddress).fulfillBasicOrder(orderParams)) {
            revert("Seaport order failed to be fulfilled.");
        }
        // 3) Take out the NFTfi loan
        uint256 loanTotalWithFlashFee = offer.loanPrincipalAmount + premium;
        INftfiDirectLoanFixedOffer(nftfiLoanAddress).acceptOffer(
            offer,
            signature,
            borrowerSettings
        );
        // 4) Approve repayment of the Aave Flash Loan
        IERC20(orderParams.considerationToken).approve(aaveFlashLoanAddress, loanTotalWithFlashFee);
    }
}
