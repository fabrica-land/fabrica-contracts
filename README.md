# fabrica-1155

`yarn && yarn build`

`yarn flatten`

`yarn test`

## Deployment

1. Copy the `custom_flatten/FabricaToken1155.sol` file to [remix](https://remix.ethereum.org/) and deploy with Metamask.

2. Pass in `baseMetadataUri` with the values: `https://metadata-staging.fabrica.land/goerli/` (test nets, use network name at the end, e.g. `goerli`) or `https://metadata.fabrica.land/ethereum/` (main net). Remember to include the trailing `/`

3. Use Solidity compiler version `0.8.17+commit.8df45f5f` with no optimization

4. To verify the contract with constructor input, you need to compare the bytecodes from Remix versus the Etherscan and use the diff. The diff will be the `ABI-Encoded` constructor input for verifying the smart contract

Note: Sample metadata uri: https://metadata-goerli.fabrica.land/goerli/0x9b0582d387161d855421bb1d54c7150f09548eac/9656060115722854310

Latest deployment contract on Goerli:
https://goerli.etherscan.io/address/0x534137ae9f67c534878aa6edf554dd45e1be1265#code

Previous deployment contracts on Goerli:
https://goerli.etherscan.io/address/0x9b0582d387161d855421bb1d54c7150f09548eac
https://goerli.etherscan.io/address/0x7e0aedbb9c50d6fe3157b92c9755ea2cc683118c
https://goerli.etherscan.io/address/0xfbb0403140f41f0a8caff57ebbe6221a795da728#code
