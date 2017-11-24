# LiveEdu Crowdsale Contract Audit

Status: Work in progress

## Summary

[LiveEdu](https://www.liveedu.tv/) intends to run a [crowdsale](https://tokensale.liveedu.tv/) commencing in Jan 2018.

Bok Consulting Pty Ltd was commissioned to perform an audit on the LiveEdu's crowdsale and token Ethereum smart contract.

**NOTE: The addresses below are NOT live. Do NOT send funds to the addresses**

This audit has been conducted on LiveEdu's deployed contracts on the Ethereum Mainnet:

* Sale [0x2097175d0abb8258f2468E3487F8db776E29D076](https://etherscan.io/address/0x2097175d0abb8258f2468E3487F8db776E29D076#code) with source code
  copied to [contracts/Sale.sol](contracts/Sale.sol), and deployed with Solidity v0.4.14+commit.c2215d46 and optimisation switched on
* Token [0x5b26C5D0772E5bbaC8b3182AE9a13f9BB2D03765](https://etherscan.io/address/0x5b26C5D0772E5bbaC8b3182AE9a13f9BB2D03765#code) with source code
  copied to [contracts/Token.sol](contracts/Token.sol), and deployed with Solidity v0.4.14+commit.c2215d46 and optimisation switched on
* Controller [0xcbD1dC6D55F20C9b4639752544d7EEcF261aBBED](https://etherscan.io/address/0xcbD1dC6D55F20C9b4639752544d7EEcF261aBBED#code) with source code
  copied to [contracts/Controller.sol](contracts/Controller.sol), and deployed with Solidity v0.4.14+commit.c2215d46 and optimisation switched on 
* Ledger [0x3847922645c99eD954f597a1DB0BA258240014Ce](https://etherscan.io/address/0x3847922645c99eD954f597a1DB0BA258240014Ce#code) with source code
  copied to [contracts/Ledger.sol](contracts/Ledger.sol), and deployed with Solidity  v0.4.14+commit.c2215d46 and optimisation switched on

The source code for [Token](contracts/Token.sol), [Controller](contracts/Controller.sol) and [Ledger](contracts/Ledger.sol) deployed on Mainnet are
exactly the same as each other.

TODO: Confirm that no potential vulnerabilities have been identified in the crowdsale and token contract.

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

Note that the crowdsale contract owner has the ability to change the start date, end date and cap by executing the `Sale.init(...)` function. This
function should only be executed once to define the crowdsale parameters, but can be called multiple times, at any time.

There is also some logic in the *Sale* contract that allows one last contribution to be made after the crowdsale end date, or above the cap, to mark
the crowdsale as being closed. This last contribution is not checked against the cap, and can vastly exceed the cap.

During the crowdsale, the end date can be brought forward by the owner executing the `softCap(...)` function.

<br />

### Token Contract

Note that:
* The token contract owner has the ability to `pause()` and `unpause()` the transfer of tokens
* The token contract owner has the ability to switch the underlying *Controller* and/or *Ledger* contracts that can change the behaviour
  and/or token balances of any/all accounts

<br />

<hr />

## Table Of Contents

* [Summary](#summary)
* [Recommendations](#recommendations)
* [Potential Vulnerabilities](#potential-vulnerabilities)
* [Scope](#scope)
* [Limitations](#limitations)
* [Due Diligence](#due-diligence)
* [Risks](#risks)
* [Testing](#testing)
  * [Test 1 Sale Contract](#test-1-sale-contract)
  * [Test 2 Token Contract](#test-2-token-contract)
* [Code Review](#code-review)

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
* **LOW IMPORTANCE** `Ledger.approve(...)` - the recently finalised [ERC20 token standard](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md)
  recommends against the smart contract enforcing a change in a non-0 approval limit by first setting the approval limit to 0 before being
  able to set the approval limit to a new non-0 amount
* **LOW IMPORTANCE** `Sale.init(...)` can be called as many times and at any time to change the start date, end date and cap for the crowdsale. Consider
  adding the statement `require(start == 0);` at the start of this function to restrict `init(...)` to only being called once
* **LOW IMPORTANCE** The *Sale* fallback `()` function implements the time limitation (end date) and the cap in some convoluted logic that permits one
  last single contribution AFTER the end date that is not restricted by the specified cap in any way. Consider simplifying the the logic to restrict
  contributions to the crowdsale period and the specified cap

<br />

<hr />

## Potential Vulnerabilities

TODO - Confirm that no potential vulnerabilities have been identified in the crowdsale and token contract.

<br />

<hr />

## Scope

This audit is into the technical aspects of the crowdsale contracts. The primary aim of this audit is to ensure that funds
contributed to these contracts are not easily attacked or stolen by third parties. The secondary aim of this audit is that
ensure the coded algorithms work as expected. This audit does not guarantee that that the code is bugfree, but intends to
highlight any areas of weaknesses.

<br />

<hr />

## Limitations

This audit makes no statements or warranties about the viability of the LiveEdu's business proposition, the individuals
involved in this business or the regulatory regime for the business model.

<br />

<hr />

## Due Diligence

As always, potential participants in any crowdsale are encouraged to perform their due diligence on the business proposition
before funding any crowdsales.

Potential participants are also encouraged to only send their funds to the official crowdsale Ethereum address, published on
the crowdsale beneficiary's official communication channel.

Scammers have been publishing phishing address in the forums, twitter and other communication channels, and some go as far as
duplicating crowdsale websites. Potential participants should NOT just click on any links received through these messages.
Scammers have also hacked the crowdsale website to replace the crowdsale contract address with their scam address.
 
Potential participants should also confirm that the verified source code on EtherScan.io for the published crowdsale address
matches the audited source code, and that the deployment parameters are correctly set, including the constant parameters.

<br />

<hr />

## Risks

* Logic in the *Sale* contract has been kept simple and there are only a few functions that can be executed by the owner to
  withdraw any contributed ETH and/or tokens - `withdraw()`, `withdrawSome(...)`, `withdrawToken(...)` and `refundToken(...)`.
  Contributed ETH accumulates in the crowdsale contract until the owner withdraws the funds using the functions listed above.
  The risks of funds getting hacked or stolen from the crowdsale contract can be reduced by immediately transferring all
  contributed funds into a better tested multisig or hardware wallet, instead of letting the funds accumulate in the
  bespoke crowdsale contract.

<br />

<hr />

## Testing

### Test 1 Sale Contract

The following functions were tested using the script [test/01_test1.sh](test/01_test1.sh) with the summary results saved
in [test/test1results.txt](test/test1results.txt) and the detailed output saved in [test/test1output.txt](test/test1output.txt):

* [x] Deploy *Sale* contract
* [x] Initialise *Sale* contract
* [x] Send contributions to *Sale* contract
* [x] Withdraw contributed funds from sale contract

<br />

### Test 2 Token Contract

* [ ] Deploy *Token*, *Controller* and *Ledger* contracts
* [ ] Mint tokens
* [ ] `transfer(...)` and `transferFrom(...)` tokens

<br />

<hr />

## Code Review

* [x] [code-review/Sale.md](code-review/Sale.md)
  * [x] contract Token
  * [x] contract Sale
* [x] [code-review/Token.md](code-review/Token.md)
  * [x] contract SafeMath
  * [x] contract Owned
  * [x] contract Pausable is Owned
  * [x] contract Finalizable is Owned
  * [x] contract IToken
  * [x] contract TokenReceivable is Owned
  * [x] contract EventDefinitions
  * [x] contract Token is Finalizable, TokenReceivable, SafeMath, EventDefinitions, Pausable
  * [x] contract Controller is Owned, Finalizable
  * [x] contract Ledger is Owned, SafeMath, Finalizable

<br />

<br />

(c) BokkyPooBah / Bok Consulting Pty Ltd for LiveEdu - Nov 24 2017. The MIT Licence.