# Third-Party Notices

Code authored by Fabrica Inc. in this repository is licensed under the MIT
License (see [LICENSE](LICENSE)). The following vendored third-party files
retain their original licenses and are NOT covered by the MIT grant:

## NFTfi (BUSL-1.1)

Interface and loan-data files under `src/nftfi/` whose SPDX header reads
`BUSL-1.1` are Copyright NFTfi and licensed under the Business Source
License 1.1:

- `src/nftfi/INftfiHub.sol`
- `src/nftfi/INftfiV2LoanBase.sol`
- `src/nftfi/INftfiV2LoanCoordinator.sol`
- `src/nftfi/INftfiV2LoanOffer.sol`
- `src/nftfi/INftfiV3Escrow.sol`
- `src/nftfi/INftfiV3LoanBase.sol`
- `src/nftfi/INftfiV3LoanCoordinator.sol`
- `src/nftfi/INftfiV3LoanOffer.sol`
- `src/nftfi/NftfiV2LoanData.sol`
- `src/nftfi/NftfiV3LoanData.sol`

Fabrica-authored integration contracts in the same directory (e.g.
`BuyWithNftfiV2Loan.sol`, `PayBackNftfiV3Loan.sol`) carry MIT SPDX headers
and are covered by the repository LICENSE.

## MetaStreet (BUSL-1.1)

- `src/meta-street/SimpleSignedPriceOracle.sol` is derived from MetaStreet
  code and licensed under the Business Source License 1.1.

Other files under `src/meta-street/` carry MIT SPDX headers.

## dYdX (Apache-2.0)

Files under `src/dydx/` are Copyright 2019 dYdX Trading Inc. and licensed
under the Apache License, Version 2.0 (see the license header in each file):

- `src/dydx/DydxFlashloanBase.sol`
- `src/dydx/ICallee.sol`
- `src/dydx/ISoloMargin.sol`
- `src/dydx/Math.sol`
- `src/dydx/Require.sol`
