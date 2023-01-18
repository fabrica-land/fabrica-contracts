# fabrica-1155

`yarn && yarn build`

`yarn flatten`

`yarn test`

## Contract Addresses

### Goerli

- Fabrica Token: 0xABc0de77866855d9C4884279d22A5a98850Cb223

- Fabrica Proxy: 0x2E1feB1efecbadD1aED541eCd251656c23842ec2

- Testnet Validator Proxy: 0xfCea282244e184D5E8B1920F91446FC75AEA8Cd2

- Testnet Validator: 0xE57CC4B20459Fd1d759e73851A1b998d571525CC (returns testnet metadata link)

- Mainnet Validator: 0xbe82054ea677903039Fba3e50334F46F53000b9C (returns mainnet metadata link)

- Null address: 0x0000000000000000000000000000000000000000

## Deployment

1. Copy the `custom_flatten/FabricaToken1155.sol` file to [remix](https://remix.ethereum.org/) and deploy with Metamask.

2. Pass in `baseMetadataUri` with the values: `https://metadata-staging.fabrica.land/goerli/` (test nets, use network name at the end, e.g. `goerli`) or `https://metadata.fabrica.land/ethereum/` (main net). Remember to include the trailing `/`

3. Use Solidity compiler version `0.8.17+commit.8df45f5f` with no optimization

4. To verify the contract with constructor input, you need to compare the bytecodes from Remix versus the Etherscan and use the diff. The diff will be the `ABI-Encoded` constructor input for verifying the smart contract

Note: Sample metadata uri: https://metadata-goerli.fabrica.land/goerli/0x9b0582d387161d855421bb1d54c7150f09548eac/9656060115722854310

Latest deployment contract on Goerli:

Proxy: https://goerli.etherscan.io/address/0x2e1feb1efecbadd1aed541ecd251656c23842ec2#writeContract

Token: https://etherscan.io/address/0xABc0de77866855d9C4884279d22A5a98850Cb223 (transactions available at Proxy only)

Previous deployment contracts on Goerli:
https://goerli.etherscan.io/address/0x534137ae9f67c534878aa6edf554dd45e1be1265#code
https://goerli.etherscan.io/address/0x9b0582d387161d855421bb1d54c7150f09548eac
https://goerli.etherscan.io/address/0x7e0aedbb9c50d6fe3157b92c9755ea2cc683118c
https://goerli.etherscan.io/address/0xfbb0403140f41f0a8caff57ebbe6221a795da728#code
