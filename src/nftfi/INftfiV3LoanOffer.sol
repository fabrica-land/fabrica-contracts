// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.28;

import {INftfiV2LoanBase} from "./INftfiV2LoanBase.sol";

interface INftfiV3LoanOffer is INftfiV2LoanBase {

    struct Offer {
        uint256 loanPrincipalAmount;
        uint256 maximumRepaymentAmount;
        uint256 nftCollateralId;
        address nftCollateralContract;
        uint32 loanDuration;
        address loanERC20Denomination;
        bool isProRata;
        uint256 originationFee;
    }

    struct Signature {
        uint256 nonce;
        uint256 expiry;
        address signer;
        bytes signature;
    }

    function acceptOffer(
        Offer memory _offer,
        Signature memory _signature
    ) external returns (uint32);

    function getEscrowAddress(
        address _borrower
    ) external returns (address);
}
