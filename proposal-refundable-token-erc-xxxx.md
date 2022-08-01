---
eip: 2000
title: Refundable Token Standard
author: John01 Any <01@example.com>, John02 Any <02@example.com>
type: Standards Track
category: ERC
status: Working
created: 2022-01-31
---

## Simple Summary

A standard interface for Refundable Token.

## Abstract

The value of security token can be number of linked currency.
For example, in STO process, issuer can be invested with real currency from buyers(or investors) and transfers issuing tokens to buyers. If offering process is successfully completed, there is no issue.
But buyers can change their plan, or offering is failed(or canceled) cause of mis-fitting the compliance rules or other rules.
There is no way guarantee to payback(refund) to buyer with real currency in on-chain network.

We have suggest this process make possible in on-chain network with payable currency like token(ex: USDT)


## Motivation

A standard interface allows payable token contract to interact with ERC-2000 interface within smart contracts.

Any payable token contract call ERC-2000 interface to exchange with issuing token based on constraint built in ERC-2000 smart contract to validate transactions.

Note: Refund is only available in certain conditions(ex: period) based on implementations.

## Requirements

Exchanging tokens with security, requires having a escrow like standard way in on-chain network.

The following stand interfaces should be provided on ERC-2000 interface.
  - MUST support querying texted based compliance for transactions. ex: period, max number of buyers, minimum and maximum tokens to hold, refund period, etc.
  - exchange(or purchase) with success or failed return code.
  - refund(or cancel transaction) with success or failed return code.


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


    /// @notice create escrow account.
    /// @dev
    ///   - created escrow account of [msg.sender].
    ///   - if escrow id is 0, this means in payable contract. payable contract will generate unique ID.
    ///   - in case of issuing contract, [msg.sender] should have enough balance of total supply. and this supply is locked until escrow account is closed.
    /// @param
    ///   - _escrowId: escrow id
    ///   - _period: escrow period in seconds
    ///   - _totalSupply: number of tokens to be exchange
    ///   - _exchangeRate: exchange rate of 1-payable token vs N-issuing token
    /// @return escrow ID.
    /// @Note: other constraint can be implemented on implementation.
    function escrowAccountCreate(uint256 _period, uint256 _totalSupply, uint256 _exchangeRate) external payable returns (uint256);


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
    ///   - _hash: if code is 0, this hash should be match with escrow balance
    /// @return reason code. 0 is success, otherwise is failure code.
    function escrowFinish(uint256 _escrowId, bytes4 _code, uint256 _hash) external payable returns (bytes4);

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
The standard proposes interfaces on top of the ERC-20 standard.
Each functions should include constraint check logic.
In case of payable token, should invoke ERC165 interface before their own logic.
In case of issuer token, should implemented internal constraint logic such as period, maximum investors, etc.

Let's discuss following functions.

1. **`escrowAccountCreate`**

The issuing token holder can call this function. The parameters are very basic(period, total supply and exchange rate).
Other constrains can be implemented on function body. Function body should implements following.

- add constraint rules on this escrow account. basic rule(ex: period) must be implemented.
- create temporary balance sheet for escrow process.
- credit own token supply on escrow account. Owner could not use this fund until escrow process is finished.(In other words, LOCKED).


When this process is success, can call specific function on payable token contract. This function create similar as above but apply contract address.
Payable contract does not have constraints rules(because it is general valuable token), but every transactions should call issuing token function to validate constraints.

2. **`escrowPurchase & escrowRefund`**

The buyer calls this function in payable token only. Smart contract code calls issuer contract via ERC165 interface, and return code is 0(Success), can continue process(ex: update escrow balance).
When fund is deposit on escrow balance sheet, this token is locked.
For example, the buyer has 100 payable tokens and purchased 1000 issuing token by 10 payable token(in case of exchange rate is 100).
In buyers wallet balance should shows 90 token. If escrow failed, escrow process should return 10 token to buyer.
If escrow process is successfully done, the buyer should have 1000 token balance on issuer contract, but fixed 90 tokens in payable token.

3. **`escrowFinish`**

Only escrow creator should call this function.


## Security concern

- The buyer should be available refund anytime until escrow finished. Because if issuer does not call `escrowFinish` forever, there is no way to get it back. Developer should be careful this logic.
- Should deal with invalid call of functions. some functions can be invoked by user directly or should be called by payable contract code via ERC165 interface. So make sure [msg.sender] is user or contract.

## Backwards Compatibility

By design ERC-2001 is fully backwards compatible with ERC-20.


## Test Cases & Implementations

(TBD)

## References

(TBD)

## Copyright

(TBD)Copyright and related rights waived via [CC0](../LICENSE.md).
