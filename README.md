# LiveEdu Crowdsale Contract Audit

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

No potential vulnerabilities have been identified in the crowdsale and token contract.

There are some recommendations listed below, but none of these are critical.

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

Together, the *Token*, *Controller* and *Ledger* contracts provide the general functionality required of an
[ERC20 Token Standard](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md) token contract. There are some slight difference
in behaviour compared to this recently (Sep 11 2017) finalised standard and these differences are listed below:

* `Token.transfer(...)` returns false if there are insufficient tokens to transfer. In the recently finalised ERC20 token standard:

  > The function **SHOULD throw** if the _from account balance does not have enough tokens to spend.

  `Token.transfer(...)` returns false as required under the previous un-finalised version of the ERC20 token standard

* `Token.transferFrom(...)` returns false if there are insufficient tokens to transfer or insufficient tokens have been approved for transfer.
  In the recently finalised ERC20 token standard:

  > The function **SHOULD throw** unless the _from account has deliberately authorized the sender of the message via some mechanism

  `Token.transferFrom(...)` returns false as required under the previous un-finalised version of the ERC20 token standard

* `Token.approve(...)` requires that a non-0 approval limit be set to 0 before being modified to another non-0 approval limit. In the recently
  finalised ERC20 token standard:

  > ... clients SHOULD make sure to create user interfaces in such a way that they set the allowance first to 0 before setting it to another value
  > for the same spender. **THOUGH The contract itself shouldn't enforce it**, to allow backwards compatilibilty with contracts deployed before

  `Token.approve(...)` implements the requirement to set a non-0 approval limit to 0 before modifying the limit to another non-0 approval limit
  that was a standard practice for ERC20 tokens before the recent ERC20 token standard was finalised 

* `Token.transfer(...)`, `Token.approve(...)` and `Token.transferFrom(...)` all implement the `onlyPayloadSize(...)` check that was recently
  relatively common in ERC20 token contracts, but has now been generally discontinued as it was found to be ineffective. See
  [Smart Contract Short Address Attack Mitigation Failure](https://blog.coinfabrik.com/smart-contract-short-address-attack-mitigation-failure/)
  for further information. The version used in the *Token* contract checks for a minimum payload size (using the `>=` operator) and should not
  cause any problems with multisig wallets as documented in the link.

None of the differences above are significant to the workings of an ERC20 token.

<br />

### Note

* Transfers in the *Token* contract can be paused and un-paused by the token contract owner, at any time

* The owner of the *Token*, *Controller* and *Ledger* contracts can use the `setToken(...)`, `setController(...)` and `setLedger(...)` functions
  to bypass the intended permissioning in this system of contracts and execute some of the functions with irregular operations. As an example,
  the owner of *Ledger* can call `setController({owner account})` and then execute `burn(...)` to burn the tokens of **any** account

<br />

<hr />

## Table Of Contents

* [Summary](#summary)
  * [Crowdsale Contract](#crowdsale-contract)
  * [Token Contract](#token-contract)
  * [Note](#note)
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
  * [Check On Calls And Permissions](#check-on-calls-and-permissions)
    * [General Functions](#general-functions)
    * [Token Specific Functions](#token-specific-functions)
    * [Controller Specific Functions](#controller-specific-functions)
    * [Ledger Specific Functions](#ledger-specific-functions)
    * [Transfer And Other Functions That Can Be Called By Any Account](#transfer-and-other-functions-that-can-be-called-by-any-account)

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

No potential vulnerabilities have been identified in the crowdsale and token contract.

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

The following functions were tested using the script [test/02_test2.sh](test/02_test2.sh) with the summary results saved
in [test/test2results.txt](test/test2results.txt) and the detailed output saved in [test/test2output.txt](test/test2output.txt):

* [x] Deploy *Token*, *Controller* and *Ledger* contracts
* [x] Stitch *Token*, *Controller* and *Ledger* contracts together
* [x] Mint tokens
* [x] Stop minting
* [x] `transfer(...)` and `transferFrom(...)` tokens
* [x] Invalid `transfer(...)` and `transferFrom(...)` tokens
* [x] 0 value `transfer(...)` and `transferFrom(...)` tokens

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

### Check On Calls And Permissions

This section looks across the permissions required to execute the non-constant functions in these set of contracts.

#### General Functions

All three main contracts *Token*, *Controller* and *Ledger* are derived from *Finalizable* which is derived from Owned. They all implement
`Finalizable.finalize()` that can only be called by the **owner**. They also implement `Owned.changeOwner(...)` that can only be called by
**owner**, and `Owned.acceptOwnership()` that can only be called by the new intended owner.

<br />

#### Token Specific Functions

* [x] *Token* additionally is derived from *TokenReceivable* that implements `TokenReceivable.claimTokens(...)` and this can only be called **owner**

* [x] `Token.setController(...)` can only be called by **owner**

* [x] `Token.controllerApprove(...)` can only be called by *Controller*. As *Controller* does not have any functions to call
  `Token.controllerApprove(...)`, this function is redundant

<br />

#### Controller Specific Functions

* [x] *Controller* has a `Controller.setToken(...)` and `Controller.setLedger(...)` that can only be called by **owner**

<br />

#### Ledger Specific Functions

* [x] `Ledger.multiMint(...)` can only be called by **owner**
  * [x] -> `Contoller.ledgerTransfer(...)` that can only be called by *Ledger*
    * [x] -> `Token.controllerTransfer(...)` that can only be called by *Controller*

* [x] *Ledger* has a `Ledger.setController(...)` and a `Ledger.stopMinting(...)` that can only be called by **owner**

<br />

#### Transfer And Other Functions That Can Be Called By Any Account

Following are the *Token* functions that can be executed by **any account**

* [x] `Token.transfer(...)`
  * [x] -> `Controller.transfer(...)` that can only be called by *Token*
    * [x] -> `Ledger.transfer(...)` that can only be called by Controller

* [x] `Token.transferFrom(...)`
  * [x] -> `Controller.transferFrom(...)` that can only be called by *Token*
    * [x] -> `Ledger.transferFrom(...)` that can only be called by Controller

* [x] `Token.approve(...)`
  * [x] -> `Controller.approve(...)` that can only be called by *Token*
    * [x] -> `Ledger.approve(...)` that can only be called by Controller

* [x] `Token.increaseApproval(...)`
  * [x] -> `Controller.increaseApproval(...)` that can only be called by *Token*
    * [x] -> `Ledger.increaseApproval(...)` that can only be called by Controller

* [x] `Token.decreaseApproval(...)`
  * [x] -> `Controller.decreaseApproval(...)` that can only be called by *Token*
    * [x] -> `Ledger.decreaseApproval(...)` that can only be called by Controller

* [x] `Token.burn(...)`
  * [x] -> `Controller.burn(...)` that can only be called by *Token*
    * [x] -> `Ledger.burn(...)` that can only be called by Controller

Each of the *Token* functions listed above can be executed by **any account**, but will only apply to the token balances the particular account
has the permission to operate on.

<br />

<br />

(c) BokkyPooBah / Bok Consulting Pty Ltd for LiveEdu - Nov 24 2017. The MIT Licence.