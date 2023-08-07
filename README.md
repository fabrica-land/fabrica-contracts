# fabrica-1155

`yarn && yarn build`

`yarn flatten`

`yarn test`

## Contract Addresses

### Sepolia
- 1155 Token Implementation: https://sepolia.etherscan.io/token/0x2d818A6ff7f77a94805275e32f0E47c2e84109e5#code
- 1155 Token Proxy: https://sepolia.etherscan.io/token/0xa2F892f678Ce11b39d68126BC8781746Fec9BBa4#code
- Validator Implementation: https://sepolia.etherscan.io/token/0xeF2e0CA6BEe19eF3b036991074e04A4817601C59#code
- Validator Proxy: https://sepolia.etherscan.io/token/0xab591569C9D4D087B037D2DA774327D807f6a4CF#code

### Goerli

- Test token ID: 11043966458603065864

- Fabrica Token Proxy: [0xE259e3626E282711DA4d988192cd807DB44CD7a0](https://goerli.etherscan.io/address/0xe259e3626e282711da4d988192cd807db44cd7a0#code)

Previous: 0x2E1feB1efecbadD1aED541eCd251656c23842ec2

- Fabrica Token: 0xab591569C9D4D087B037D2DA774327D807f6a4CF

Previous: 0xABc0de77866855d9C4884279d22A5a98850Cb223

- Testnet Validator Proxy: [0xFF9dAe0F64382e9dDc0918A7704eF4777A7e0D6F](https://goerli.etherscan.io/address/0xFF9dAe0F64382e9dDc0918A7704eF4777A7e0D6F#code)

- Testnet Validator: 0xeB894D4404e159365173174F3aec5b8B654783D1

Previous: 0x876CD7299e296B3385C298cf24e6F1b9E3FE3cba (uses Proxy address as part of the uri)


### Main net

- Fabrica Token Proxy: [0xd8A38b46D8cF9813c7c9233B844DD0eC7D7e8750](https://etherscan.io/address/0xd8a38b46d8cf9813c7c9233b844dd0ec7d7e8750#code)

- Fabrica Token: 0x8E9d55A4cA3EdF7Bf3263F746AF404A2c985EdF7

- Mainnet Validator Proxy: [0x6fA2Ee5C9841163E88c85a40B70a90FCD5FBB68b](https://etherscan.io/address/0x6fa2ee5c9841163e88c85a40b70a90fcd5fbb68b#code)

- Mainnet Validator: 0x236fcc678E28e7eE97d83ae926087DC880D1D40D

- Null address: 0x0000000000000000000000000000000000000000


## Deployment steps

1. `yarn && yarn build` then `yarn flatten`

2. Copy and paste the files in folder `flatten/` to Remix and deploy

3. Use compiler version `v0.8.17+commit.8df45f5f`

4. Validator: (a) deploy validator proxy and verify source code on Etherscan, (b) update the validator proxy address in validator path, (c) build and flatten validator file, deploy with Remix, (d) verify source code on Etherscan, (e) set proxy implementation to the validator contract address, (f) verify proxy on Etherscan

5. Fabrica token: (a) input default validator with the validator proxy address, (b) build and flatten, deploy in Remix, verify source code, (c) deploy Fabrica proxy, verify source code, and verify proxy


## Archived

1. Copy the `custom_flatten/FabricaToken1155.sol` file to [remix](https://remix.ethereum.org/) and deploy with Metamask.

2. Pass in `baseMetadataUri` with the values: `https://metadata-staging.fabrica.land/goerli/` (test nets, use network name at the end, e.g. `goerli`) or `https://metadata.fabrica.land/ethereum/` (main net). Remember to include the trailing `/`

3. Use Solidity compiler version `0.8.17+commit.8df45f5f` with no optimization

4. To verify the contract with constructor input, you need to compare the bytecodes from Remix versus the Etherscan and use the diff. The diff will be the `ABI-Encoded` constructor input for verifying the smart contract

Note: Sample metadata uri: https://metadata-goerli.fabrica.land/goerli/0x9b0582d387161d855421bb1d54c7150f09548eac/9656060115722854310

Latest deployment contract on Goerli:

Proxy: https://goerli.etherscan.io/address/0x2e1feb1efecbadd1aed541ecd251656c23842ec2#writeContract

Token: https://etherscan.io/address/0xABc0de77866855d9C4884279d22A5a98850Cb223 (transactions available at Proxy only)

Previous deployment contracts on Goerli:
- https://goerli.etherscan.io/address/0x534137ae9f67c534878aa6edf554dd45e1be1265#code
- https://goerli.etherscan.io/address/0x9b0582d387161d855421bb1d54c7150f09548eac
- https://goerli.etherscan.io/address/0x7e0aedbb9c50d6fe3157b92c9755ea2cc683118c
- https://goerli.etherscan.io/address/0xfbb0403140f41f0a8caff57ebbe6221a795da728#code

Previous Sepolia contracts
- 1155 Token Proxy: 0x13364c9D131dC2e0C83Be9D2fD3edb6627536544
- 1155 Token Implementation: 0x62AB1aA5dE5a824969Fa954e57E1655896F48b86
- Validator Proxy: 0x0BC24a5c475232F9d2501fFc52C3685741d6F517
- Validator Implementation: 0xa991DDB60c5a17f1F022c587c30e65d70a8558cc
