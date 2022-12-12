# fabrica-1155

`yarn && yarn build`

`yarn flatten`

`yarn test`

## Deployment

1. Copy the `custom_flatten/FabricaToken1155.sol` file to [remix](https://remix.ethereum.org/) and deploy with Metamask.

2. Use Solidity compiler version 0.8.17+commit.8df45f5f with no optimization

3. To verify the contract with constructor input, you need to compare the bytecodes from Remix versus the Etherscan and use the diff. The diff will be the `ABI-Encoded` constructor input for verifying the smart contract

Latest deployment contract on Goerli:
https://goerli.etherscan.io/address/0x7e0aedbb9c50d6fe3157b92c9755ea2cc683118c

Previous deployment contracts on Goerli:
https://goerli.etherscan.io/address/0xfbb0403140f41f0a8caff57ebbe6221a795da728#code
