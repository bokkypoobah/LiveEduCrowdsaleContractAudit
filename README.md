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

<hr />

## Table Of Contents

<br />

<hr />

## Recommendations

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
  * [ ] contract SafeMath
  * [ ] contract Owned
  * [ ] contract Pausable is Owned
  * [ ] contract Finalizable is Owned
  * [ ] contract IToken
  * [ ] contract TokenReceivable is Owned
  * [ ] contract EventDefinitions
  * [ ] contract Token is Finalizable, TokenReceivable, SafeMath, EventDefinitions, Pausable
  * [ ] contract Controller is Owned, Finalizable
  * [ ] contract Ledger is Owned, SafeMath, Finalizable
