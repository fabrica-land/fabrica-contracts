// SPDX-License-Identifier: MIT

pragma solidity ^0.8.28;

/**
 * @dev Public interface of the Fabrica ERC1155 multi-token.
 */
interface IFabricaToken {
    // Mapping from token ID to property info
    function _property(uint256 tokenId) external view returns (
        uint256 supply,
        string memory operatingAgreement,
        string memory definition,
        string memory configuration,
        address validator
    );

    // On-chain data update
    event UpdateConfiguration(uint256, string newData);
    event UpdateOperatingAgreement(uint256, string newData);
    event UpdateValidator(uint256 tokenId, string dataType, address validator);

    function setDefaultValidator(address newDefaultValidator) external;

    function defaultValidator() external view returns (address);

    function setValidatorRegistry(address newValidatorRegistry) external;

    function validatorRegistry() external view returns (address);

    /**
     * @dev `mint` allows users to mint to 3rd party (although it allows to mint to self as well)
     */
    function mint(
        address[] memory recipients,
        uint256 sessionId,
        uint256[] memory amounts,
        string memory definition,
        string memory operatingAgreement,
        string memory configuration,
        address validator
    ) external returns (uint256);

    /**
     * @dev `mintBatch` allows users to mint in bulk
     */
    function mintBatch(
        address[] memory recipients,
        uint256[] memory sessionIds,
        uint256[] memory amounts,
        string[] memory definitions,
        string[] memory operatingAgreements,
        string[] memory configurations,
        address[] memory validators
    ) external returns (uint256[] memory ids);

    function burn(
        address from,
        uint256 id,
        uint256 amount
    ) external returns (bool success);

    function burnBatch(
        address from,
        uint256[] memory ids,
        uint256[] memory amounts
    ) external returns (bool success);

    /**
     * @dev generate token id (to avoid frontrunning)
     */
    function generateId(
        address operator,
        uint256 sessionId,
        string memory operatingAgreement
    ) external view returns(uint256);

    // @dev only executable by > 70% owner
    function updateOperatingAgreement(
        string memory operatingAgreement,
        uint256 id
    ) external returns (bool);

    // @dev only executable by > 50% owner
    function updateConfiguration(
        string memory configuration,
        uint256 id
    ) external returns (bool);

    // @dev only executable by > 70% owner
    function updateValidator(
        address validator,
        uint256 id
    ) external returns (bool);
}
