// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC165, IERC165} from "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import {IERC1155} from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import {IERC1155Receiver} from "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";
import {ERC1155Receiver} from "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Receiver.sol";
import {Strings} from  "@openzeppelin/contracts/utils/Strings.sol";

import {Account, Actions, ISoloMargin} from "../dydx/ISoloMargin.sol";
import {DydxFlashloanBase} from "../dydx/DydxFlashloanBase.sol";
import {ICallee} from "../dydx/ICallee.sol";
import {ConsiderationInterface} from "../seaport/ConsiderationInterface.sol";
import {Order} from "../seaport/ConsiderationStructs.sol";

import {IBuyWithNftfiLoan} from "./IBuyWithNftfiLoan.sol";
import {IDirectLoanCoordinator} from "./IDirectLoanCoordinator.sol";
import {INftfiDirectLoanFixedOffer} from "./INftfiDirectLoanFixedOffer.sol";
import {INftfiHub} from "./INftfiHub.sol";

contract BuyWithNftfiLoan is IBuyWithNftfiLoan, IERC165, ERC165, IERC721Receiver, ERC1155Receiver, ICallee, DydxFlashloanBase {

    ISoloMargin public immutable DYDX_SOLO_MARGIN;
    INftfiDirectLoanFixedOffer public immutable NFTFI_DIRECT_LOAN;
    IDirectLoanCoordinator public immutable NFTFI_DIRECT_LOAN_COORDINATOR;
    ConsiderationInterface public immutable SEAPORT;

    mapping(address => bool) public tokenFlashloanable;
    mapping(address => uint256) public marketIds;

    struct CallParams {
        address operator;
        address receiver;
        Order order;
        INftfiDirectLoanFixedOffer.Offer offer;
        INftfiDirectLoanFixedOffer.Signature signature;
        INftfiDirectLoanFixedOffer.BorrowerSettings borrowerSettings;
    }

    constructor(
        address dydxSoloMarginAddress,
        address nftfiLoanAddress,
        address seaportAddress
    ) {
        DYDX_SOLO_MARGIN = ISoloMargin(dydxSoloMarginAddress);
        NFTFI_DIRECT_LOAN = INftfiDirectLoanFixedOffer(nftfiLoanAddress);
        INftfiHub nftfiHub = INftfiHub(NFTFI_DIRECT_LOAN.hub());
        NFTFI_DIRECT_LOAN_COORDINATOR = IDirectLoanCoordinator(nftfiHub.getContract(NFTFI_DIRECT_LOAN.LOAN_COORDINATOR()));
        SEAPORT = ConsiderationInterface(seaportAddress);
        for (uint256 i; i <= 3; ++i) {
            address tokenAddress = DYDX_SOLO_MARGIN.getMarketTokenAddress(i);
            tokenFlashloanable[tokenAddress] = true;
            marketIds[tokenAddress] = i;
        }
    }

    function calculateFlashLoanInterest(
        uint256 loanPrincipalAmount
    ) public override pure returns (uint256) {
        uint256 repaymentAmount = _getRepaymentAmountInternal(loanPrincipalAmount);
        return repaymentAmount - loanPrincipalAmount;
    }

    function buyWithLoan(
        address receiver,
        Order calldata order,
        INftfiDirectLoanFixedOffer.Offer calldata offer,
        INftfiDirectLoanFixedOffer.Signature calldata signature,
        INftfiDirectLoanFixedOffer.BorrowerSettings calldata borrowerSettings
    ) external override {
        require(order.parameters.offer.length == 1, "Only single-token orders are supported by this contract");
        require(tokenFlashloanable[order.parameters.consideration[0].token], "Consideration token not supported by flash-loan provider");
        uint256 totalConsideration = 0;
        require(order.parameters.consideration.length >= 1, "At least one consideration must be present in the order");
        for (uint256 i = 0; i < order.parameters.consideration.length; i++) {
            require(offer.loanERC20Denomination == order.parameters.consideration[i].token, "All order consideration token must match loan-offer denomination");
            require(order.parameters.consideration[i].startAmount == order.parameters.consideration[i].endAmount, "ERC20 auctions are not supported by this contract");
            totalConsideration = totalConsideration + order.parameters.consideration[i].startAmount;
        }
        require(offer.nftCollateralContract == order.parameters.offer[0].token, "Order offer token does not match loan-offer collateral token");
        uint256 flashLoanInterest = calculateFlashLoanInterest(offer.loanPrincipalAmount);
        uint256 flashLoanRepayment = offer.loanPrincipalAmount + flashLoanInterest;
        uint256 totalRequiredFromOperator = totalConsideration - offer.loanPrincipalAmount + flashLoanInterest;
        IERC20 considerationToken = IERC20(order.parameters.consideration[0].token);
        require(considerationToken.balanceOf(msg.sender) >= totalRequiredFromOperator, "Operator does not have sufficient consideration to make the down payment plus flash-loan fees");
        uint256 allowance = considerationToken.allowance(msg.sender, address(this));
        require(
            allowance >= totalRequiredFromOperator,
            string.concat("Operator has not approved sufficient ERC20 transfer to this contract to complete the purchase; allowance:", Strings.toString(allowance))
        );
        // 1) Take out DyDx Flash Loan
        uint256 marketId = marketIds[order.parameters.consideration[0].token];
        Actions.ActionArgs[] memory actions = new Actions.ActionArgs[](3);
        actions[0] = _getWithdrawAction(marketId, offer.loanPrincipalAmount);
        actions[1] = _getCallAction(abi.encode(CallParams({
            operator: msg.sender,
            receiver: receiver,
            order: order,
            offer: offer,
            signature: signature,
            borrowerSettings: borrowerSettings
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
        require(msg.sender == address(DYDX_SOLO_MARGIN), "Only the dYdX SoloMargin contract can call this function");
        require(sender == address(this), "Flash-loan initiator must be this contract");
        CallParams memory params = abi.decode(data, (CallParams));
        require(params.offer.nftCollateralContract == params.order.parameters.offer[0].token, "Order offer token does not match loan-offer collateral token");
        uint256 flashLoanInterest = calculateFlashLoanInterest(params.offer.loanPrincipalAmount);
        uint256 totalConsideration = 0;
        require(params.order.parameters.consideration.length >= 1, "At least one consideration must be present in the order");
        for (uint256 i = 0; i < params.order.parameters.consideration.length; i++) {
            totalConsideration = totalConsideration + params.order.parameters.consideration[i].startAmount;
        }
        uint256 totalRequiredFromOperator = totalConsideration - params.offer.loanPrincipalAmount + flashLoanInterest;
        IERC20 considerationToken = IERC20(params.order.parameters.consideration[0].token);
        require(considerationToken.balanceOf(params.operator) >= totalRequiredFromOperator, "Operator does not have sufficient consideration to make the down payment plus flash-loan fees");
        require(considerationToken.allowance(params.operator, address(this)) >= totalRequiredFromOperator, "Operator has not approved sufficient ERC20 transfer to this contract to complete the purchase");
        // 2) Take the down-payment plus flash-loan fee from the operator
        if (!considerationToken.transferFrom(params.operator, address(this), totalRequiredFromOperator)) {
            revert("Failed to transfer required funds from operator");
        }
        // 3) Allow Seaport to transfer the required funds from this contract to complete the purchase
        if (!considerationToken.approve(address(SEAPORT), totalConsideration)) {
            revert("Failed to approve ERC20 transfer from this contract to Seaport");
        }
        // 4) Buy the Fabrica token
        if (!SEAPORT.fulfillOrder(params.order, 0)) {
            revert("Seaport order failed to be fulfilled.");
        }
        // 5) Take out the NFTfi loan
        IERC1155(params.offer.nftCollateralContract).setApprovalForAll(address(NFTFI_DIRECT_LOAN), true);
        uint32 loanId = NFTFI_DIRECT_LOAN.acceptOffer(
            params.offer,
            params.signature,
            params.borrowerSettings
        );
        // 7) Mint the obligation receipt
        NFTFI_DIRECT_LOAN.mintObligationReceipt(loanId);
        // 8) Transfer the obligation receipt to the receiver
        IDirectLoanCoordinator.Loan memory loan = NFTFI_DIRECT_LOAN_COORDINATOR.getLoanData(loanId);
        IERC721(NFTFI_DIRECT_LOAN_COORDINATOR.obligationReceiptToken()).transferFrom(
            address(this),
            params.receiver,
            loan.smartNftId
        );
        // 8) Approve repayment of the flash loan
        uint256 flashLoanRepayment = params.offer.loanPrincipalAmount + flashLoanInterest;
        considerationToken.approve(address(DYDX_SOLO_MARGIN), flashLoanRepayment);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165, ERC1155Receiver) returns (bool) {
        return
            interfaceId == type(ICallee).interfaceId
            || interfaceId == type(IERC721Receiver).interfaceId
            || ERC1155Receiver.supportsInterface(interfaceId);
    }

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) override external pure returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
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
