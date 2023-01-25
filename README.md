# fabrica-1155

`yarn && yarn build`

`yarn flatten`

`yarn test`

## Contract Addresses

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

- Fabrica Token Proxy: 0xf51f64ADa27c882B737cCe150d31827B2971dc4D
Failed: [0x84afC90d163Ab18D4e66B7D9D9Db6cB60B6150E1](https://etherscan.io/address/0x84afc90d163ab18d4e66b7d9d9db6cb60b6150e1#code)

- Fabrica Token: 0xDa5F9606CF3EAa7d6F9aC4879fB9218e5b780463

- Mainnet Validator Proxy:
Attempt:
Works: 0x1076b35aD477dB4B0234031C22732D75f0131484
Failed: 0xCA896139E283fb7e6012D2A8c900F391d51197CA
Failed: 0xb53f5c06E5D6e75DF8daA4bd1296811411A4203e
Failed and contacted support: 0x88Fdea798ff484966e5c1F1402fD9204fEBA33c9
Failed: 0x958D528e215873be27ebA1EEc3c3b0e9F35256eB
Not working: [0x3Ac4A3C1234a992646D38e7254171C63D498bb59](https://etherscan.io/address/0x3ac4a3c1234a992646d38e7254171c63d498bb59#code)

- Mainnet Validator: 0x50F2CD980cF7E2A9F0453aE5A454adE355D9F3F0

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
https://goerli.etherscan.io/address/0x534137ae9f67c534878aa6edf554dd45e1be1265#code
https://goerli.etherscan.io/address/0x9b0582d387161d855421bb1d54c7150f09548eac
https://goerli.etherscan.io/address/0x7e0aedbb9c50d6fe3157b92c9755ea2cc683118c
https://goerli.etherscan.io/address/0xfbb0403140f41f0a8caff57ebbe6221a795da728#code
