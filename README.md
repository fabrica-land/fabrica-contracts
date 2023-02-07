# fabrica-1155

`yarn && yarn build`

`yarn flatten`

`yarn test`

## Contract Addresses

### Main net

- Fabrica Token Proxy: [0xd8A38b46D8cF9813c7c9233B844DD0eC7D7e8750](https://etherscan.io/address/0xd8a38b46d8cf9813c7c9233b844dd0ec7d7e8750#code)

- Fabrica Token: 0x8E9d55A4cA3EdF7Bf3263F746AF404A2c985EdF7

- Mainnet Validator Proxy: [0x6fA2Ee5C9841163E88c85a40B70a90FCD5FBB68b](https://etherscan.io/address/0x6fa2ee5c9841163e88c85a40b70a90fcd5fbb68b#code)

- Mainnet Validator: 0x236fcc678E28e7eE97d83ae926087DC880D1D40D

### Goerli

- Test token ID: 11043966458603065864

- Fabrica Token Proxy: [0xE259e3626E282711DA4d988192cd807DB44CD7a0](https://goerli.etherscan.io/address/0xe259e3626e282711da4d988192cd807db44cd7a0#code)

Previous: 0x2E1feB1efecbadD1aED541eCd251656c23842ec2

- Fabrica Token: 0xab591569C9D4D087B037D2DA774327D807f6a4CF

Previous: 0xABc0de77866855d9C4884279d22A5a98850Cb223

- Testnet Validator Proxy: [0xFF9dAe0F64382e9dDc0918A7704eF4777A7e0D6F](https://goerli.etherscan.io/address/0xFF9dAe0F64382e9dDc0918A7704eF4777A7e0D6F#code)

- Testnet Validator: 0xeB894D4404e159365173174F3aec5b8B654783D1

Previous: 0x876CD7299e296B3385C298cf24e6F1b9E3FE3cba (uses Proxy address as part of the uri)

### Handy variables
- Null address: 0x0000000000000000000000000000000000000000


## Deployment steps

1. `yarn && yarn build` then `yarn flatten`

2. Copy and paste the files in folder `flatten/` to Remix and deploy

3. Use compiler version `v0.8.17+commit.8df45f5f`

4. Validator: (a) deploy validator proxy and verify source code on Etherscan, (b) update the validator proxy address in validator path, (c) build and flatten validator file, deploy with Remix, (d) verify source code on Etherscan, (e) set proxy implementation to the validator contract address, (f) verify proxy on Etherscan

5. Fabrica token: (a) input default validator with the validator proxy address, (b) build and flatten, deploy in Remix, verify source code, (c) deploy Fabrica proxy, verify source code, and verify proxy

6. To verify the contract with constructor input, you need to compare the bytecodes from Remix versus the Etherscan and use the diff. The diff will be the `ABI-Encoded` constructor input for verifying the smart contract

## Chainlink

### Goerli

- Fabrica API Consumer: [0x03968Ca1DFEa7B1c180681bd6a927577258c6Ce8](https://goerli.etherscan.io/address/0x03968ca1dfea7b1c180681bd6a927577258c6ce8#code)

- Note: remember to send 0.1 LINK token to the contract before running the oracle

- Note: After the contract is flattened, rename abstract contract ENSResolver to abstract contract ENSResolver_Chainlink
