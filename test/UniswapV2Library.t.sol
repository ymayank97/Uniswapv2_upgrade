// SPDX-License-Identifier: Unlicense
pragma solidity >=0.8.10;

import "forge-std/Test.sol";
import "../src/UniswapV2Library.sol";
import "../src/UniswapV2Factory.sol";
import "../src/UniswapV2Pair.sol";
import "./mocks/MintERC20.sol";

contract UniswapV2LibraryTest is Test {
    UniswapV2Factory factory;

    MintERC20 tokenA;
    MintERC20 tokenB;
    MintERC20 tokenC;
    MintERC20 tokenD;

    UniswapV2Pair pair;
    UniswapV2Pair pair2;
    UniswapV2Pair pair3;

    function encodeError(
        string memory error
    ) internal pure returns (bytes memory encoded) {
        encoded = abi.encodeWithSignature(error);
    }

    function setUp() public {
        factory = new UniswapV2Factory();

        tokenA = new MintERC20("TokenA", "TKNA");
        tokenB = new MintERC20("TokenB", "TKNB");
        tokenC = new MintERC20("TokenC", "TKNC");
        tokenD = new MintERC20("TokenD", "TKND");

        tokenA.mint(10 ether, address(this));
        tokenB.mint(10 ether, address(this));
        tokenC.mint(10 ether, address(this));
        tokenD.mint(10 ether, address(this));

        address pairAddress = factory.createPair(
            address(tokenA),
            address(tokenB)
        );
        pair = UniswapV2Pair(pairAddress);

        pairAddress = factory.createPair(address(tokenB), address(tokenC));
        pair2 = UniswapV2Pair(pairAddress);

        pairAddress = factory.createPair(address(tokenC), address(tokenD));
        pair3 = UniswapV2Pair(pairAddress);
    }

    function testGetReserves() public {
        tokenA.transfer(address(pair), 1.1 ether);
        tokenB.transfer(address(pair), 0.8 ether);

        UniswapV2Pair(address(pair)).mint(address(this));

        (uint256 reserve0, uint256 reserve1) = UniswapV2Library.getReserves(
            address(factory),
            address(tokenA),
            address(tokenB)
        );

        assertEq(reserve0, 1.1 ether);
        assertEq(reserve1, 0.8 ether);
    }



    function testPairForTokensSorting() public {
        address pairAddress = UniswapV2Library.pairFor(
            address(factory),
            address(tokenB),
            address(tokenA)
        );

        assertEq(pairAddress, factory.pairs(address(tokenA), address(tokenB)));
    }


    function testGetAmountOut() public {
        uint256 amountOut = UniswapV2Library.getAmountOut(
            1000,
            1 ether,
            1.5 ether
        );
        assertEq(amountOut, 1495);
    }

    function testGetAmountOutZeroInputAmount() public {
        vm.expectRevert(encodeError("InsufficientAmount()"));
        UniswapV2Library.getAmountOut(0, 1 ether, 1.5 ether);
    }

    function testGetAmountOutZeroInputReserve() public {
        vm.expectRevert(encodeError("InsufficientLiquidity()"));
        UniswapV2Library.getAmountOut(1000, 0, 1.5 ether);
    }

    function testGetAmountOutZeroOutputReserve() public {
        vm.expectRevert(encodeError("InsufficientLiquidity()"));
        UniswapV2Library.getAmountOut(1000, 1 ether, 0);
    }

    function testGetAmountsOut() public {
        tokenA.transfer(address(pair), 1 ether);
        tokenB.transfer(address(pair), 2 ether);
        pair.mint(address(this));

        tokenB.transfer(address(pair2), 1 ether);
        tokenC.transfer(address(pair2), 0.5 ether);
        pair2.mint(address(this));

        tokenC.transfer(address(pair3), 1 ether);
        tokenD.transfer(address(pair3), 2 ether);
        pair3.mint(address(this));

        address[] memory path = new address[](4);
        path[0] = address(tokenA);
        path[1] = address(tokenB);
        path[2] = address(tokenC);
        path[3] = address(tokenD);

        uint256[] memory amounts = UniswapV2Library.getAmountsOut(
            address(factory),
            0.1 ether,
            path
        );

        assertEq(amounts.length, 4);
        assertEq(amounts[0], 0.1 ether);
        assertEq(amounts[1], 0.181322178776029826 ether);
        assertEq(amounts[2], 0.076550452221167502 ether);
        assertEq(amounts[3], 0.141817942760565270 ether);
    }

    function testGetAmountsOutInvalidPath() public {
        address[] memory path = new address[](1);
        path[0] = address(tokenA);

        vm.expectRevert(encodeError("InvalidPath()"));
        UniswapV2Library.getAmountsOut(address(factory), 0.1 ether, path);
    }

    function testGetAmountIn() public {
        uint256 amountIn = UniswapV2Library.getAmountIn(
            1495,
            1 ether,
            1.5 ether
        );
        assertEq(amountIn, 1000);
    }


    function testGetAmountsIn() public {
        tokenA.transfer(address(pair), 1 ether);
        tokenB.transfer(address(pair), 2 ether);
        pair.mint(address(this));

        tokenB.transfer(address(pair2), 1 ether);
        tokenC.transfer(address(pair2), 0.5 ether);
        pair2.mint(address(this));

        tokenC.transfer(address(pair3), 1 ether);
        tokenD.transfer(address(pair3), 2 ether);
        pair3.mint(address(this));

        address[] memory path = new address[](4);
        path[0] = address(tokenA);
        path[1] = address(tokenB);
        path[2] = address(tokenC);
        path[3] = address(tokenD);

        uint256[] memory amounts = UniswapV2Library.getAmountsIn(
            address(factory),
            0.1 ether,
            path
        );

        assertEq(amounts.length, 4);
        assertEq(amounts[0], 0.063113405152841847 ether);
        assertEq(amounts[1], 0.118398043685444580 ether);
        assertEq(amounts[2], 0.052789948793749671 ether);
        assertEq(amounts[3], 0.100000000000000000 ether);
    }

    function testGetAmountsInInvalidPath() public {
        address[] memory path = new address[](1);
        path[0] = address(tokenA);

        vm.expectRevert(encodeError("InvalidPath()"));
        UniswapV2Library.getAmountsIn(address(factory), 0.1 ether, path);
    }

    function testSortTokens() public {
    (address token0, address token1) = UniswapV2Library.sortTokens(
        address(tokenA),
        address(tokenB)
    );
    assertEq(token0, address(tokenA));
    assertEq(token1, address(tokenB));

    (token0, token1) = UniswapV2Library.sortTokens(
        address(tokenB),
        address(tokenA)
    );
    assertEq(token0, address(tokenA));
    assertEq(token1, address(tokenB));
}

function testPairFor() public {
        address pairAddress = UniswapV2Library.pairFor(
            address(factory),
            address(tokenA),
            address(tokenB)
        );

        assertEq(pairAddress, factory.pairs(address(tokenA), address(tokenB)));
}


function testQuote() public {
    uint256 amountA = UniswapV2Library.quote(
        1000,
        1 ether,
        1.5 ether
    );
    assertEq(amountA, 1500);

    uint256 amountB = UniswapV2Library.quote(
        1000,
        1.5 ether,
        1 ether
    );
    assertEq(amountB, 666);

}

function testGetReserves_2() public {
    tokenA.transfer(address(pair), 1 ether);
    tokenB.transfer(address(pair), 2 ether);
    pair.mint(address(this));

    (uint256 reserveA, uint256 reserveB) = UniswapV2Library.getReserves(
        address(factory),
        address(tokenA),
        address(tokenB)
    );

    assertEq(reserveA, 1 ether);
    assertEq(reserveB, 2 ether);

}


function testGetAmountInZeroInputAmount() public {
        vm.expectRevert(encodeError("InsufficientAmount()"));
        UniswapV2Library.getAmountIn(0, 1 ether, 1.5 ether);
    }

    function testGetAmountInZeroInputReserve() public {
        vm.expectRevert(encodeError("InsufficientLiquidity()"));
        UniswapV2Library.getAmountIn(1000, 0, 1.5 ether);
    }



    function testGetAmountInZeroOutputReserve() public {
        vm.expectRevert(encodeError("InsufficientLiquidity()"));
        UniswapV2Library.getAmountIn(1000, 1 ether, 0);
    }

    function testGetAmountOutZeroInputAmount_2() public {
        vm.expectRevert(encodeError("InsufficientAmount()"));
        UniswapV2Library.getAmountOut(0, 1 ether, 1.5 ether);
    }

}