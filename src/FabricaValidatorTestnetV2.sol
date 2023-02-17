// SPDX-License-Identifier: MIT
// Validator smart contract for Fabrica version 1.0

pragma solidity ^0.8.12;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./IFabricaValidatorV2.sol";


/**
 * @dev Implementation of the Fabrica validator smart contract
 *      Delegates the metadata `uri` function to this contract
 *      May add other fields in newer versions
 */
contract Validator is IValidator, Ownable {
    mapping(uint256 => uint256) private _scores;
    /**
     * @dev use network name subdomain and contract address + tokenId,
     *      no suffix '.json'
     *      the proxy contract address is hardcoded here
     *      (instead of using `address(this)`)
     */
    function uri(uint256 id) public pure returns (string memory) {
        return(
            string.concat(
                "https://metadata-staging.fabrica.land/goerli/0xE259e3626E282711DA4d988192cd807DB44CD7a0/",
                Strings.toString(id)
            )
        );
    }

    function score(uint256 id) public view returns (uint256) {
        return _scores[id];
    }

    /**
     * @dev Set score for a property
     */
    function setScore(uint256 id, uint256 propertyScore) public onlyOwner {
        _scores[id] = propertyScore;
    }

    /**
     * @dev Set scores for multiple properties
     */
    function setScores(uint256[] memory ids, uint256[] memory propertyScores) public onlyOwner {
        require(ids.length == propertyScores.length, "Validator: ids and scores length mismatch");
        for (uint256 i = 0; i < ids.length; i++) {
            _scores[ids[i]] = propertyScores[i];
        }
    }
}
