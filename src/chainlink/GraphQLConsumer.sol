// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";
import "@chainlink/contracts/src/v0.8/ConfirmedOwner.sol";

/**
 * IMPORTANT: READ HERE FIRST
 * After the contract is flattened, rename abstract contract ENSResolver to abstract contract ENSResolver_Chainlink
 */


/**
 * Request testnet LINK and ETH here: https://faucets.chain.link/
 * Find information on LINK Token Contracts and get the latest ETH and LINK faucets here: https://docs.chain.link/docs/link-token-contracts/
 */

/**
 * THIS IS AN EXAMPLE CONTRACT WHICH USES HARDCODED VALUES FOR CLARITY.
 * THIS EXAMPLE USES UN-AUDITED CODE.
 * DO NOT USE THIS CODE IN PRODUCTION.
 */

contract GraphQLConsumer is ChainlinkClient, ConfirmedOwner {
    using Chainlink for Chainlink.Request;

    mapping (bytes32 => string) public requestIdToTokenId;
    mapping (string => uint256) public tokenIdToScore;

    bytes32 private jobId;
    uint256 private fee;

    event FetchScore(bytes32 indexed requestId, uint256 score);

    /**
     * @notice Initialize the link token and target oracle
     *
     * Goerli Testnet details:
     * Link Token: 0x326C977E6efc84E512bB9C30f76E30c160eD06FB
     * Oracle: 0xCC79157eb46F5624204f47AB42b3906cAA40eaB7 (Chainlink DevRel)
     * jobId: ca98366cc7314957b8c012c72f05aeeb
     *
     */
    constructor() ConfirmedOwner(msg.sender) {
        setChainlinkToken(0x326C977E6efc84E512bB9C30f76E30c160eD06FB);
        // Chainlink suggested validators aren't responding, get a response from the Chainlink's developer Discord
        // https://github.com/oraclelabs-link/chainlink-node-public-jobs/tree/master/ethereum-goerli/HTTP%20Get%20%3E%20Uint256
        setChainlinkOracle(0x7ecFBD6CB2D3927Aa68B5F2f477737172F11190a);
        jobId = "beb323d08e56408a8c85271b2db4f196";
        // fee = (1 * LINK_DIVISIBILITY) / 10; // 0,1 * 10**18 (Varies by network and job)
        fee = (25 * LINK_DIVISIBILITY) / 1000; // 0,025 * 10**18 (Varies by network and job)
    }

    /**
     * Create a Chainlink request to retrieve API response, find the target
     * data, then multiply by 1000000000000000000 (to remove decimal places from data).
     */
    function fetchScore(string memory _tokenId) public returns (bytes32 requestId) {
        Chainlink.Request memory req = buildChainlinkRequest(
            jobId,
            address(this),
            this.fulfill.selector
        );
        bytes32 _requestId;
        string memory _url = "https://api3.fabrica.land/graphql";
        string memory _query = "query Token($network: String!, $contractAddress: String!, $tokenId: String!) { token(network: $network, contractAddress: $contractAddress, tokenId: $tokenId) {score}}";
        string memory _variables = string(
            abi.encodePacked(
                "{\"contractAddress\": \"0xd8a38b46d8cf9813c7c9233b844dd0ec7d7e8750\", \"network\": \"ethereum\", \"tokenId\": \"",
                _tokenId,
                "\"}"
            )
        );
        string memory _requestUrl = string(
            abi.encodePacked(
                _url,
                "?query=",
                _query,
                "&variables=",
                _variables
            )
        );

        // Set the URL to perform the GET request on
        req.add(
            "get",
            _requestUrl
        );

        // Set the path to find the desired data in the API response, where the response format is:
        // {
        //     "data": {
        //         "token": {
        //         "score": 1132
        //         }
        //     }
        // }
        // request.add("path", "data.token.score"); // Chainlink nodes prior to 1.0.0 support this format
        req.add("path", "data,token,score"); // Chainlink nodes 1.0.0 and later support this format

        // Multiply the result by 1000000000000000000 to remove decimals
        int256 timesAmount = 10 ** 18;
        req.addInt("times", timesAmount);

        // Sends the request
        _requestId = sendChainlinkRequest(req, fee);
        requestIdToTokenId[_requestId] = _tokenId;
        return _requestId;
    }

    /**
     * Receive the response in the form of uint256
     */
    function fulfill(
        bytes32 _requestId,
        uint256 _score
    ) public recordChainlinkFulfillment(_requestId) {
        emit FetchScore(_requestId, _score);
        tokenIdToScore[requestIdToTokenId[_requestId]] = _score;
    }

    /**
     * Allow withdraw of Link tokens from the contract
     */
    function withdrawLink() public onlyOwner {
        LinkTokenInterface link = LinkTokenInterface(chainlinkTokenAddress());
        require(
            link.transfer(msg.sender, link.balanceOf(address(this))),
            "Unable to transfer"
        );
    }
}
