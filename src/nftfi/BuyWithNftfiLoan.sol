// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC165, IERC165} from "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import {IERC1155} from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import {IERC1155Receiver} from "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";
import {ERC1155Receiver} from "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Receiver.sol";
import {Strings} from  "@openzeppelin/contracts/utils/Strings.sol";

import {AaveFlashLoanSimpleReceiverBase, IAaveFlashLoanSimpleReceiver} from "../aave/AaveFlashLoanSimpleReceiverBase.sol";
import {IAavePool} from "../aave/IAavePool.sol";
import {IAavePoolAddressesProvider} from "../aave/IAavePoolAddressesProvider.sol";
import {ISeaport} from "../seaport/ISeaport.sol";

import {IBuyWithNftfiLoan} from "./IBuyWithNftfiLoan.sol";
import {IDirectLoanCoordinator} from "./IDirectLoanCoordinator.sol";
import {INftfiDirectLoanFixedOffer} from "./INftfiDirectLoanFixedOffer.sol";
import {INftfiHub} from "./INftfiHub.sol";

contract BuyWithNftfiLoan is IBuyWithNftfiLoan, AaveFlashLoanSimpleReceiverBase, IERC165, ERC165, IERC721Receiver, ERC1155Receiver {

    INftfiDirectLoanFixedOffer public immutable NFTFI_DIRECT_LOAN;
    IDirectLoanCoordinator public immutable NFTFI_DIRECT_LOAN_COORDINATOR;
    ISeaport public immutable SEAPORT;

    constructor(
        address aavePoolAddressesProviderAddress,
        address nftfiLoanAddress,
        address seaportAddress
    ) AaveFlashLoanSimpleReceiverBase(IAavePoolAddressesProvider(aavePoolAddressesProviderAddress)) {
        NFTFI_DIRECT_LOAN = INftfiDirectLoanFixedOffer(nftfiLoanAddress);
        INftfiHub nftfiHub = INftfiHub(NFTFI_DIRECT_LOAN.hub());
        NFTFI_DIRECT_LOAN_COORDINATOR = IDirectLoanCoordinator(nftfiHub.getContract(NFTFI_DIRECT_LOAN.LOAN_COORDINATOR()));
        SEAPORT = ISeaport(seaportAddress);
    }

    // Modifier to restrict access to the Pool
    modifier onlyPool() {
        require(msg.sender == address(POOL), "Caller is not the Pool");
        _;
    }

    function calculateFlashLoanInterest(
        INftfiDirectLoanFixedOffer.Offer memory offer
    ) public override view returns (uint256) {
        return offer.loanPrincipalAmount * POOL.FLASHLOAN_PREMIUM_TOTAL() / 10000;
    }

    function buyWithLoan(
        ISeaport.BasicOrderParameters calldata orderParams,
        INftfiDirectLoanFixedOffer.Offer calldata offer,
        INftfiDirectLoanFixedOffer.Signature calldata signature,
        INftfiDirectLoanFixedOffer.BorrowerSettings calldata borrowerSettings
    ) external override {
        require(offer.loanERC20Denomination == orderParams.considerationToken, "Order consideration token does not match loan-offer denomination");
        require(offer.nftCollateralContract == orderParams.offerToken, "Order offer token does not match loan-offer collateral token");
        uint256 flashLoanInterest = calculateFlashLoanInterest(offer);
        uint256 downPayment = orderParams.considerationAmount - offer.loanPrincipalAmount;
        uint256 totalRequiredFromPurchaser = downPayment + flashLoanInterest;
        IERC20 considerationToken = IERC20(orderParams.considerationToken);
        require(considerationToken.balanceOf(msg.sender) >= totalRequiredFromPurchaser, "Purchaser does not have sufficient consideration to make the down payment plus flash-loan fees");
        uint256 allowance = considerationToken.allowance(msg.sender, address(this));
        require(
            allowance >= totalRequiredFromPurchaser,
            string.concat("Purchaser has not approved sufficient ERC20 transfer to this contract to complete the purchase; allowance:", Strings.toString(allowance))
        );
        // 1) Take out Aave Flash Loan
        bytes memory params = abi.encode(
            msg.sender,
            orderParams,
            offer,
            signature,
            borrowerSettings
        );
        POOL.flashLoanSimple(
            address(this),
            offer.loanERC20Denomination,
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
    ) external override onlyPool returns (bool) {
        require(initiator == address(this), "Flash-loan initiator must be this contract");
        (
            address purchaser,
            ISeaport.BasicOrderParameters memory orderParams,
            INftfiDirectLoanFixedOffer.Offer memory offer,
            INftfiDirectLoanFixedOffer.Signature memory signature,
            INftfiDirectLoanFixedOffer.BorrowerSettings memory borrowerSettings
        ) = abi.decode(
            params,
            (
                address,
                ISeaport.BasicOrderParameters,
                INftfiDirectLoanFixedOffer.Offer,
                INftfiDirectLoanFixedOffer.Signature,
                INftfiDirectLoanFixedOffer.BorrowerSettings
            )
        );
        require(amount == offer.loanPrincipalAmount, "Flash-loan amount must equal the loan offer's principal amount");
        require(asset == orderParams.considerationToken, "Flash-loan asset must equal the order's consideration token");
        require(asset == offer.loanERC20Denomination, "Flash-loan asset must equal the loan-offer denomination");
        require(offer.nftCollateralContract == orderParams.offerToken, "Order offer token does not match loan-offer collateral token");
        uint256 flashLoanInterest = calculateFlashLoanInterest(offer);
        require(premium == flashLoanInterest, "Aave's calculated premium doesn't equal ours based on the FLASHLOAN_PREMIUM_TOTAL");
        uint256 downPayment = orderParams.considerationAmount - offer.loanPrincipalAmount;
        uint256 totalRequiredFromPurchaser = downPayment + flashLoanInterest;
        IERC20 considerationToken = IERC20(orderParams.considerationToken);
        require(considerationToken.balanceOf(purchaser) >= totalRequiredFromPurchaser, "Purchaser does not have sufficient consideration to make the down payment plus flash-loan fees");
        require(considerationToken.allowance(purchaser, address(this)) >= totalRequiredFromPurchaser, "Purchaser has not approved sufficient ERC20 transfer to this contract to complete the purchase");
        // 2) Take the down-payment plus flash-loan fee from the purchaser
        if (!considerationToken.transferFrom(purchaser, address(this), totalRequiredFromPurchaser)) {
            revert("Failed to transfer required funds from purchaser");
        }
        // 3) Allow Seaport to transfer the required funds from this contract to complete the purchase
        if (!considerationToken.approve(address(SEAPORT), orderParams.considerationAmount)) {
            revert("Failed to approve ERC20 transfer from this contract to Seaport");
        }
        // 4) Buy the Fabrica token
        if (!SEAPORT.fulfillBasicOrder(orderParams)) {
            revert("Seaport order failed to be fulfilled.");
        }
        // 5) Take out the NFTfi loan
        IERC1155(offer.nftCollateralContract).setApprovalForAll(address(NFTFI_DIRECT_LOAN), true);
        uint32 loanId = NFTFI_DIRECT_LOAN.acceptOffer(
            offer,
            signature,
            borrowerSettings
        );
        // 7) Mint the obligation receipt
        NFTFI_DIRECT_LOAN.mintObligationReceipt(loanId);
        // 8) Transfer the obligation receipt to the purchaser
        IDirectLoanCoordinator.Loan memory loan = NFTFI_DIRECT_LOAN_COORDINATOR.getLoanData(loanId);
        IERC721(NFTFI_DIRECT_LOAN_COORDINATOR.obligationReceiptToken()).transferFrom(
            address(this),
            purchaser,
            loan.smartNftId
        );
        // 8) Approve repayment of the flash loan
        uint256 flashLoanRepayment = offer.loanPrincipalAmount + flashLoanInterest;
        considerationToken.approve(address(POOL), flashLoanRepayment);
        return true;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165, ERC1155Receiver) returns (bool) {
        return
            interfaceId == type(IAaveFlashLoanSimpleReceiver).interfaceId
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
