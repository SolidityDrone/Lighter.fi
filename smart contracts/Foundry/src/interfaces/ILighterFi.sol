pragma solidity ^0.8.19;

interface ILighterFi {
    struct UserStrategy {
        address user;
        address tokenIn;
        address tokenOut;
        uint256 timeInterval;
        uint256 nextExecution;
        uint256 amount;
        uint256 limit;
        bytes lastResponse;
    }
    
    error NotAllowedCaller(
        address caller,
        address owner,
        address automationRegistry
    );

    event NewUserStrategy(address indexed user, UserStrategy userStrategy, uint256 strategyIndex);
    event RemovedUserStrategy(address indexed user, uint256 strategyIndex);
    event UpdatedUserStrategy(address indexed user, UserStrategy userStrategy, uint256 strategyIndex);
    event RequestReceived(bytes32 indexed requestId , uint256 strategyIndex);
    event Response(bytes32 indexed requestId, bytes response, bytes err);
    event SwapExecuted(bytes32 indexed requestId, uint256 strategyIndex, uint256 amountIn, uint amountOut, address user, address tokenIn, address tokenOut);
}
