// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

interface ERC20 {
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
}

/* Uniswap V2 */
interface IUniswapV2Router02 {
    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);
}

/* Uniswap V3 */
interface IUniswapV3Pool {
    function initialize(uint160 sqrtPriceX96) external;
}

interface IUniswapV3Factory {
    function getPool(
        address tokenA,
        address tokenB,
        uint24 fee
    ) external view returns (address pool);
}

interface INonfungiblePositionManager {
    function mint(
        MintParams calldata params
    )
        external
        returns (
            uint256 tokenId,
            uint128 liquidity,
            uint256 amount0,
            uint256 amount1
        );
}

interface IUniswapV3Router {
    function exactInputSingle(
        ExactInputSingleParams calldata params
    ) external payable returns (uint256 amountOut);
}

struct MintParams {
    address token0;
    address token1;
    uint24 fee;
    int24 tickLower;
    int24 tickUpper;
    uint256 amount0Desired;
    uint256 amount1Desired;
    uint256 amount0Min;
    uint256 amount1Min;
    address recipient;
    uint256 deadline;
}

struct ExactInputSingleParams {
    address tokenIn;
    address tokenOut;
    uint24 fee;
    address recipient;
    uint256 deadline;
    uint256 amountIn;
    uint256 amountOutMinimum;
    uint160 sqrtPriceLimitX96;
}

contract UnicheatV2 {
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

contract UnicheatV3 {
    address public factory;
    address public positionManager;
    address public router;

    constructor(address _factory, address _positionManager, address _router) {
        factory = _factory;
        positionManager = _positionManager;
        router = _router;
    }

    /** Calls `initialize` on the pool for the given tokens with a 1:1 price ratio. */
    function initPool(address tokenA, address tokenB, uint24 fee) public {
        address pool = IUniswapV3Factory(factory).getPool(tokenA, tokenB, fee);
        IUniswapV3Pool(pool).initialize(79228162514264337593543950336);
    }

    /** Calls `mint` on the positionManager with the assumption that it was created with a 1:1 price ratio. */
    function mint(
        address tokenA,
        address tokenB,
        uint24 fee,
        uint256 amountA,
        uint256 amountB
    ) public {
        (address token0, address token1) = tokenA < tokenB
            ? (tokenA, tokenB)
            : (tokenB, tokenA);
        (uint256 amount0, uint256 amount1) = tokenA < tokenB
            ? (amountA, amountB)
            : (amountB, amountA);
        MintParams memory params = MintParams({
            token0: token0,
            token1: token1,
            fee: fee,
            tickLower: -120,
            tickUpper: 120,
            amount0Desired: amount0,
            amount1Desired: amount1,
            amount0Min: 0,
            amount1Min: 0,
            recipient: address(this),
            deadline: block.timestamp + 100
        });
        INonfungiblePositionManager(positionManager).mint(params);
    }

    /** Calls `exactInputSingle` on UniV3Router, using this contract's token balances. */
    function swap(ExactInputSingleParams calldata params) public {
        uint256 amountOut = IUniswapV3Router(router).exactInputSingle(params);
        if (params.recipient != address(this)) {
            // transfer the output token from the recipient back to this contract
            ERC20(params.tokenOut).transferFrom(
                params.recipient,
                address(this),
                amountOut
            );
        }
    }
}
