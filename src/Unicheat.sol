// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

interface ERC20 {
    function approve(address spender, uint256 amount) external returns (bool);
}

interface IUniswapV2Router02 {
    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);
}

contract Unicheat {
    address public router;

    constructor(address _router) {
        router = _router;
    }

    function swap(address tokenIn, address tokenOut, uint256 amountIn) public {
        // approve router to spend this contract's tokens
        ERC20(tokenIn).approve(router, amountIn);

        address[] memory path = new address[](2);
        path[0] = tokenIn;
        path[1] = tokenOut;

        IUniswapV2Router02(router).swapExactTokensForTokens(
            amountIn,
            1,
            path,
            address(this),
            block.timestamp + 100
        );
    }
}
