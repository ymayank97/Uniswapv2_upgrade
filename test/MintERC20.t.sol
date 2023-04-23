// SPDX-License-Identifier: Unlicense
pragma solidity >=0.8.10;

import "forge-std/Test.sol";
import "./mocks/MintERC20.sol";

contract MintERC20Test is Test {
    function testMint() public {
        // Deploy the contract
        MintERC20 mintERC20 = new MintERC20("Test Token", "TST");

        // Mint some tokens to an address
        address to = address(0x123);
        uint256 amount = 100;
        mintERC20.mint(amount, to);

        // Check that the balance of the recipient matches the minted amount
        assertEq(mintERC20.balanceOf(to), amount, "Balance should match minted amount");
    }
}