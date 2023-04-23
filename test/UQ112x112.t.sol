// SPDX-License-Identifier: Unlicense
pragma solidity >=0.8.10;

import "forge-std/Test.sol";
import "../src/libraries/UQ112x112.sol";

contract UQ112x112Test is Test {
    
    function testEncode() public {
        uint112 y = 12345;
        uint224 expected = uint224(y) * 2 ** 112;
        uint224 result = UQ112x112.encode(y);
        assertEq(result, expected, "Encode result should match expected value");
    }

    function testUQDiv() public {
        uint224 x = 123456789;
        uint112 y = 9876;
        uint224 expected = x / uint224(y);
        uint224 result = UQ112x112.uqdiv(x, y);
        assertEq(result, expected, "UQDiv result should match expected value");
    }
}