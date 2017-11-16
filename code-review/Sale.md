# Sale

Source file [../contracts/Sale.sol](../contracts/Sale.sol).

<br />

<hr />

```javascript
// Copyright New Alchemy Limited, 2017. All rights reserved.

// BK Ok - Was deployed with Solidity v0.4.14+commit.c2215d46 and optimisation switched on
pragma solidity >=0.4.10;

// Just the bits of ERC20 that we need.
// BK Ok
contract Token {
    // BK Ok
    function balanceOf(address addr) returns(uint);
    // BK Ok
    function transfer(address to, uint amount) returns(bool);
}

// BK Ok
contract Sale {
    // BK Ok
    address public owner;    // contract owner
    // BK Ok
    address public newOwner; // new contract owner for two-way ownership handshake
    // BK Ok
    string public notice;    // arbitrary public notice text
    // BK Next 4 Ok
    uint public start;       // start time of sale
    uint public end;         // end time of sale
    uint public cap;         // Ether hard cap
    bool public live;        // sale is live right now

    // BK Ok - Events
    event StartSale();
    event EndSale();
    event EtherIn(address from, uint amount);

    // BK Ok - Constructor
    function Sale() {
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

    // BK Ok - Anyone can contribute ETH
    function () payable {
        // BK Ok
        require(block.timestamp >= start);

        // If we've reached end-of-sale conditions, accept
        // this as the last contribution and emit the EndSale event.
        // (Technically this means we allow exactly one contribution
        // after the end of the sale.)
        // Conversely, if we haven't started the sale yet, emit
        // the StartSale event.
        // BK Ok
        if (block.timestamp > end || this.balance > cap) {
            // BK Ok
            require(live);
            // BK Ok
            live = false;
            // BK Ok - Log event 
            EndSale();
        // BK Ok
        } else if (!live) {
            // BK Ok
            live = true;
            // BK Ok - Log event 
            StartSale();
        }
        // BK Ok - Log event
        EtherIn(msg.sender, msg.value);
    }

    // BK Ok - Only owner can execute this
    function init(uint _start, uint _end, uint _cap) onlyOwner {
        // BK Next 3 Ok
        start = _start;
        end = _end;
        cap = _cap;
    }

    // BK Ok - Only owner can execute this
    function softCap(uint _newend) onlyOwner {
        // BK Ok
        require(_newend >= block.timestamp && _newend >= start && _newend <= end);
        // BK Ok
        end = _newend;
    }

    // 1st half of ownership change
    // BK Ok - Only owner can execute this
    function changeOwner(address next) onlyOwner {
        // BK Ok
        newOwner = next;
    }

    // 2nd half of ownership change
    // BK Ok - Only newOwner can execute this
    function acceptOwnership() {
        // BK Ok
        require(msg.sender == newOwner);
        // BK Ok
        owner = msg.sender;
        // BK Ok
        newOwner = 0;
    }

    // put some text in the contract
    // BK Ok - Only owner can execute this
    function setNotice(string note) onlyOwner {
        // BK Ok
        notice = note;
    }

    // withdraw all of the Ether
    // BK Ok - Only owner can execute this
    function withdraw() onlyOwner {
        // BK Ok
        msg.sender.transfer(this.balance);
    }

    // withdraw some of the Ether
    // BK Ok - Only owner can execute this
    function withdrawSome(uint value) onlyOwner {
        // BK Ok
        require(value <= this.balance);
        // BK Ojk
        msg.sender.transfer(value);
    }

    // withdraw tokens to owner
    // BK Ok - Only owner can execute this
    function withdrawToken(address token) onlyOwner {
        // BK Ok
        Token t = Token(token);
        // BK Ok
        require(t.transfer(msg.sender, t.balanceOf(this)));
    }

    // refund early/late tokens
    // BK Ok - Only owner can execute this
    function refundToken(address token, address sender, uint amount) onlyOwner {
        // BK Ok
        Token t = Token(token);
        // BK Ok
        require(t.transfer(sender, amount));
    }
}
```
