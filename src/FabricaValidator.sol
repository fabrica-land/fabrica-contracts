// SPDX-License-Identifier: MIT
// Validator smart contract for Fabrica version 1.0

pragma solidity ^0.8.12;

import "@openzeppelin/contracts/utils/Strings.sol";
import "./IFabricaValidator.sol";


/**
 * @dev Implementation of the Fabrica validator smart contract
 *      Delegates the metadata `uri` function to this contract
 *      May add other fields in newer versions
 */
contract Validator is IValidator {
    /**
     * @dev use network name subdomain and contract address + tokenId,
     *      no suffix '.json'
     *      the proxy contract address is hardcoded here
     *      (instead of using `address(this)`)
     */
    function uri(uint256 id) public pure returns (string memory) {
        return(
            string.concat(
                "https://metadata.fabrica.land/ethereum/0x84afC90d163Ab18D4e66B7D9D9Db6cB60B6150E1/",
                Strings.toString(id)
            )
        );
    }
}
