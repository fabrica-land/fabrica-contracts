# Third-Party Notices

Code authored by Fabrica Inc. in this repository is licensed under the MIT
License (see [LICENSE](LICENSE)). The following vendored third-party files
retain their original licenses and are NOT covered by the MIT grant. Copies
of the applicable upstream license texts are bundled in [`licenses/`](licenses/).

## NFTfi (BUSL-1.1, converted per its Change Date)

Interface and loan-data files under `src/nftfi/` whose SPDX header reads
`BUSL-1.1` are Copyright (c) 2021 NFTfi Genesis, originally licensed under the
Business Source License 1.1 with the parameters bundled at
[`licenses/NFTfi-v2-BUSL-1.1.md`](licenses/NFTfi-v2-BUSL-1.1.md) (upstream:
[NFTfi-Genesis/nftfi.eth](https://github.com/NFTfi-Genesis/nftfi.eth)).
Per those parameters, the Change Date was no later than 2026-01-31 and the
Change License is GNU General Public License v2.0 or later, so this code is
now additionally available under GPL-2.0-or-later.

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

## MetaStreet (BUSL-1.1, converted to MIT per its Change Date)

`src/meta-street/SimpleSignedPriceOracle.sol` is derived from MetaStreet v2
code, Copyright (c) 2023 MetaStreet Labs, originally licensed under the
Business Source License 1.1 with the parameters bundled at
[`licenses/MetaStreet-v2-BUSL-1.1.txt`](licenses/MetaStreet-v2-BUSL-1.1.txt)
(upstream:
[metastreet-labs/metastreet-contracts-v2](https://github.com/metastreet-labs/metastreet-contracts-v2)).
Per those parameters, the Change Date was no later than 2025-06-01 and the
Change License is MIT, so this code is now available under the MIT License
(Copyright MetaStreet Labs).

Other files under `src/meta-street/` carry MIT SPDX headers.

## Seaport / OpenSea (MIT)

Files under `src/seaport/` are vendored from OpenSea's Seaport protocol,
Copyright (c) 2023 Ozone Networks, Inc., licensed under the MIT License. The
upstream copyright and permission notice is bundled at
[`licenses/Seaport-MIT.txt`](licenses/Seaport-MIT.txt) (upstream:
[ProjectOpenSea/seaport](https://github.com/ProjectOpenSea/seaport)).

- `src/seaport/ConsiderationEnums.sol`
- `src/seaport/ConsiderationInterface.sol`
- `src/seaport/ConsiderationStructs.sol`
- `src/seaport/PointerLibraries.sol`

## dYdX (Apache-2.0)

Files under `src/dydx/` are Copyright 2019 dYdX Trading Inc. and licensed
under the Apache License, Version 2.0. A copy of the license is bundled at
[`licenses/dYdX-Apache-2.0.txt`](licenses/dYdX-Apache-2.0.txt) (upstream:
[dydxprotocol/solo](https://github.com/dydxprotocol/solo)).

- `src/dydx/DydxFlashloanBase.sol`
- `src/dydx/ICallee.sol`
- `src/dydx/ISoloMargin.sol`
- `src/dydx/Math.sol`
- `src/dydx/Require.sol`
