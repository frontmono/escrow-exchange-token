---
eip: 2000
title: Escrow Issuing Token Standard
author: John01 Any <01@example.com>, John02 Any <02@example.com>
type: Standards Track
category: ERC
status: Working
created: 2022-01-31
---

## Simple Summary

A standard interface for Refundable Security Token.

## Abstract

The value of security token can be number of linked currency.
For example, in STO process, issuer can be invested with real currency from buyers(or investors) and transfers issuing tokens to buyers. If offering process is successfully completed, there is no issue.
But buyers can change their plan, or offering is failed(or canceled) cause of mis-fitting the compliance rules or other rules.
There is no way guarantee to payback(refund) to buyer with real currency in on-chain network.

We have suggest this process make possible in on-chain network with payable currency like token(ex: USDT)


## Motivation

A standard interface allows payable token contract to interface with ERC-2000 interface within smart contracts.

Any payable token contract call ERC-2000 interface to exchange with issuing token based on rules built in ERC-2000 smart contract to validate transactions.

Note: Refund is only available in certain conditions(ex: period) based on implementations.

## Requirements

Exchanging tokens with security, requires having a escrow like standard way in on-chain network.

The following stand interfaces should be provided on ERC-2000 interface.
  - MUST support querying texted based compliance for transactions. ex: period, max number of buyers, minimum and maximum tokens to hold, refund period, etc.
  - exchange(or purchase) with success or failed return code.
  - refund(or cancel transaction) with success or failed return code.
  - TBD


## Specification

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD", "SHOULD NOT", "RECOMMENDED", "MAY", and "OPTIONAL" in this document are to be interpreted as described in RFC 2119.

**Every ERC-2001 compliant contract must implement the `ERC2001` and `ERC165` interfaces** (subject to "caveats" below):

```solidity
pragma solidity ^0.4.20;

/// @title ERC-2001 Refundable Token Standard
///  Note: the ERC-165 identifier for this interface is 0x keccak256 - TODO.
///  We will use balance in comment as following
interface ERC2001 /* is ERC165 */ {

    /// @dev This emits when buyer purchase token with owned payable token.
    ///   _from: buyer address
    ///   _escrowId: specify offering event. can be zero in STO process, but in payable token, can be used to distinguish for escrow id
    ///   _valuePayed: payable token amount
    ///   _valueObtain: earned of current token by this event.
    event EscrowPurchase(address _from, uint256 _escrowId, uint256 _valuePayed, uint256 _valueObtain);

    /// @dev This emits when buyer refund token.
    event EscrowRefund(address _from, uint256 _escrowId, uint256 _valuePayed, uint256 _valueObtain);

    /// @dev This emits when escrow is finished.
    ///   _code: if 0(zero), it means success, but otherwise, shows reason.
    ///   _description: shows description of finish reason(success or other failure reasons)
    event EscrowFinished(uint256 _escrowId, bytes4 _code, string _description);

    /// @notice escrow balance of owner
    /// @dev assigned to the zero address are considered invalid, and this
    ///   function throws for queries about the zero address.
    ///   if escrowId does not exist, must throw error.
    /// @param
    ///   - _owner: An address for whom to query the balance
    ///   - _escrowId: escrow account id
    /// @return amount of current escrow account balance. First is payed, and seconds is hold tokens
    function escrowBalanceOf(address _owner, uint256 _escrowId) external view returns (uint256, uint256);

    /// simple query to return simple description of compilance.
    function escrowComplainaceDescription() external view returns (string _description);


    /// simple query to return string based on error code. if code is zero,return can be 'success'
    function escrowErrorCodeDescription(bytes4 _code) external view returns (string _description);

    /// @notice exchange tokens from owner of _escrowId and from address.
    /// @dev
    ///   - if escrowId is not valid, should throw error.
    ///   - token can be calculated from _valuePayed x exchange_rate
    ///   - decrease escrow owners balance, and increase [msg.sender]'s balance
    ///   - Should check conditions to perform. ex: if period is done, will return failure  
    /// @param
    ///   - _escrowId: escrow id
    ///   - _valuePayed: payable token amount
    /// @return reason code. 0 is success, otherwise is failure code.
    function escrowPurchase(uint256 _escrowId, uint256 _valuePayed) external payable returns (bytes4);


    /// @notice [msg.sender] request refund from previous purchase.
    /// @dev
    ///   - if escrowId is not valid, should throw error.
    ///   - token can be calculated from _valuePayed x exchange_rate
    ///   - increase escrow owners balance, and decrease [msg.sender]'s balance
    ///   - Should check conditions to perform. ex: if period is done, will return failure  
    ///   - if all success, should emit `EscrowPurchase` event
    /// @param
    ///   - _escrowId: escrow id
    ///   - _valuePayed: payable token amount
    /// @return reason code. 0 is success, otherwise is failure code.
    function escrowRefund(uint256 _escrowId, uint256 _valuePayed) external payable returns (bytes4);

    /// @notice request escrow finish
    /// @dev
    ///   - if escrowId is not valid, should throw error.
    ///   - [msg.sender] must be escrow owner
    ///   - to be success, should be meet constraint(ex: period)
    ///   - when it is done(success or failed), all escrow balances should be cleaned and emit EscrowFinished    ///   
    /// @param
    ///   - _escrowId: escrow id
    ///   - _code: 0  is success, otherwise, issuer cancel(or close) this escrow account
    /// @return reason code. 0 is success, otherwise is failure code.
    function escrowFinish(uint256 _escrowId, bytes4 _code) external payable returns (bytes4);

}

interface ERC165 {
    /// @notice Query if a contract implements an interface
    /// @param interfaceID The interface identifier, as specified in ERC-165
    /// @dev Interface identification is specified in ERC-165. This function
    ///  uses less than 30,000 gas.
    /// @return `true` if the contract implements `interfaceID` and
    ///  `interfaceID` is not 0xffffffff, `false` otherwise
    function supportsInterface(bytes4 interfaceID) external view returns (bool);
}
```

## Rationale

There are many proposed uses of Ethereum smart contracts that depend on tracking distinguishable assets. Examples of existing or planned NFTs are LAND in Decentraland, the eponymous punks in CryptoPunks, and in-game items using systems like DMarket or EnjinCoin. Future uses include tracking real-world assets, like real-estate (as envisioned by companies like Ubitquity or Propy). It is critical in each of these cases that these items are not "lumped together" as numbers in a ledger, but instead each asset must have its ownership individually and atomically tracked. Regardless of the nature of these assets, the ecosystem will be stronger if we have a standardized interface that allows for cross-functional asset management and sales platforms.

**"NFT" Word Choice**

"NFT" was satisfactory to nearly everyone surveyed and is widely applicable to a broad universe of distinguishable digital assets. We recognize that "deed" is very descriptive for certain applications of this standard (notably, physical property).

*Alternatives considered: distinguishable asset, title, token, asset, equity, ticket*

**NFT Identifiers**

Every NFT is identified by a unique `uint256` ID inside the ERC-721 smart contract. This identifying number SHALL NOT change for the life of the contract. The pair `(contract address, uint256 tokenId)` will then be a globally unique and fully-qualified identifier for a specific asset on an Ethereum chain. While some ERC-721 smart contracts may find it convenient to start with ID 0 and simply increment by one for each new NFT, callers SHALL NOT assume that ID numbers have any specific pattern to them, and MUST treat the ID as a "black box". Also note that NFTs MAY become invalid (be destroyed). Please see the enumeration functions for a supported enumeration interface.

The choice of `uint256` allows a wide variety of applications because UUIDs and sha3 hashes are directly convertible to `uint256`.

**Transfer Mechanism**

ERC-721 standardizes a safe transfer function `safeTransferFrom` (overloaded with and without a `bytes` parameter) and an unsafe function `transferFrom`. Transfers may be initiated by:

- The owner of an NFT
- The approved address of an NFT
- An authorized operator of the current owner of an NFT

Additionally, an authorized operator may set the approved address for an NFT. This provides a powerful set of tools for wallet, broker and auction applications to quickly use a *large* number of NFTs.

The transfer and accept functions' documentation only specify conditions when the transaction MUST throw. Your implementation MAY also throw in other situations. This allows implementations to achieve interesting results:

- **Disallow transfers if the contract is paused** — prior art, CryptoKitties deployed contract, line 611
- **Blocklist certain address from receiving NFTs** — prior art, CryptoKitties deployed contract, lines 565, 566
- **Disallow unsafe transfers** — `transferFrom` throws unless `_to` equals `msg.sender` or `countOf(_to)` is non-zero or was non-zero previously (because such cases are safe)
- **Charge a fee to both parties of a transaction** — require payment when calling `approve` with a non-zero `_approved` if it was previously the zero address, refund payment if calling `approve` with the zero address if it was previously a non-zero address, require payment when calling any transfer function, require transfer parameter `_to` to equal `msg.sender`, require transfer parameter `_to` to be the approved address for the NFT
- **Read only NFT registry** — always throw from `safeTransferFrom`, `transferFrom`, `approve` and `setApprovalForAll`

Failed transactions will throw, a best practice identified in ERC-223, ERC-677, ERC-827 and OpenZeppelin's implementation of SafeERC20.sol. ERC-20 defined an `allowance` feature, this caused a problem when called and then later modified to a different amount, as on OpenZeppelin issue \#438. In ERC-721, there is no allowance because every NFT is unique, the quantity is none or one. Therefore we receive the benefits of ERC-20's original design without problems that have been later discovered.

Creation of NFTs ("minting") and destruction of NFTs ("burning") is not included in the specification. Your contract may implement these by other means. Please see the `event` documentation for your responsibilities when creating or destroying NFTs.

We questioned if the `operator` parameter on `onERC721Received` was necessary. In all cases we could imagine, if the operator was important then that operator could transfer the token to themself and then send it -- then they would be the `from` address. This seems contrived because we consider the operator to be a temporary owner of the token (and transferring to themself is redundant). When the operator sends the token, it is the operator acting on their own accord, NOT the operator acting on behalf of the token holder. This is why the operator and the previous token owner are both significant to the token recipient.

*Alternatives considered: only allow two-step ERC-20 style transaction, require that transfer functions never throw, require all functions to return a boolean indicating the success of the operation.*

**ERC-165 Interface**

We chose Standard Interface Detection (ERC-165) to expose the interfaces that a ERC-721 smart contract supports.

A future EIP may create a global registry of interfaces for contracts. We strongly support such an EIP and it would allow your ERC-721 implementation to implement `ERC721Enumerable`, `ERC721Metadata`, or other interfaces by delegating to a separate contract.

**Gas and Complexity** (regarding the enumeration extension)

This specification contemplates implementations that manage a few and *arbitrarily large* numbers of NFTs. If your application is able to grow then avoid using for/while loops in your code (see CryptoKitties bounty issue \#4). These indicate your contract may be unable to scale and gas costs will rise over time without bound.

We have deployed a contract, XXXXERC721, to Testnet which instantiates and tracks 340282366920938463463374607431768211456 different deeds (2^128). That's enough to assign every IPV6 address to an Ethereum account owner, or to track ownership of nanobots a few micron in size and in aggregate totalling half the size of Earth. You can query it from the blockchain. And every function takes less gas than querying the ENS.

This illustration makes clear: the ERC-721 standard scales.

*Alternatives considered: remove the asset enumeration function if it requires a for-loop, return a Solidity array type from enumeration functions.*

**Privacy**

Wallets/brokers/auctioneers identified in the motivation section have a strong need to identify which NFTs an owner owns.

It may be interesting to consider a use case where NFTs are not enumerable, such as a private registry of property ownership, or a partially-private registry. However, privacy cannot be attained because an attacker can simply (!) call `ownerOf` for every possible `tokenId`.

**Metadata Choices** (metadata extension)

We have required `name` and `symbol` functions in the metadata extension. Every token EIP and draft we reviewed (ERC-20, ERC-223, ERC-677, ERC-777, ERC-827) included these functions.

We remind implementation authors that the empty string is a valid response to `name` and `symbol` if you protest to the usage of this mechanism. We also remind everyone that any smart contract can use the same name and symbol as *your* contract. How a client may determine which ERC-721 smart contracts are well-known (canonical) is outside the scope of this standard.

A mechanism is provided to associate NFTs with URIs. We expect that many implementations will take advantage of this to provide metadata for each NFT. The image size recommendation is taken from Instagram, they probably know much about image usability. The URI MAY be mutable (i.e. it changes from time to time). We considered an NFT representing ownership of a house, in this case metadata about the house (image, occupants, etc.) can naturally change.

Metadata is returned as a string value. Currently this is only usable as calling from `web3`, not from other contracts. This is acceptable because we have not considered a use case where an on-blockchain application would query such information.

*Alternatives considered: put all metadata for each asset on the blockchain (too expensive), use URL templates to query metadata parts (URL templates do not work with all URL schemes, especially P2P URLs), multiaddr network address (not mature enough)*

**Community Consensus**

A significant amount of discussion occurred on the original ERC-721 issue, additionally we held a first live meeting on Gitter that had good representation and well advertised (on Reddit, in the Gitter #ERC channel, and the original ERC-721 issue). Thank you to the participants:

- [@ImAllInNow](https://github.com/imallinnow) Rob from DEC Gaming / Presenting Michigan Ethereum Meetup Feb 7
- [@Arachnid](https://github.com/arachnid) Nick Johnson
- [@jadhavajay](https://github.com/jadhavajay) Ajay Jadhav from AyanWorks
- [@superphly](https://github.com/superphly) Cody Marx Bailey - XRAM Capital / Sharing at hackathon Jan 20 / UN Future of Finance Hackathon.
- [@fulldecent](https://github.com/fulldecent) William Entriken

A second event was held at ETHDenver 2018 to discuss distinguishable asset standards (notes to be published).

We have been very inclusive in this process and invite anyone with questions or contributions into our discussion. However, this standard is written only to support the identified use cases which are listed herein.

## Backwards Compatibility

We have adopted `balanceOf`, `totalSupply`, `name` and `symbol` semantics from the ERC-20 specification. An implementation may also include a function `decimals` that returns `uint8(0)` if its goal is to be more compatible with ERC-20 while supporting this standard. However, we find it contrived to require all ERC-721 implementations to support the `decimals` function.

Example NFT implementations as of February 2018:

- CryptoKitties -- Compatible with an earlier version of this standard.
- CryptoPunks -- Partially ERC-20 compatible, but not easily generalizable because it includes auction functionality directly in the contract and uses function names that explicitly refer to the assets as "punks".
- Auctionhouse Asset Interface -- The author needed a generic interface for the Auctionhouse ÐApp (currently ice-boxed). His "Asset" contract is very simple, but is missing ERC-20 compatibility, `approve()` functionality, and metadata. This effort is referenced in the discussion for EIP-173.

Note: "Limited edition, collectible tokens" like Curio Cards and Rare Pepe are *not* distinguishable assets. They're actually a collection of individual fungible tokens, each of which is tracked by its own smart contract with its own total supply (which may be `1` in extreme cases).

The `onERC721Received` function specifically works around old deployed contracts which may inadvertently return 1 (`true`) in certain circumstances even if they don't implement a function (see Solidity DelegateCallReturnValue bug). By returning and checking for a magic value, we are able to distinguish actual affirmative responses versus these vacuous `true`s.

## Test Cases

0xcert ERC-721 Token includes test cases written using Truffle.

## Implementations

0xcert ERC721 -- a reference implementation

- MIT licensed, so you can freely use it for your projects
- Includes test cases
- Active bug bounty, you will be paid if you find errors

Su Squares -- an advertising platform where you can rent space and place images

- Complete the Su Squares Bug Bounty Program to seek problems with this standard or its implementation
- Implements the complete standard and all optional interfaces

ERC721ExampleDeed -- an example implementation

- Implements using the OpenZeppelin project format

XXXXERC721, by William Entriken -- a scalable example implementation

- Deployed on testnet with 1 billion assets and supporting all lookups with the metadata extension. This demonstrates that scaling is NOT a problem.

## References

**Standards**

1. [ERC-20](./eip-20.md) Token Standard.
1. [ERC-165](./eip-165.md) Standard Interface Detection.
1. [ERC-173](./eip-173.md) Owned Standard.
1. [ERC-223](https://github.com/ethereum/EIPs/issues/223) Token Standard.
1. [ERC-677](https://github.com/ethereum/EIPs/issues/677) `transferAndCall` Token Standard.
1. [ERC-827](https://github.com/ethereum/EIPs/issues/827) Token Standard.
1. Ethereum Name Service (ENS). https://ens.domains
1. Instagram -- What's the Image Resolution? https://help.instagram.com/1631821640426723
1. JSON Schema. https://json-schema.org/
1. Multiaddr. https://github.com/multiformats/multiaddr
1. RFC 2119 Key words for use in RFCs to Indicate Requirement Levels. https://www.ietf.org/rfc/rfc2119.txt

**Issues**

1. The Original ERC-721 Issue. https://github.com/ethereum/eips/issues/721
1. Solidity Issue \#2330 -- Interface Functions are External. https://github.com/ethereum/solidity/issues/2330
1. Solidity Issue \#3412 -- Implement Interface: Allow Stricter Mutability. https://github.com/ethereum/solidity/issues/3412
1. Solidity Issue \#3419 -- Interfaces Can't Inherit. https://github.com/ethereum/solidity/issues/3419
1. Solidity Issue \#3494 -- Compiler Incorrectly Reasons About the `selector` Function. https://github.com/ethereum/solidity/issues/3494
1. Solidity Issue \#3544 -- Cannot Calculate Selector of Function Named `transfer`. https://github.com/ethereum/solidity/issues/3544
1. CryptoKitties Bounty Issue \#4 -- Listing all Kitties Owned by a User is `O(n^2)`. https://github.com/axiomzen/cryptokitties-bounty/issues/4
1. OpenZeppelin Issue \#438 -- Implementation of `approve` method violates ERC20 standard. https://github.com/OpenZeppelin/zeppelin-solidity/issues/438
1. Solidity DelegateCallReturnValue Bug. https://solidity.readthedocs.io/en/develop/bugs.html#DelegateCallReturnValue

**Discussions**

1. Reddit (announcement of first live discussion). https://www.reddit.com/r/ethereum/comments/7r2ena/friday_119_live_discussion_on_erc_nonfungible/
1. Gitter #EIPs (announcement of first live discussion). https://gitter.im/ethereum/EIPs?at=5a5f823fb48e8c3566f0a5e7
1. ERC-721 (announcement of first live discussion). https://github.com/ethereum/eips/issues/721#issuecomment-358369377
1. ETHDenver 2018. https://ethdenver.com

**NFT Implementations and Other Projects**

1. CryptoKitties. https://www.cryptokitties.co
1. 0xcert ERC-721 Token. https://github.com/0xcert/ethereum-erc721
1. Su Squares. https://tenthousandsu.com
1. Decentraland. https://decentraland.org
1. CryptoPunks. https://www.larvalabs.com/cryptopunks
1. DMarket. https://www.dmarket.io
1. Enjin Coin. https://enjincoin.io
1. Ubitquity. https://www.ubitquity.io
1. Propy. https://tokensale.propy.com
1. CryptoKitties Deployed Contract. https://etherscan.io/address/0x06012c8cf97bead5deae237070f9587f8e7a266d#code
1. Su Squares Bug Bounty Program. https://github.com/fulldecent/su-squares-bounty
1. XXXXERC721. https://github.com/fulldecent/erc721-example
1. ERC721ExampleDeed. https://github.com/nastassiasachs/ERC721ExampleDeed
1. Curio Cards. https://mycuriocards.com
1. Rare Pepe. https://rarepepewallet.com
1. Auctionhouse Asset Interface. https://github.com/dob/auctionhouse/blob/master/contracts/Asset.sol
1. OpenZeppelin SafeERC20.sol Implementation. https://github.com/OpenZeppelin/zeppelin-solidity/blob/master/contracts/token/ERC20/SafeERC20.sol

## Copyright

Copyright and related rights waived via [CC0](../LICENSE.md).
