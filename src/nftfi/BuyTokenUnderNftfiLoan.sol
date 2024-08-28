// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC165, IERC165} from "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import {IERC1155Receiver} from "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";
import {IERC1155} from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import {ERC1155Receiver} from "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Receiver.sol";
import {Strings} from  "@openzeppelin/contracts/utils/Strings.sol";

import {Account, Actions, ISoloMargin} from "../dydx/ISoloMargin.sol";
import {DydxFlashloanBase} from "../dydx/DydxFlashloanBase.sol";
import {ICallee} from "../dydx/ICallee.sol";
import {ConsiderationInterface} from "../seaport/ConsiderationInterface.sol";
import {ConsiderationItem} from "../seaport/ConsiderationStructs.sol";
import {Order} from "../seaport/ConsiderationStructs.sol";

import {IDirectLoanBase, INftfiDirectLoanFixedOffer} from "./INftfiDirectLoanFixedOffer.sol";
import {IBuyTokenUnderNftfiLoan} from "./IBuyTokenUnderNftfiLoan.sol";
import {LoanData} from "./LoanData.sol";

contract BuyTokenUnderNftfiLoan is IBuyTokenUnderNftfiLoan, IERC165, ERC165, ERC1155Receiver, ICallee, DydxFlashloanBase {

    ISoloMargin public immutable DYDX_SOLO_MARGIN;
    INftfiDirectLoanFixedOffer public immutable NFTFI_DIRECT_LOAN;
    ConsiderationInterface public immutable SEAPORT;

    mapping(address => bool) public tokenFlashloanable;
    mapping(address => uint256) public marketIds;

    struct CallParams {
        address operator;
        address receiver;
        uint32 loanId;
        Order order;
    }

    constructor(
        address dydxSoloMarginAddress,
        address nftfiLoanAddress,
        address seaportAddress
    ) {
        DYDX_SOLO_MARGIN = ISoloMargin(dydxSoloMarginAddress);
        NFTFI_DIRECT_LOAN = INftfiDirectLoanFixedOffer(nftfiLoanAddress);
        SEAPORT = ConsiderationInterface(seaportAddress);
        for (uint256 i; i <= 3; ++i) {
            address tokenAddress = DYDX_SOLO_MARGIN.getMarketTokenAddress(i);
            tokenFlashloanable[tokenAddress] = true;
            marketIds[tokenAddress] = i;
        }
    }

    function calculateFlashLoanInterest(
        uint256 flashLoanAmount
    ) public override pure returns (uint256) {
        uint256 repaymentAmount = _getRepaymentAmountInternal(flashLoanAmount);
        return repaymentAmount - flashLoanAmount;
    }

    function buyTokenUnderLoan(
        address receiver,
        uint32 loanId,
        Order calldata order
    ) external override {
        // TODO: Ensure the order is sell-side, that the maker matches the borrower, and that the maker has authorized ERC1155 transfer to Reservoir
        require(
            order.parameters.offer.length == 1,
            "Only single-token orders are supported by this contract"
        );
        require(
            tokenFlashloanable[order.parameters.consideration[0].token],
            "Consideration token not supported by flash-loan provider"
        );
        LoanData.LoanTerms memory terms = NFTFI_DIRECT_LOAN.loanIdToLoan(loanId);
        uint256 totalConsideration = 0;
        require(
            order.parameters.consideration.length >= 1,
            "At least one consideration must be present in the order"
        );
        for (uint256 i = 0; i < order.parameters.consideration.length; i++) {
            require(
                terms.loanERC20Denomination == order.parameters.consideration[i].token,
                "All order consideration token must match loan denomination"
            );
            require(
                order.parameters.consideration[i].startAmount == order.parameters.consideration[i].endAmount,
                "ERC20 auctions are not supported by this contract"
            );
            totalConsideration = totalConsideration + order.parameters.consideration[i].startAmount;
        }
        require(
            terms.nftCollateralContract == order.parameters.offer[0].token,
            "Order offer token does not match loan collateral token"
        );
        uint256 flashLoanInterest = calculateFlashLoanInterest(terms.maximumRepaymentAmount);
        uint256 flashLoanRepayment = terms.maximumRepaymentAmount + flashLoanInterest;
        uint256 totalRequiredFromOperator = totalConsideration + flashLoanInterest;
        IERC20 considerationToken = IERC20(order.parameters.consideration[0].token);
        require(
            considerationToken.balanceOf(msg.sender) >= totalRequiredFromOperator,
            "Operator does not have sufficient consideration to purchase the token, plus flash-loan fees"
        );
        uint256 operatorAllowance = considerationToken.allowance(msg.sender, address(this));
        require(
            operatorAllowance >= totalRequiredFromOperator,
            string.concat("Operator has not approved sufficient ERC20 transfer to this contract to complete the purchase; allowance:", Strings.toString(operatorAllowance))
        );
        uint256 sellerAllowance = considerationToken.allowance(order.parameters.offerer, address(this));
        require(
            sellerAllowance >= terms.maximumRepaymentAmount,
            string.concat("Seller has not approved sufficient ERC20 transfer to this contract to pay off the loan; allowance:", Strings.toString(sellerAllowance))
        );
        // 1) Take out DyDx Flash Loan
        uint256 marketId = marketIds[order.parameters.consideration[0].token];
        Actions.ActionArgs[] memory actions = new Actions.ActionArgs[](3);
        actions[0] = _getWithdrawAction(marketId, terms.maximumRepaymentAmount);
        actions[1] = _getCallAction(abi.encode(CallParams({
            operator: msg.sender,
            receiver: receiver,
            loanId: loanId,
            order: order
        })));
        actions[2] = _getDepositAction(marketId, flashLoanRepayment);
        Account.Info[] memory accountInfos = new Account.Info[](1);
        accountInfos[0] = _getAccountInfo();
        DYDX_SOLO_MARGIN.operate(accountInfos, actions);
        // Next steps are in callFunction()
    }

    function callFunction(
        address sender,
        Account.Info calldata accountInfo,
        bytes calldata data
    ) external override {
        require(
            msg.sender == address(DYDX_SOLO_MARGIN),
            "Only the dYdX SoloMargin contract can call this function"
        );
        require(
            sender == address(this),
            "Flash-loan initiator must be this contract"
        );
        CallParams memory params = abi.decode(data, (CallParams));
        LoanData.LoanTerms memory terms = NFTFI_DIRECT_LOAN.loanIdToLoan(params.loanId);
        // TODO: Ensure the order is sell-side, that the maker matches the borrower, and that the maker has authorized ERC1155 transfer to Reservoir
        require(
            terms.nftCollateralContract == params.order.parameters.offer[0].token,
            "Order offer token does not match loan collateral token"
        );
        uint256 flashLoanInterest = calculateFlashLoanInterest(terms.maximumRepaymentAmount);
        uint256 totalConsideration = 0;
        require(
            params.order.parameters.consideration.length >= 1,
            "At least one consideration must be present in the order"
        );
        for (uint256 i = 0; i < params.order.parameters.consideration.length; i++) {
            totalConsideration = totalConsideration + params.order.parameters.consideration[i].startAmount;
        }
        uint256 totalRequiredFromOperator = totalConsideration + flashLoanInterest;
        IERC20 considerationToken = IERC20(params.order.parameters.consideration[0].token);
        require(
            considerationToken.balanceOf(params.operator) >= totalRequiredFromOperator,
            "Operator does not have sufficient consideration to complete the purchase plus flash-loan fees"
        );
        require(
            considerationToken.allowance(params.operator, address(this)) >= totalRequiredFromOperator,
            "Operator has not approved sufficient ERC20 transfer to this contract to complete the purchase"
        );
        require(
            considerationToken.balanceOf(address(this)) == terms.maximumRepaymentAmount,
            string.concat("Unexpected amount of USDC in contract just after taking out flash loan", Strings.toString(considerationToken.balanceOf(address(this))))
        );
        // 2) Take the purchase price plus flash-loan fee from the operator
        require(
            considerationToken.transferFrom(params.operator, address(this), totalRequiredFromOperator),
            "Failed to transfer required funds from operator"
        );
        require(
            considerationToken.balanceOf(address(this)) == terms.maximumRepaymentAmount + totalRequiredFromOperator,
            string.concat("Unexpected amount of USDC in contract just after pulling funds from operator", Strings.toString(considerationToken.balanceOf(address(this))))
        );
        // 3) Pay off the loan
        require (
            considerationToken.approve(address(NFTFI_DIRECT_LOAN), terms.maximumRepaymentAmount),
            "Failed to approve ERC20 transfer from this contract to the NFTfi loan contract"
        );
        NFTFI_DIRECT_LOAN.payBackLoan(params.loanId);
        uint256 balanceAfterPayingBackLoan = considerationToken.balanceOf(address(this));
        require(
            considerationToken.balanceOf(address(this)) == totalRequiredFromOperator,
            string.concat("Unexpected amount of USDC in contract just after paying off the NFTfi loan", Strings.toString(considerationToken.balanceOf(address(this))))
        );
        // 4) Buy the Fabrica token
        require(
            considerationToken.approve(address(SEAPORT), totalConsideration),
            "Failed to approve ERC20 transfer from this contract to Seaport"
        );
        require(
            SEAPORT.fulfillOrder(params.order, 0),
            "Seaport order failed to be fulfilled."
        );
        require(
            considerationToken.balanceOf(address(this)) == flashLoanInterest,
            string.concat("Unexpected amount of USDC in contract just after paying off the NFTfi loan", Strings.toString(considerationToken.balanceOf(address(this))))
        );
        // 5) Transfer the loan amount from the seller to this contract
        require(
            considerationToken.transferFrom(params.order.parameters.offerer, address(this), terms.maximumRepaymentAmount),
            "Failed to transfer loan-repayment amount from seller to this contract"
        );
        uint256 flashLoanRepayment = terms.maximumRepaymentAmount + flashLoanInterest;
        require(
            considerationToken.balanceOf(address(this)) == flashLoanRepayment,
            string.concat("Unexpected amount of USDC in contract just after paying off the NFTfi loan", Strings.toString(considerationToken.balanceOf(address(this))))
        );
        // 6) Transfer the Fabrica token to the receiver
        IERC1155(params.order.parameters.offer[0].token).safeTransferFrom(
            address(this),
            params.receiver,
            params.order.parameters.offer[0].identifierOrCriteria,
            params.order.parameters.offer[0].startAmount,
            new bytes(0)
        );
        // 7) Approve repayment of the flash loan
        require(
            considerationToken.approve(address(DYDX_SOLO_MARGIN), flashLoanRepayment),
            "Failed to approve ERC20 transfer from this contract to dYdX"
        );
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165, ERC1155Receiver) returns (bool) {
        return
            interfaceId == type(ICallee).interfaceId
            || ERC1155Receiver.supportsInterface(interfaceId);
    }

    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) override(IERC1155Receiver) external pure returns (bytes4) {
        return IERC1155Receiver.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) override(IERC1155Receiver) external pure returns (bytes4) {
        return IERC1155Receiver.onERC1155BatchReceived.selector;
    }
}
