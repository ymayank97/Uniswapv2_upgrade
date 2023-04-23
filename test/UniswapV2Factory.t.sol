// SPDX-License-Identifier: Unlicense
pragma solidity >=0.8.10;

import "forge-std/Test.sol";
import "../src/UniswapV2Factory.sol";
import "../src/UniswapV2Pair.sol";
import "./mocks/MintERC20.sol";

contract UniswapV2FactoryTest is Test {
    UniswapV2Factory factory;

    MintERC20 erc_token0;
    MintERC20 erc_token1;

    function setUp() public {
        factory = new UniswapV2Factory();

        erc_token0 = new MintERC20("Token A", "TKNA");
        erc_token1 = new MintERC20("Token B", "TKNB");
    }

    function encodeError(
        string memory error
    ) internal pure returns (bytes memory encoded) {
        encoded = abi.encodeWithSignature(error);
    }

    function testCreatePair() public {
        address pairAddress = factory.createPair(
            address(erc_token1),
            address(erc_token0)
        );

        UniswapV2Pair pair = UniswapV2Pair(pairAddress);

        assertEq(pair.token0(), address(erc_token0));
        assertEq(pair.token1(), address(erc_token1));
    }

    function testCreatePairZeroAddress() public {
        vm.expectRevert(encodeError("ZeroAddress()"));
        factory.createPair(address(0), address(erc_token0));

        vm.expectRevert(encodeError("ZeroAddress()"));
        factory.createPair(address(erc_token1), address(0));
    }

    function testCreatePairPairExists() public {
        factory.createPair(address(erc_token1), address(erc_token0));

        vm.expectRevert(encodeError("PairExists()"));
        factory.createPair(address(erc_token1), address(erc_token0));
    }

    function testCreatePairIdenticalTokens() public {
        vm.expectRevert(encodeError("IdenticalAddresses()"));
        factory.createPair(address(erc_token0), address(erc_token0));
    }
}
