# fabrica-contracts

## Contract Addresses

### Ethereum Mainnet Contracts
- 1155 Token Proxy: [0x5cbeb7a0df7ed85d82a472fd56d81ed550f3ea95](https://etherscan.io/token/0x5cbeb7a0df7ed85d82a472fd56d81ed550f3ea95#readProxyContract)
- 1155 Token Implementation: `0x7c26B9e463554b2FD348eafAB33A5928Fdba3a73`
- Validator Proxy: [0x170511f95560A1F280c29026f73a9cD6a4bA8ab0](https://etherscan.io/address/0x170511f95560A1F280c29026f73a9cD6a4bA8ab0#readProxyContract)
- Validator Implementation: `0x33F1b76603DBf84b2717f17A4ea0CCb2c94fFbF0`
- Validator Registry Proxy: [0xB5dE693F6fa91D25EFa61BA740F0B4766a8DA6E5](https://sepolia.etherscan.io/token/0xB5dE693F6fa91D25EFa61BA740F0B4766a8DA6E5#readProxyContract)
- Validator Registry Implementation: `0xBeC03A6C37D985C86F0e6A91ACbdD487B45B259b`
- NFTfi v3 Loan Pay-Back:

### Sepolia Contracts
- 1155 Token Proxy: [0xb52ED2Dc8EBD49877De57De3f454Fd71b75bc1fD](https://sepolia.etherscan.io/token/0xb52ED2Dc8EBD49877De57De3f454Fd71b75bc1fD#readProxyContract)
- 1155 Token Implementation: `0x719542E4422d1F896d6d1Cca358FD31F8153106c`
- Validator Proxy: [0xAAA7FDc1A573965a2eD47Ab154332b6b55098008](https://sepolia.etherscan.io/address/0xAAA7FDc1A573965a2eD47Ab154332b6b55098008#readProxyContract)
- Validator Implementation: `0xea409961530b6dfb4b82debad0ba99271bc350d7`
- Validator Registry Proxy: [0xb54392209537606F30bC056f3D83d0771A69c9ba](https://sepolia.etherscan.io/token/0xb54392209537606F30bC056f3D83d0771A69c9ba#readProxyContract)
- Validator Registry Implementation: `0xc60657bdd358b95be80266f3b7be15dc856a41b9`
- Fee Collection Proxy: [0x24888646723ae14C83E5354431753675A3d12D3c](https://sepolia.etherscan.io/address/0x24888646723ae14c83e5354431753675a3d12d3c#readProxyContract)
- Fee Collection Implementation: `0xc6e6dabd25f3ed98ceb98da26a934e269b62fd58`
- NFTfi v3 Loan Pay-Back: [0x925f2BD542cEc764f4444C890c20048C8E99092B](https://sepolia.etherscan.io/address/0x925f2BD542cEc764f4444C890c20048C8E99092B#writeContract)

### Base-Sepolia Contracts
- 1155 Token Proxy: [0xCE53C17A82bd67aD835d3e2ADBD3e062058B8F81](https://sepolia.basescan.org/address/0xCE53C17A82bd67aD835d3e2ADBD3e062058B8F81#readProxyContract)
- 1155 Token Implementation: `0x59ea6435588f7e9599166cc77da6a1af3973e2a4`
- Validator Proxy: [0x40Ac72C5C7712566eB5552fb1aB2093FA07B9682](https://sepolia.basescan.org/address/0x40Ac72C5C7712566eB5552fb1aB2093FA07B9682#readProxyContract)
- Validator Implementation: `0xd07d4860ee356d0413159071c9aa403c9d21643e`
- Validator Registry Proxy: [0xF9C41f9FC2b44645A6788ED95E433BD5e96a2e24](https://sepolia.basescan.org/address/0xF9C41f9FC2b44645A6788ED95E433BD5e96a2e24#readProxyContract)
- Validator Registry Implementation: `0xa24dc4f04d1ac9b41df0f7c2c772a9c0192d9c3b`
- Fee Collection Proxy: [0xa991DDB60c5a17f1F022c587c30e65d70a8558cc]()
- Fee Collection Implementation: `0x62AB1aA5dE5a824969Fa954e57E1655896F48b86`
- NFTfi v3 Loan Pay-Back: [0xaa89b922f9f416af44a2bb98cab8c7024f764e90](https://sepolia.basescan.org/address/0xaa89b922f9f416af44a2bb98cab8c7024f764e90#writeContract)

### Common
- Null address: `0x0000000000000000000000000000000000000000`

## Deploying Initial Contracts and Proxies
1. `yarn && yarn rebuild`
2. Copy and paste the files in folder `custom_flatten/` to Remix.
3. Use compiler version `v0.8.28+commit.7893614a` with optimization enabled and runs set to 1.
4. Validator:
   1. Deploy the `FabricaValidator` contract and verify the source code on Etherscan (be sure to set optimize to true and runs to 1); copy address
   2. Deploy the `FabricaProxy` contract with these constructor arguments, and verify the source code on Etherscan (optimize, 1 run):
      1. `_logic` set to the pasted validator implementation address
      2. `_admin` set to the deployment-account address, or `0x0000000000000000000000000000000000000000` (same effect)
      3. `_data` set to `0x8129fc1c` (which is an ABI-packed call to `intitialize` with no arguments)
   3. After deploying the token proxy (next step), call `setBaseUri` in Write as Proxy on the validator proxy in Etherscan
      to set the value to `https://metadata.fabrica.land/<network_name>/<token_proxy_address>/`. The trailing
      slash is mandatory.
5. ERC-1155 token:
   1. Deploy the `FabricaToken` contract and verify the source code on Etherscan; copy address
   2. Deploy the `FabricaProxy` contract with these constructor arguments:
      1. `_logic` set to the pasted token implementation address
      2. `_admin` set to the deployment-account address, or `0x0000000000000000000000000000000000000000` (same effect)
      3. `_data` set to `0x8129fc1c` (which is an ABI-packed call to `intitialize` with no arguments)
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
the next integer that hasn't been implemented and pass it in, e.g. `function initializeV2() public reinitialize(2) {`

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

## Onchain Traits Deployment
- Deploy and verify the validator-registry contract
- Deploy and verify the validator-registry proxy, setting the initial implementation and calling `initialize` in the data
- Add the Fabrica v3 Validator name, pointing to the validator proxy
- Test the `name` method
- Deploy and verify the new validator implementation
- Call upgradeTo on the validator proxy
- Add the trust names for each of our operating-agreement versions
- Test the `operatingAgreementName` method
- Set and test the default operating agreement
- Deploy and verify the new token implementation
- Call `upgradeToAndCall` on the token proxy, calling `initializeV3`
- Call `setValidatorRegistry` with the address of the registry proxy
- Call `updateValidator` and `updateOperatingAgreement` on a token
- Test `getTraitValue` with each, and test `getTraitValues` with both

## Archived

### Previous Mainnet Contracts
- 1155 Token Proxy: [0xd8A38b46D8cF9813c7c9233B844DD0eC7D7e8750](https://etherscan.io/token/0xd8a38b46d8cf9813c7c9233b844dd0ec7d7e8750#readProxyContract)
- 1155 Token Implementations:
  - `0xd1336777Df7c9cA43842F91EEcf74bD4BE70c477`
  - `0x8E9d55A4cA3EdF7Bf3263F746AF404A2c985EdF7`
  - `0x58fe23aeb6e7768457fbc1c89f303835a9de2956`
  - `0x43c6eE9D5B2369C5484f69E2Eb3361466855beDd`
  - `0xAc060b48bdd8680b7fCcB8563D78e1B85219485B`
- Validator Proxy: [0x6fA2Ee5C9841163E88c85a40B70a90FCD5FBB68b](https://etherscan.io/address/0x6fa2ee5c9841163e88c85a40b70a90fcd5fbb68b#readProxyContract)
- Validator Implementations:
  - `0x236fcc678E28e7eE97d83ae926087DC880D1D40D`
  - `0x7dEd932Ff0AD55F1D12436A29bCAE846C2115A7C`

### Previous Sepolia Contracts
- 1155 Token Proxy: https://sepolia.etherscan.io/token/0x13364c9D131dC2e0C83Be9D2fD3edb6627536544#code
- 1155 Token Implementations:
  - `0xBb865345aAb0D2d6Eb93dfE5D4c0a3930c36140B`
  - `0x62AB1aA5dE5a824969Fa954e57E1655896F48b86`
  - `0x07e5bd197335c0d452e74c67733402b741a74bd1`
  - `0x43c6eE9D5B2369C5484f69E2Eb3361466855beDd`
  - `0x349558BBb0dC364Ef7E2006E1BaFd8f705b42fEC`
- Validator Proxy: https://sepolia.etherscan.io/address/0x0BC24a5c475232F9d2501fFc52C3685741d6F517#code
- Validator Implementations:
    - `0xa991DDB60c5a17f1F022c587c30e65d70a8558cc`
    - `0x1Bb59487B8A255cd0Cd01e9a0C493e208843860a`

### Previous Goerli Contracts (Goerli is completely deprecated)
- 1155 Token Proxies:
  - [0xE259e3626E282711DA4d988192cd807DB44CD7a0](https://goerli.etherscan.io/token/0xe259e3626e282711da4d988192cd807db44cd7a0#readProxyContract)
  - [0x2E1feB1efecbadD1aED541eCd251656c23842ec2](https://goerli.etherscan.io/address/0x2e1feb1efecbadd1aed541ecd251656c23842ec2#readProxyContract)
- 1155 Token Implementations:
  - `0xab591569C9D4D087B037D2DA774327D807f6a4CF`
  - `0xABc0de77866855d9C4884279d22A5a98850Cb223`
  - `0x534137ae9f67c534878aa6edf554dd45e1be1265#code`
  - `0x9b0582d387161d855421bb1d54c7150f09548eac`
  - `0x7e0aedbb9c50d6fe3157b92c9755ea2cc683118c`
  - `0xfbb0403140f41f0a8caff57ebbe6221a795da728#code`
- Validator Proxy: [0xFF9dAe0F64382e9dDc0918A7704eF4777A7e0D6F](https://goerli.etherscan.io/address/0xFF9dAe0F64382e9dDc0918A7704eF4777A7e0D6F#readProxyContract)
- Validator Implementation: `0xeB894D4404e159365173174F3aec5b8B654783D1`
- Test token ID: `11043966458603065864`
