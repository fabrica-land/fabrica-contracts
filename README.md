# fabrica-1155

## Contract Addresses

### Sepolia
- 1155 Token Proxy: https://sepolia.etherscan.io/token/0xa2F892f678Ce11b39d68126BC8781746Fec9BBa4#code
- 1155 Token Implementation: https://sepolia.etherscan.io/token/0xf4E09a171bfBefBE4113e91603EF5a99e76dd366#code
- Validator Proxy: https://sepolia.etherscan.io/token/0xFfF595A28EB4C83CD7AFB758Cd021F98226E840f#code
- Validator Implementation: https://sepolia.etherscan.io/token/0x7C649c06E9DA1A56E0ef67E813ee425FF3b5eC39#code

### Goerli
- 1155 Token Proxy: [0xE259e3626E282711DA4d988192cd807DB44CD7a0](https://goerli.etherscan.io/address/0xe259e3626e282711da4d988192cd807db44cd7a0#code)
- 1155 Token Implementation: 0xab591569C9D4D087B037D2DA774327D807f6a4CF
- Validator Proxy: [0xFF9dAe0F64382e9dDc0918A7704eF4777A7e0D6F](https://goerli.etherscan.io/address/0xFF9dAe0F64382e9dDc0918A7704eF4777A7e0D6F#code)
- Validator Implementation: 0xeB894D4404e159365173174F3aec5b8B654783D1
- Test token ID: 11043966458603065864

### Ethereum Mainnet
- 1155 Token Proxy: [0xd8A38b46D8cF9813c7c9233B844DD0eC7D7e8750](https://etherscan.io/address/0xd8a38b46d8cf9813c7c9233b844dd0ec7d7e8750#code)
- 1155 Token Implementation: 0x8E9d55A4cA3EdF7Bf3263F746AF404A2c985EdF7
- Validator Proxy: [0x6fA2Ee5C9841163E88c85a40B70a90FCD5FBB68b](https://etherscan.io/address/0x6fa2ee5c9841163e88c85a40b70a90fcd5fbb68b#code)
- Validator Implementation: 0x236fcc678E28e7eE97d83ae926087DC880D1D40D

### Common
- Null address: 0x0000000000000000000000000000000000000000

## Deploying Initial Contracts and Proxies
1. `yarn && yarn rebuild`
2. Copy and paste the files in folder `flatten/` to Remix.
3. Use compiler version `v0.8.21` with optimization enabled and runs set to 1.
4. Validator:
   1. Deploy the FabricaValidator contract and verify the source code on Etherscan (be sure to set optimize to true and runs to 1); copy address
   2. Deploy the FabricaProxy contract with these constructor arguments, and verify the source code on Etherscan (optimize, 1 run):
      1. _logic set to the pasted validator implementation address
      2. _admin set to the deployment-account address, or `0x0000000000000000000000000000000000000000` (same effect)
      3. _data set to `0x8129fc1c` (which is an ABI-packed call to `intitialize` with no arguments)
   3. After deploying the token proxy (next step), call `setBaseUri` in Write as Proxy on the validator proxy in Etherscan
      to set the value to `https://metadata[-staging].fabrica.land/<network_name>/<token_proxy_address>/`. The trailing
      slash is mandatory.
5. ERC-1155 token:
   1. Deploy the FabricaToken contract and verify the source code on Etherscan; copy address
   2. Deploy the FabricaProxy contract with these constructor arguments:
      1. _logic set to the pasted token implementation address
      2. _admin set to the deployment-account address, or `0x0000000000000000000000000000000000000000` (same effect)
      3. _data set to `0x8129fc1c` (which is an ABI-packed call to `intitialize` with no arguments)
   3. Verify the source of the proxy on Etherscan (optimize, 1 run). Use the following tool to generate an ABI packing
      of the constructor arguments: https://abi.hashex.org/ and add `0x` to the front of it. Paste this into Etherscan.
   4. Call `setDefaultValidator` in "Write as Proxy" on Etherscan: set the value to the validator proxy address

## Upgrading Implementations

There are two cases: the simple case (no new initializer), and the complex case, where you implement a new initializer.
In the simple case, you can simply call `upgradeTo` in "Write as Proxy" on the proxy address in Etherscan, passing in
the address of the newly-deployed implementation contract as `newImplementation`.

The complex case comes into play if you add an inheritance to a contract that has a constructor. You need to instead
inherit from the upgradeable version of the contract (node_modules/@openzeppelin/contract-upgradeable), and add its
__ClassName_init(); method to a new initializer in your contract. Initializers can only be called once, so the new
initializer is added and the initial `initialize` method is left alone. The new initializer has a new name
(e.g. initializeV2) and carries the reinitializer modifier (instead of initializer), which accepts an integer. So take
the next integer that hasn't been implemented and pass it in, e.g. `function initializeV2() public reinitlize(2) {`

In the complex case, you need to call `upgradeToAndCall` in "Write as Proxy" on the proxy contract on Etherscan.
Pass `0` ETH for the `payableAmount`, the new implementation address in `newImplementation`, and in `data` you need
to pass in ABI-packed bytes of the name of the new initializer and any arguments. You can generate the ABI-packed
string using this tool: https://abi.hashex.org/ and don't forget to add `0x` in front of the result.

In either case, first deploy the new implementation and verify its source. Then call upgradeTo or upgradeToAndCall
as indicated above.

Make sure:
- Constructor is not changed (it invalidates initializers)
- Old initializers are not changed
- Any new initialization logic is in a new initializer with the `reinitialize(nextVersionNumber)` modifier
- New initializer calls __ClassName_init(); on any new upgradeable contracts that are inherited
- New initializer is passed to `upgradeToAndCall` as a packed ABI call (see above)

## Archived

### Previous Goerli contracts
- Proxy: https://goerli.etherscan.io/address/0x2e1feb1efecbadd1aed541ecd251656c23842ec2#writeContract
- Token: https://etherscan.io/address/0xABc0de77866855d9C4884279d22A5a98850Cb223 (transactions available at Proxy only)
- https://goerli.etherscan.io/address/0x534137ae9f67c534878aa6edf554dd45e1be1265#code
- https://goerli.etherscan.io/address/0x9b0582d387161d855421bb1d54c7150f09548eac
- https://goerli.etherscan.io/address/0x7e0aedbb9c50d6fe3157b92c9755ea2cc683118c
- https://goerli.etherscan.io/address/0xfbb0403140f41f0a8caff57ebbe6221a795da728#code

### Previous Sepolia contracts
- 1155 Token Proxy: https://sepolia.etherscan.io/token/0x13364c9D131dC2e0C83Be9D2fD3edb6627536544#code
- 1155 Token Implementation: https://sepolia.etherscan.io/token/0x62AB1aA5dE5a824969Fa954e57E1655896F48b86#code
- Validator Proxy: https://sepolia.etherscan.io/address/0x0BC24a5c475232F9d2501fFc52C3685741d6F517#code
- Validator Implementation: https://sepolia.etherscan.io/address/0xa991DDB60c5a17f1F022c587c30e65d70a8558cc#code
