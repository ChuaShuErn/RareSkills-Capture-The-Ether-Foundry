// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/TokenWhale.sol";

contract TokenWhaleTest is Test {
    TokenWhale public tokenWhale;
    ExploitContract public exploitContract;
    // Feel free to use these random addresses
    address constant Alice = address(0x5E12E7);
    address constant Bob = address(0x5311E8);
    address constant Pete = address(0x5E41E9);

    function setUp() public {
        // Deploy contracts
        tokenWhale = new TokenWhale(address(this));
        exploitContract = new ExploitContract(tokenWhale);
        exploitContract.setPlayer(address(this));
        vm.label(Alice, "Alice");
        vm.label(Bob, "Bob");
        vm.label(Pete, "Pete");
        vm.label(address(tokenWhale), "Token Whale");
        vm.label(address(exploitContract), "Exploiter");
        vm.label(address(this), "Player");
    }

    // Use the instance tokenWhale and exploitContract
    // Use vm.startPrank and vm.stopPrank to change between msg.sender
    function testExploit() public {
        // Put your solution here
        console.log("Balance of Player At Start:", tokenWhale.balanceOf(address(this)));
        vm.startPrank(address(this));
        tokenWhale.approve(address(exploitContract), 100e18);
        exploitContract.Exploit();
        console.log("Balance of ExploitContract:", tokenWhale.balanceOf(address(exploitContract)));
        console.log("Balance of Player:", tokenWhale.balanceOf(address(this)));
        vm.stopPrank();

        _checkSolved();
    }

    function _checkSolved() internal {
        assertTrue(tokenWhale.isComplete(), "Challenge Incomplete");
    }

    receive() external payable {}
}
