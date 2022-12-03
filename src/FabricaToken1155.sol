// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC1155/ERC1155.sol)

pragma solidity ^0.8.12;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

/**
 * @dev Implementation of the Fabrica ERC1155 multi-token.
 * See https://eips.ethereum.org/EIPS/eip-1155
 * Originally based on code by Enjin: https://github.com/enjin/erc-1155
 *
 * _Available since v3.1._
 */
contract FabricaToken is Context, ERC165, IERC1155, IERC1155MetadataURI {
    using Address for address;

    // Struct needed to avoid stack too deep error
    struct Property {
        uint256 supply;
        string operatingAgreement;
        string definition;
        string configuration;
        address validator;
    }

    // Mapping from token ID to account balances
    mapping(uint256 => mapping(address => uint256)) private _balances;

    // Mapping from account to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    // Mapping from token ID to property info
    mapping(uint256 => Property) private _property;

    // For Opensea compatibility, `id` needs to convert to string, store base uri to construct the public uri
    // Default: `https://metadata.fabrtica.land/[chain_id]/[contract_address]/{id}.json`
    string private _baseUri = string(abi.encodePacked(
        "https://metadata.fabrica.land/",
        Strings.toString(block.chainid),
        "/",
        Strings.toHexString(address(this)),
        "/"
    ));
    // Used as the URI for all token types by relying on ID substitution, e.g. https://token-cdn-domain/{id}.json
    string private _uri = string.concat(_baseUri, "{id}.json");

    event Creation(string uri);

    /**
     * @dev See {_setURI}.
     */
    constructor() {
        emit Creation(_uri);
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC1155).interfaceId ||
            interfaceId == type(IERC1155MetadataURI).interfaceId ||
            super.supportsInterface(interfaceId);
    }

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
     */
    function uri(uint256 id) override public view returns (string memory) {
        return(
            string(abi.encodePacked(
                _baseUri,
                Strings.toString(id),
                ".json"
            ))
        );
    }

    /**
     * @dev `mint` does not minting to a 3rd party address
     */
    function mint(
        uint256 sessionId,
        uint256 supply,
        string memory definition,
        string memory operatingAgreement,
        string memory configuration,
        address validator
    ) public returns (uint256) {
        Property memory property;
        property.supply = supply;
        property.operatingAgreement = operatingAgreement;
        property.definition = definition;
        property.configuration = configuration;
        property.validator = validator;
        uint256 id = _mint(_msgSender(), sessionId, property, "");
        return id;
    }

    /**
     * @dev See {IERC1155-balanceOf}.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) public view virtual override returns (uint256) {
        require(account != address(0), "ERC1155: address zero is not a valid owner");
        return _balances[id][account];
    }

    /**
     * @dev See {IERC1155-balanceOfBatch}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] memory accounts, uint256[] memory ids)
        public
        view
        virtual
        override
        returns (uint256[] memory)
    {
        require(accounts.length == ids.length, "ERC1155: accounts and ids length mismatch");

        uint256[] memory batchBalances = new uint256[](accounts.length);

        for (uint256 i = 0; i < accounts.length; ++i) {
            batchBalances[i] = balanceOf(accounts[i], ids[i]);
        }

        return batchBalances;
    }

    /**
     * @dev See {IERC1155-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        _setApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC1155-isApprovedForAll}.
     */
    function isApprovedForAll(address account, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[account][operator];
    }

    /**
     * @dev See {IERC1155-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public virtual override {
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: caller is not token owner or approved"
        );
        _safeTransferFrom(from, to, id, amount, data);
    }

    /**
     * @dev See {IERC1155-safeBatchTransferFrom}.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public virtual override {
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: caller is not token owner or approved"
        );
        _safeBatchTransferFrom(from, to, ids, amounts, data);
    }

    // @dev only executable by > 70% owner
    function updateOperatingAgreement(string memory operatingAgreement, uint256 id) public returns (bool) {
        require(_percentOwner(_msgSender(), id, 70), "Only > 70% can update");
        _property[id].operatingAgreement = operatingAgreement;
        // TODO: emit event
        return true;
    }

    // @dev only executable by > 50% owner
    function updateConfiguration(string memory configuration, uint256 id) public returns (bool) {
        require(_percentOwner(_msgSender(), id, 50), "Only > 50% can update");
        _property[id].configuration = configuration;
        // TODO: emit event
        return true;
    }

    // @dev only executable by > 70% owner
    function updateValidator(address validator, uint256 id) public returns (bool) {
        require(_percentOwner(_msgSender(), id, 70), "Only > 70% can update");
        _property[id].validator = validator;
        // TODO: emit event
        return true;
    }

    // @dev `threshold`: percentage threshold
    function _percentOwner(address wallet, uint256 id, uint256 threshold) internal virtual returns (bool) {
        uint256 shares = _balances[id][wallet];
        if (shares == 0) {
            return false;
        }
        uint256 supply = _property[id].supply;
        if (supply == 0) {
            return false;
        }
        uint256 percent = Math.mulDiv(shares, 100, supply);
        return percent > threshold;
    }

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function _safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal virtual {
        require(to != address(0), "ERC1155: transfer to the zero address");

        address operator = _msgSender();
        uint256[] memory ids = _asSingletonArray(id);
        uint256[] memory amounts = _asSingletonArray(amount);

        _beforeTokenTransfer(operator, from, to, ids, amounts, data);

        uint256 fromBalance = _balances[id][from];
        require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");
        unchecked {
            _balances[id][from] = fromBalance - amount;
        }
        _balances[id][to] += amount;

        emit TransferSingle(operator, from, to, id, amount);

        _afterTokenTransfer(operator, from, to, ids, amounts, data);

        _doSafeTransferAcceptanceCheck(operator, from, to, id, amount, data);
    }

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function _safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");
        require(to != address(0), "ERC1155: transfer to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, to, ids, amounts, data);

        for (uint256 i = 0; i < ids.length; ++i) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            uint256 fromBalance = _balances[id][from];
            require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");
            unchecked {
                _balances[id][from] = fromBalance - amount;
            }
            _balances[id][to] += amount;
        }

        emit TransferBatch(operator, from, to, ids, amounts);

        _afterTokenTransfer(operator, from, to, ids, amounts, data);

        _doSafeBatchTransferAcceptanceCheck(operator, from, to, ids, amounts, data);
    }

    /**
     * @dev Sets a new URI for all token types, by relying on the token type ID
     * substitution mechanism
     * https://eips.ethereum.org/EIPS/eip-1155#metadata[defined in the EIP].
     *
     * By this mechanism, any occurrence of the `\{id\}` substring in either the
     * URI or any of the amounts in the JSON file at said URI will be replaced by
     * clients with the token type ID.
     *
     * For example, the `https://token-cdn-domain/\{id\}.json` URI would be
     * interpreted by clients as
     * `https://token-cdn-domain/000000000000000000000000000000000000000000000000000000000004cce0.json`
     * for token type ID 0x4cce0.
     *
     * See {uri}.
     *
     * Because these URIs cannot be meaningfully represented by the {URI} event,
     * this function emits no events.
     */
    function _setURI(string memory baseUri) internal virtual {
        _uri = string.concat(baseUri, "{id}.json");
    }

    /**
     * @dev Creates `amount` tokens of token type `id`, and assigns them to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     * - `definition` cannot be null.
     */
    function _mint(
        address to,
        uint sessionId,
        Property memory property,
        bytes memory data
    ) internal virtual returns(uint256) {
        // Note: `to` is default to the message sender, this validation should never fail
        require(to != address(0), "ERC1155: mint to the zero address");
        require(bytes(property.definition).length > 0, "Definition is required");
        require(sessionId > 0, "Valid sessionId is required");
        require(property.supply > 0, "Minimum supply is 1");

        address operator = _msgSender();

        uint256 amount = property.supply;

        /**
         * @dev hash sender address with sessionId to generate unique token Id
         *      format: string(sender_address) + string(sessionId) => hash to byte32 => cast to uint
         */
        string memory operatorString = Strings.toHexString(uint(uint160(operator)), 20);
        string memory idString = string.concat(operatorString, Strings.toString(sessionId));
        uint256 id = uint(keccak256(abi.encodePacked(idString)));

        require(_property[id].supply == 0, "Session ID already exist, please use a different one");

        // uint256[] memory ids = _asSingletonArray(id);
        // uint256[] memory amounts = _asSingletonArray(amount);

        // _beforeTokenTransfer(operator, address(0), to, ids, amounts, data);

        _balances[id][to] += amount;
        // Update property data
        _property[id] = property;

        emit TransferSingle(operator, address(0), to, id, amount);

        // _afterTokenTransfer(operator, address(0), to, ids, amounts, data);

        _doSafeTransferAcceptanceCheck(operator, address(0), to, id, amount, data);
        return id;
    }

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_mint}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    // function _mintBatch(
    //     address to,
    //     uint256[] memory ids,
    //     uint256[] memory amounts,
    //     bytes memory data
    // ) internal virtual {
    //     require(to != address(0), "ERC1155: mint to the zero address");
    //     require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

    //     address operator = _msgSender();

    //     _beforeTokenTransfer(operator, address(0), to, ids, amounts, data);

    //     for (uint256 i = 0; i < ids.length; i++) {
    //         _balances[ids[i]][to] += amounts[i];
    //     }

    //     emit TransferBatch(operator, address(0), to, ids, amounts);

    //     _afterTokenTransfer(operator, address(0), to, ids, amounts, data);

    //     _doSafeBatchTransferAcceptanceCheck(operator, address(0), to, ids, amounts, data);
    // }

    /**
     * @dev Destroys `amount` tokens of token type `id` from `from`
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `from` must have at least `amount` tokens of token type `id`.
     */
    // function _burn(
    //     address from,
    //     uint256 id,
    //     uint256 amount
    // ) internal virtual {
    //     require(from != address(0), "ERC1155: burn from the zero address");

    //     address operator = _msgSender();
    //     uint256[] memory ids = _asSingletonArray(id);
    //     uint256[] memory amounts = _asSingletonArray(amount);

    //     _beforeTokenTransfer(operator, from, address(0), ids, amounts, "");

    //     uint256 fromBalance = _balances[id][from];
    //     require(fromBalance >= amount, "ERC1155: burn amount exceeds balance");
    //     unchecked {
    //         _balances[id][from] = fromBalance - amount;
    //     }

    //     emit TransferSingle(operator, from, address(0), id, amount);

    //     _afterTokenTransfer(operator, from, address(0), ids, amounts, "");
    // }

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_burn}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     */
    // function _burnBatch(
    //     address from,
    //     uint256[] memory ids,
    //     uint256[] memory amounts
    // ) internal virtual {
    //     require(from != address(0), "ERC1155: burn from the zero address");
    //     require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

    //     address operator = _msgSender();

    //     _beforeTokenTransfer(operator, from, address(0), ids, amounts, "");

    //     for (uint256 i = 0; i < ids.length; i++) {
    //         uint256 id = ids[i];
    //         uint256 amount = amounts[i];

    //         uint256 fromBalance = _balances[id][from];
    //         require(fromBalance >= amount, "ERC1155: burn amount exceeds balance");
    //         unchecked {
    //             _balances[id][from] = fromBalance - amount;
    //         }
    //     }

    //     emit TransferBatch(operator, from, address(0), ids, amounts);

    //     _afterTokenTransfer(operator, from, address(0), ids, amounts, "");
    // }

    /**
     * @dev Approve `operator` to operate on all of `owner` tokens
     *
     * Emits an {ApprovalForAll} event.
     */
    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {
        require(owner != operator, "ERC1155: setting approval status for self");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning, as well as batched variants.
     *
     * The same hook is called on both single and batched variants. For single
     * transfers, the length of the `ids` and `amounts` arrays will be 1.
     *
     * Calling conditions (for each `id` and `amount` pair):
     *
     * - When `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * of token type `id` will be  transferred to `to`.
     * - When `from` is zero, `amount` tokens of token type `id` will be minted
     * for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens of token type `id`
     * will be burned.
     * - `from` and `to` are never both zero.
     * - `ids` and `amounts` have the same, non-zero length.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {}

    /**
     * @dev Hook that is called after any token transfer. This includes minting
     * and burning, as well as batched variants.
     *
     * The same hook is called on both single and batched variants. For single
     * transfers, the length of the `id` and `amount` arrays will be 1.
     *
     * Calling conditions (for each `id` and `amount` pair):
     *
     * - When `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * of token type `id` will be  transferred to `to`.
     * - When `from` is zero, `amount` tokens of token type `id` will be minted
     * for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens of token type `id`
     * will be burned.
     * - `from` and `to` are never both zero.
     * - `ids` and `amounts` have the same, non-zero length.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {}

    function _doSafeTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) private {
        if (to.isContract()) {
            try IERC1155Receiver(to).onERC1155Received(operator, from, id, amount, data) returns (bytes4 response) {
                if (response != IERC1155Receiver.onERC1155Received.selector) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non-ERC1155Receiver implementer");
            }
        }
    }

    function _doSafeBatchTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) private {
        if (to.isContract()) {
            try IERC1155Receiver(to).onERC1155BatchReceived(operator, from, ids, amounts, data) returns (
                bytes4 response
            ) {
                if (response != IERC1155Receiver.onERC1155BatchReceived.selector) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non-ERC1155Receiver implementer");
            }
        }
    }

    function _asSingletonArray(uint256 element) private pure returns (uint256[] memory) {
        uint256[] memory array = new uint256[](1);
        array[0] = element;

        return array;
    }
}
