# Token

Source file [../contracts/Token.sol](../contracts/Token.sol).

<br />

<hr />

```javascript
// Unattributed material copyright New Alchemy Limited, 2017. All rights reserved.
// BK Ok - Was deployed with Solidity v0.4.14+commit.c2215d46 and optimisation switched on
pragma solidity >=0.4.10;

// BK Ok
contract SafeMath {
    // BK Ok - This function is not used
    function safeMul(uint a, uint b) internal returns (uint) {
        // BK Ok
        uint c = a * b;
        // BK Ok
        require(a == 0 || c / a == b);
        // BK Ok
        return c;
    }

    // BK Ok
    function safeSub(uint a, uint b) internal returns (uint) {
        // BK Ok
        require(b <= a);
        // BK Ok
        return a - b;
    }

    // BK Ok
    function safeAdd(uint a, uint b) internal returns (uint) {
        // BK Ok
        uint c = a + b;
        // BK Ok
        require(c>=a && c>=b);
        // BK Ok
        return c;
    }
}

// BK Ok
contract Owned {
    // BK Ok
    address public owner;
    // BK NOTE - Following should be public
    address newOwner;

    // BK Ok - Constructor
    function Owned() {
        // BK Ok
        owner = msg.sender;
    }

    // BK Ok
    modifier onlyOwner() {
        // BK Ok
        require(msg.sender == owner);
        // BK Ok
        _;
    }

    // BK Ok - Only owner can execute this
    function changeOwner(address _newOwner) onlyOwner {
        // BK Ok
        newOwner = _newOwner;
    }

    // BK Ok - Only newOwner can execute this
    function acceptOwnership() {
        // BK Ok
        if (msg.sender == newOwner) {
            // BK Ok
            owner = newOwner;
        }
    }
}

// BK Ok
contract Pausable is Owned {
    // BK Ok
    bool public paused;

    // BK Ok - Only owner can execute
    function pause() onlyOwner {
        // BK Ok
        paused = true;
    }

    // BK Ok - Only owner can execute
    function unpause() onlyOwner {
        // BK Ok
        paused = false;
    }

    // BK Ok
    modifier notPaused() {
        // BK Ok
        require(!paused);
        // BK Ok
        _;
    }
}

// BK Ok
contract Finalizable is Owned {
    // BK Ok
    bool public finalized;

    // BK NOTE - Could add the `notFinalized()` modifier, so this function cannot be executed twice
    // BK Ok - Only owner can execute
    function finalize() onlyOwner {
        // BK Ok
        finalized = true;
    }

    // BK Ok
    modifier notFinalized() {
        // BK Ok
        require(!finalized);
        // BK Ok
        _;
    }
}

// BK Ok
contract IToken {
    // BK Ok
    function transfer(address _to, uint _value) returns (bool);
    // BK Ok
    function balanceOf(address owner) returns(uint);
}

// BK Ok
contract TokenReceivable is Owned {
    // BK Ok - Only owner can execute
    function claimTokens(address _token, address _to) onlyOwner returns (bool) {
        // BK Ok
        IToken token = IToken(_token);
        // BK Ok
        return token.transfer(_to, token.balanceOf(this));
    }
}

// BK Ok
contract EventDefinitions {
    // BK Ok - Event
    event Transfer(address indexed from, address indexed to, uint value);
    // BK Ok - Event
    event Approval(address indexed owner, address indexed spender, uint value);
}

contract Token is Finalizable, TokenReceivable, SafeMath, EventDefinitions, Pausable {
    // BK Ok
    string constant public name = "Education";
    // BK Ok
    uint8 constant public decimals = 8;
    // BK Ok
    string constant public symbol = "EDU";
    // BK Ok
    Controller public controller;
    // BK Ok
    string public motd;
    // BK Ok - Event
    event Motd(string message);

    // functions below this line are onlyOwner

    // BK Ok - Only owner can execute
    function setMotd(string _m) onlyOwner {
        // BK Ok
        motd = _m;
        // BK Ok - Log event
        Motd(_m);
    }

    // BK Ok - Only owner can execute before the crowdsale is finalised
    function setController(address _c) onlyOwner notFinalized {
        // BK Ok
        controller = Controller(_c);
    }

    // functions below this line are public

    // BK Ok - Constant function
    function balanceOf(address a) constant returns (uint) {
        // BK Ok
        return controller.balanceOf(a);
    }

    // BK Ok - Constant function
    function totalSupply() constant returns (uint) {
        // BK Ok
        return controller.totalSupply();
    }

    // BK Ok - Constant function
    function allowance(address _owner, address _spender) constant returns (uint) {
        // BK Ok
        return controller.allowance(_owner, _spender);
    }

    // BK NOTE - `onlyPayloadSize(...)` short address attack mitigation is no longer recommended
    // BK NOTE - An error should be thrown if there are insufficient tokens to transfer
    // BK NOTE - A 0 value transfer should be a valid transfer
    // BK Ok
    function transfer(address _to, uint _value) onlyPayloadSize(2) notPaused returns (bool success) {
        // BK Ok
        if (controller.transfer(msg.sender, _to, _value)) {
            // BK Ok - Log event
            Transfer(msg.sender, _to, _value);
            // BK Ok
            return true;
        }
        // BK Ok
        return false;
    }

    // BK NOTE - `onlyPayloadSize(...)` short address attack mitigation is no longer recommended
    // BK NOTE - An error should be thrown if there are insufficient tokens to transfer
    // BK NOTE - An error should be thrown if there are insufficient approved tokens to transfer
    // BK NOTE - A 0 value transfer should be a valid transfer
    // BK Ok
    function transferFrom(address _from, address _to, uint _value) onlyPayloadSize(3) notPaused returns (bool success) {
        // BK Ok
        if (controller.transferFrom(msg.sender, _from, _to, _value)) {
            // BK Ok - Log event
            Transfer(_from, _to, _value);
            // BK Ok
            return true;
        }
        // BK Ok
        return false;
    }

    // BK NOTE - `onlyPayloadSize(...)` short address attack mitigation is no longer recommended
    // BK Ok
    function approve(address _spender, uint _value) onlyPayloadSize(2) notPaused returns (bool success) {
        // BK Ok
        if (controller.approve(msg.sender, _spender, _value)) {
            // BK Ok - Log event
            Approval(msg.sender, _spender, _value);
            // BK Ok
            return true;
        }
        // BK Ok
        return false;
    }

    // BK NOTE - `onlyPayloadSize(...)` short address attack mitigation is no longer recommended
    // BK Ok
    function increaseApproval (address _spender, uint _addedValue) onlyPayloadSize(2) notPaused returns (bool success) {
        // BK Ok
        if (controller.increaseApproval(msg.sender, _spender, _addedValue)) {
            // BK Ok
            uint newval = controller.allowance(msg.sender, _spender);
            // BK Ok - Log event
            Approval(msg.sender, _spender, newval);
            // BK Ok
            return true;
        }
        // BK Ok
        return false;
    }

    // BK NOTE - `onlyPayloadSize(...)` short address attack mitigation is no longer recommended
    // BK Ok
    function decreaseApproval (address _spender, uint _subtractedValue) onlyPayloadSize(2) notPaused returns (bool success) {
        // BK Ok
        if (controller.decreaseApproval(msg.sender, _spender, _subtractedValue)) {
            // BK Ok
            uint newval = controller.allowance(msg.sender, _spender);
            // BK Ok - Log event
            Approval(msg.sender, _spender, newval);
            // BK Ok
            return true;
        }
        // BK Ok
        return false;
    }

    // BK Ok
    modifier onlyPayloadSize(uint numwords) {
        // BK Ok
        assert(msg.data.length >= numwords * 32 + 4);
        // BK Ok
        _;
    }

    // BK Ok - Accounts can burn their own tokens
    function burn(uint _amount) notPaused {
        // BK Ok
        controller.burn(msg.sender, _amount);
        // BK Ok
        Transfer(msg.sender, 0x0, _amount);
    }

    // functions below this line are onlyController

    // BK Ok
    modifier onlyController() {
        // BK Ok
        assert(msg.sender == address(controller));
        // BK Ok
        _;
    }

    // BK Ok - Only controller can execute to log event
    function controllerTransfer(address _from, address _to, uint _value) onlyController {
        // BK Ok - Log event
        Transfer(_from, _to, _value);
    }

    // BK Ok - Only controller can execute to log event
    function controllerApprove(address _owner, address _spender, uint _value) onlyController {
        // BK Ok - Log event
        Approval(_owner, _spender, _value);
    }
}

// BK Ok
contract Controller is Owned, Finalizable {
    // BK Ok
    Ledger public ledger;
    // BK Ok
    Token public token;

    // BK Ok - Constructor
    function Controller() {
    }

    // functions below this line are onlyOwner

    // BK Ok - Only owner can change token address
    function setToken(address _token) onlyOwner {
        // BK Ok
        token = Token(_token);
    }

    // BK Ok - Only owner can change ledger address
    function setLedger(address _ledger) onlyOwner {
        // BK Ok
        ledger = Ledger(_ledger);
    }

    // BK Ok
    modifier onlyToken() {
        // BK Ok
        require(msg.sender == address(token));
        // BK Ok
        _;
    }

    // BK Ok
    modifier onlyLedger() {
        // BK Ok
        require(msg.sender == address(ledger));
        // BK Ok
        _;
    }

    // public functions

    // BK Ok - Constant function
    function totalSupply() constant returns (uint) {
        // BK Ok
        return ledger.totalSupply();
    }

    // BK Ok - Constant function
    function balanceOf(address _a) constant returns (uint) {
        // BK Ok
        return ledger.balanceOf(_a);
    }

    // BK Ok - Constant function
    function allowance(address _owner, address _spender) constant returns (uint) {
        // BK Ok
        return ledger.allowance(_owner, _spender);
    }

    // functions below this line are onlyLedger

    // BK Ok - Only ledger can execute, to log event when minting tokens
    function ledgerTransfer(address from, address to, uint val) onlyLedger {
        // BK Ok - Log Transfer event
        token.controllerTransfer(from, to, val);
    }

    // functions below this line are onlyToken

    // BK Ok - Only token contract can execute to instruct ledger to transfer(...)
    function transfer(address _from, address _to, uint _value) onlyToken returns (bool success) {
        // BK Ok
        return ledger.transfer(_from, _to, _value);
    }

    // BK Ok - Only token  contract can execute to instruct ledger to transferFrom(...)
    function transferFrom(address _spender, address _from, address _to, uint _value) onlyToken returns (bool success) {
        // BK Ok
        return ledger.transferFrom(_spender, _from, _to, _value);
    }

    // BK Ok - Only token contract can execute to instruct ledger to approve(...)
    function approve(address _owner, address _spender, uint _value) onlyToken returns (bool success) {
        // BK Ok
        return ledger.approve(_owner, _spender, _value);
    }

    // BK Ok - Only token contract can execute to instruct ledger to increaseApproval(...)
    function increaseApproval (address _owner, address _spender, uint _addedValue) onlyToken returns (bool success) {
        // BK Ok
        return ledger.increaseApproval(_owner, _spender, _addedValue);
    }

    // BK Ok - Only token contract can execute to instruct ledger to decreaseApproval(...)
    function decreaseApproval (address _owner, address _spender, uint _subtractedValue) onlyToken returns (bool success) {
        // BK Ok
        return ledger.decreaseApproval(_owner, _spender, _subtractedValue);
    }

    // BK Ok - Only token contract can execute to instruct ledger to burn(...)
    function burn(address _owner, uint _amount) onlyToken {
        // BK Ok
        ledger.burn(_owner, _amount);
    }
}

// BK Ok
contract Ledger is Owned, SafeMath, Finalizable {
    // BK Ok
    Controller public controller;
    // BK Ok
    mapping(address => uint) public balanceOf;
    // BK Ok
    mapping (address => mapping (address => uint)) public allowance;
    // BK Ok
    uint public totalSupply;
    // BK Ok
    uint public mintingNonce;
    // BK Ok
    bool public mintingStopped;

    // functions below this line are onlyOwner

    // BK Ok - Constructor
    function Ledger() {
    }

    // BK Ok - Only owner can execute whren not finalised
    function setController(address _controller) onlyOwner notFinalized {
        // BK Ok
        controller = Controller(_controller);
    }

    // BK NOTE - Can add `require(!mintingStopped);` so this is not run more than once
    // BK Ok
    function stopMinting() onlyOwner {
        // BK Ok
        mintingStopped = true;
    }

    // BK Ok - Only owner can mint
    function multiMint(uint nonce, uint256[] bits) onlyOwner {
        // BK Ok
        require(!mintingStopped);
        // BK Ok
        if (nonce != mintingNonce) return;
        // BK Ok
        mintingNonce += 1;
        // BK Ok
        uint256 lomask = (1 << 96) - 1;
        // BK Ok
        uint created = 0;
        // BK Ok
        for (uint i=0; i<bits.length; i++) {
            // BK Ok
            address a = address(bits[i]>>96);
            // BK Ok
            uint value = bits[i]&lomask;
            // BK Ok
            balanceOf[a] = balanceOf[a] + value;
            // BK Ok - Log event
            controller.ledgerTransfer(0, a, value);
            // BK Ok
            created += value;
        }
        // BK Ok
        totalSupply += created;
    }

    // functions below this line are onlyController

    // BK Ok
    modifier onlyController() {
        // BK Ok
        require(msg.sender == address(controller));
        // BK Ok
        _;
    }

    // BK Ok - Only controller can execute to record transfer
    function transfer(address _from, address _to, uint _value) onlyController returns (bool success) {
        // BK Ok
        if (balanceOf[_from] < _value) return false;

        // BK Ok
        balanceOf[_from] = safeSub(balanceOf[_from], _value);
        // BK Ok
        balanceOf[_to] = safeAdd(balanceOf[_to], _value);
        // BK Ok
        return true;
    }

    // BK Ok - Only controller can execute to record transferFrom(...)
    function transferFrom(address _spender, address _from, address _to, uint _value) onlyController returns (bool success) {
        // BK Ok
        if (balanceOf[_from] < _value) return false;

        // BK Ok
        var allowed = allowance[_from][_spender];
        // BK Ok
        if (allowed < _value) return false;

        // BK Ok
        balanceOf[_to] = safeAdd(balanceOf[_to], _value);
        // BK Ok
        balanceOf[_from] = safeSub(balanceOf[_from], _value);
        // BK NOTE - Good practice to move the following statement before the previous statement
        // BK Ok
        allowance[_from][_spender] = safeSub(allowed, _value);
        // BK Ok
        return true;
    }

    // BK Ok - Only controller can execute to record approve(...)
    function approve(address _owner, address _spender, uint _value) onlyController returns (bool success) {
        // BK NOTE - This is no longer recommended in the recently finalised ERC20 token standard
        // BK Ok
        if ((_value != 0) && (allowance[_owner][_spender] != 0)) {
            // BK Ok
            return false;
        }

        // BK Ok
        allowance[_owner][_spender] = _value;
        // BK Ok
        return true;
    }

    // BK Ok - Only controller can execute to record increaseApproval(...)
    function increaseApproval (address _owner, address _spender, uint _addedValue) onlyController returns (bool success) {
        // BK Ok
        uint oldValue = allowance[_owner][_spender];
        // BK Ok
        allowance[_owner][_spender] = safeAdd(oldValue, _addedValue);
        // BK Ok
        return true;
    }

    // BK Ok - Only controller can execute to record decreaseApproval(...)
    function decreaseApproval (address _owner, address _spender, uint _subtractedValue) onlyController returns (bool success) {
        // BK Ok
        uint oldValue = allowance[_owner][_spender];
        // BK Ok
        if (_subtractedValue > oldValue) {
            // BK Ok
            allowance[_owner][_spender] = 0;
        // BK Ok
        } else {
            // BK Ok
            allowance[_owner][_spender] = safeSub(oldValue, _subtractedValue);
        }
        // BK Ok
        return true;
    }

    // BK Ok - Only controller can execute to record burn(...)
    function burn(address _owner, uint _amount) onlyController {
        // BK Ok
        balanceOf[_owner] = safeSub(balanceOf[_owner], _amount);
        // BK Ok
        totalSupply = safeSub(totalSupply, _amount);
    }
}
```
