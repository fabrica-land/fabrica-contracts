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
    // Test net: https://metadata-staging.fabrica.land/goerli/
    // Main net: https://metadata.fabrica.land/ethereum/
    string private _baseMetadataUri = "https://metadata-staging.fabrica.land/goerli/";

    /**
     * @dev See {IERC1155MetadataURI-uri}.
     *
     * This implementation returns the same URI for *all* token types. It relies
     * on the token type ID substitution mechanism
     * https://eips.ethereum.org/EIPS/eip-1155#metadata[defined in the EIP].
     *
     * Clients calling this function must replace the `\{id\}` substring with the
     * actual token type ID.
     *
     * function uri(uint256) public view virtual override returns (string memory) {return _uri;}
     *
     * Fabrica: use network name subdomain and contract address + tokenId, no suffix '.json'
     */
    function uri(uint256 id) public view returns (string memory) {
        return(
            string.concat(
                _baseMetadataUri,
                Strings.toHexString(address(this)),
                "/",
                Strings.toString(id)
            )
        );
    }
}
