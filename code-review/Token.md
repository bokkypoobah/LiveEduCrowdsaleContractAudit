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
    function transfer(address _to, uint _value) onlyPayloadSize(2) notPaused returns (bool success) {
        // BK Ok
        if (controller.transfer(msg.sender, _to, _value)) {
            // BK Ok
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
    function transferFrom(address _from, address _to, uint _value) onlyPayloadSize(3) notPaused returns (bool success) {
        // BK Ok
        if (controller.transferFrom(msg.sender, _from, _to, _value)) {
            // BK Ok
            Transfer(_from, _to, _value);
            // BK Ok
            return true;
        }
        // BK Ok
        return false;
    }

    // BK NOTE - `onlyPayloadSize(...)` short address attack mitigation is no longer recommended
    function approve(address _spender, uint _value) onlyPayloadSize(2) notPaused returns (bool success) {
        if (controller.approve(msg.sender, _spender, _value)) {
            Approval(msg.sender, _spender, _value);
            return true;
        }
        return false;
    }

    // BK NOTE - `onlyPayloadSize(...)` short address attack mitigation is no longer recommended
    function increaseApproval (address _spender, uint _addedValue) onlyPayloadSize(2) notPaused returns (bool success) {
        if (controller.increaseApproval(msg.sender, _spender, _addedValue)) {
            uint newval = controller.allowance(msg.sender, _spender);
            Approval(msg.sender, _spender, newval);
            return true;
        }
        return false;
    }

    // BK NOTE - `onlyPayloadSize(...)` short address attack mitigation is no longer recommended
    function decreaseApproval (address _spender, uint _subtractedValue) onlyPayloadSize(2) notPaused returns (bool success) {
        if (controller.decreaseApproval(msg.sender, _spender, _subtractedValue)) {
            uint newval = controller.allowance(msg.sender, _spender);
            Approval(msg.sender, _spender, newval);
            return true;
        }
        return false;
    }

    modifier onlyPayloadSize(uint numwords) {
        assert(msg.data.length >= numwords * 32 + 4);
        _;
    }

    function burn(uint _amount) notPaused {
        controller.burn(msg.sender, _amount);
        Transfer(msg.sender, 0x0, _amount);
    }

    // functions below this line are onlyController

    modifier onlyController() {
        assert(msg.sender == address(controller));
        _;
    }

    function controllerTransfer(address _from, address _to, uint _value) onlyController {
        Transfer(_from, _to, _value);
    }

    function controllerApprove(address _owner, address _spender, uint _value) onlyController {
        Approval(_owner, _spender, _value);
    }
}

contract Controller is Owned, Finalizable {
    Ledger public ledger;
    Token public token;

    function Controller() {
    }

    // functions below this line are onlyOwner

    function setToken(address _token) onlyOwner {
        token = Token(_token);
    }

    function setLedger(address _ledger) onlyOwner {
        ledger = Ledger(_ledger);
    }

    modifier onlyToken() {
        require(msg.sender == address(token));
        _;
    }

    modifier onlyLedger() {
        require(msg.sender == address(ledger));
        _;
    }

    // public functions

    function totalSupply() constant returns (uint) {
        return ledger.totalSupply();
    }

    function balanceOf(address _a) constant returns (uint) {
        return ledger.balanceOf(_a);
    }

    function allowance(address _owner, address _spender) constant returns (uint) {
        return ledger.allowance(_owner, _spender);
    }

    // functions below this line are onlyLedger

    function ledgerTransfer(address from, address to, uint val) onlyLedger {
        token.controllerTransfer(from, to, val);
    }

    // functions below this line are onlyToken

    function transfer(address _from, address _to, uint _value) onlyToken returns (bool success) {
        return ledger.transfer(_from, _to, _value);
    }

    function transferFrom(address _spender, address _from, address _to, uint _value) onlyToken returns (bool success) {
        return ledger.transferFrom(_spender, _from, _to, _value);
    }

    function approve(address _owner, address _spender, uint _value) onlyToken returns (bool success) {
        return ledger.approve(_owner, _spender, _value);
    }

    function increaseApproval (address _owner, address _spender, uint _addedValue) onlyToken returns (bool success) {
        return ledger.increaseApproval(_owner, _spender, _addedValue);
    }

    function decreaseApproval (address _owner, address _spender, uint _subtractedValue) onlyToken returns (bool success) {
        return ledger.decreaseApproval(_owner, _spender, _subtractedValue);
    }

    function burn(address _owner, uint _amount) onlyToken {
        ledger.burn(_owner, _amount);
    }
}

contract Ledger is Owned, SafeMath, Finalizable {
    Controller public controller;
    mapping(address => uint) public balanceOf;
    mapping (address => mapping (address => uint)) public allowance;
    uint public totalSupply;
    uint public mintingNonce;
    bool public mintingStopped;

    // functions below this line are onlyOwner

    function Ledger() {
    }

    function setController(address _controller) onlyOwner notFinalized {
        controller = Controller(_controller);
    }

    function stopMinting() onlyOwner {
        mintingStopped = true;
    }

    function multiMint(uint nonce, uint256[] bits) onlyOwner {
        require(!mintingStopped);
        if (nonce != mintingNonce) return;
        mintingNonce += 1;
        uint256 lomask = (1 << 96) - 1;
        uint created = 0;
        for (uint i=0; i<bits.length; i++) {
            address a = address(bits[i]>>96);
            uint value = bits[i]&lomask;
            balanceOf[a] = balanceOf[a] + value;
            controller.ledgerTransfer(0, a, value);
            created += value;
        }
        totalSupply += created;
    }

    // functions below this line are onlyController

    modifier onlyController() {
        require(msg.sender == address(controller));
        _;
    }

    function transfer(address _from, address _to, uint _value) onlyController returns (bool success) {
        if (balanceOf[_from] < _value) return false;

        balanceOf[_from] = safeSub(balanceOf[_from], _value);
        balanceOf[_to] = safeAdd(balanceOf[_to], _value);
        return true;
    }

    function transferFrom(address _spender, address _from, address _to, uint _value) onlyController returns (bool success) {
        if (balanceOf[_from] < _value) return false;

        var allowed = allowance[_from][_spender];
        if (allowed < _value) return false;

        balanceOf[_to] = safeAdd(balanceOf[_to], _value);
        balanceOf[_from] = safeSub(balanceOf[_from], _value);
        allowance[_from][_spender] = safeSub(allowed, _value);
        return true;
    }

    function approve(address _owner, address _spender, uint _value) onlyController returns (bool success) {
        if ((_value != 0) && (allowance[_owner][_spender] != 0)) {
            return false;
        }

        allowance[_owner][_spender] = _value;
        return true;
    }

    function increaseApproval (address _owner, address _spender, uint _addedValue) onlyController returns (bool success) {
        uint oldValue = allowance[_owner][_spender];
        allowance[_owner][_spender] = safeAdd(oldValue, _addedValue);
        return true;
    }

    function decreaseApproval (address _owner, address _spender, uint _subtractedValue) onlyController returns (bool success) {
        uint oldValue = allowance[_owner][_spender];
        if (_subtractedValue > oldValue) {
            allowance[_owner][_spender] = 0;
        } else {
            allowance[_owner][_spender] = safeSub(oldValue, _subtractedValue);
        }
        return true;
    }

    function burn(address _owner, uint _amount) onlyController {
        balanceOf[_owner] = safeSub(balanceOf[_owner], _amount);
        totalSupply = safeSub(totalSupply, _amount);
    }
}
```
