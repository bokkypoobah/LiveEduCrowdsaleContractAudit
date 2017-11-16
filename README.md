# LiveEdu Crowdsale Contract Audit

Status: To be commenced

## Summary

[LiveEdu](https://www.liveedu.tv/)

**NOTE: The addresses below are NOT live. Do NOT send funds to the addresses**

Deployed contracts on Mainnet:

* Sale [0x2097175d0abb8258f2468E3487F8db776E29D076](https://etherscan.io/address/0x2097175d0abb8258f2468E3487F8db776E29D076#code) with source code
  copied to [contracts/Sale.sol](contracts/Sale.sol), and deployed with Solidity v0.4.14+commit.c2215d46 and optimisation switched on
* Token [0x5b26C5D0772E5bbaC8b3182AE9a13f9BB2D03765](https://etherscan.io/address/0x5b26C5D0772E5bbaC8b3182AE9a13f9BB2D03765#code) with source code
  copied to [contracts/Token.sol](contracts/Token.sol), and deployed with Solidity v0.4.14+commit.c2215d46 and optimisation switched on
* Controller [0xcbD1dC6D55F20C9b4639752544d7EEcF261aBBED](https://etherscan.io/address/0xcbD1dC6D55F20C9b4639752544d7EEcF261aBBED#code) with source code
  copied to [contracts/Controller.sol](contracts/Controller.sol), and deployed with Solidity v0.4.14+commit.c2215d46 and optimisation switched on 
* Ledger [0x3847922645c99eD954f597a1DB0BA258240014Ce](https://etherscan.io/address/0x3847922645c99eD954f597a1DB0BA258240014Ce#code) with source code
  copied to [contracts/Ledger.sol](contracts/Ledger.sol), and deployed with Solidity  v0.4.14+commit.c2215d46 and optimisation switched on

The source code for Token, Controller and Ledger deployed on Mainnet are exactly the same as each other.

<br />

### Mainnet Contract Details

`TBA`

<br />

### Crowdsale Contract

The *Sale* crowdsale contract accepts ethers (ETH) sent by participants to the contract address, where the fallback function is executed. The ETH
accumulates in the crowdsale contract, and the crowdsale administrator will have to manually withdraw the ETH by executing the `withdraw()` or
`withdrawSome(...)` functions.

The `EtherIn(...)` events logged with each ETH contribution will be collected using an off-chain process and this data will be used to generate
the appropriate amount of tokens for each participant's contributing ETH account. 

<br />

### Token Contract

Note that:
* The token contract owner has the ability to `pause()` and `unpause()` the transfer of tokens
* The token contract owner has the ability to switch the underlying *Controller* and/or *Ledger* contracts that can change the behaviour
  and/or token balances of any/all accounts

<br />

<hr />

## Table Of Contents

<br />

<hr />

## Recommendations

* **LOW IMPORTANCE** In *Token*, consider making `Owned.newOwner` public
* **LOW IMPORTANCE** In *Token*, consider adding the `notFinalized()` modifier to `Finalizable.finalize()` so this function cannot
  be executed more than once
* **LOW IMPORTANCE** In *Sale*, while there are not many ways to extract ETH from the *Sale* contract, security can be further improved
  by immediately transferring any contributed ETH to the crowdsale wallet that should be more widely tested and used than this
  bespoke smart contract
* **LOW IMPORTANCE** In *Token*, `transfer(...)`, `transferFrom(...)`, `approve(...)`, `increaseApproval(...)` and `decreaseApproval(...)` have
  the `onlyPayloadSize(...)` modifier to mitigate against the "Short Address Attack". This mitigation method is no longer recommended - see
  [Smart Contract Short Address Attack Mitigation Failure](https://blog.coinfabrik.com/smart-contract-short-address-attack-mitigation-failure/)
* **LOW IMPORTANCE** The recently finalised [ERC20 token standard](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md)
  recommends the following behaviour that the *Token* contract does not implement:
  * `transfer(...)` and `transferFrom(...)` throws an error if there are insufficient tokens to transfer
  * `transferFrom(...)` throws an error if there are insufficient approved tokens to transfer
  * 0 value transfers are valid transfers

<br />

<hr />

## Testing

<br />

<hr />

## Code Review

* [x] [code-review/Sale.md](code-review/Sale.md)
  * [x] contract Token
  * [x] contract Sale
* [ ] [code-review/Token.md](code-review/Token.md)
  * [x] contract SafeMath
  * [x] contract Owned
  * [x] contract Pausable is Owned
  * [x] contract Finalizable is Owned
  * [x] contract IToken
  * [x] contract TokenReceivable is Owned
  * [x] contract EventDefinitions
  * [ ] contract Token is Finalizable, TokenReceivable, SafeMath, EventDefinitions, Pausable
  * [ ] contract Controller is Owned, Finalizable
  * [ ] contract Ledger is Owned, SafeMath, Finalizable
