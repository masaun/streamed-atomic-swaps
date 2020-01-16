pragma solidity ^0.5.11;


contract SmEvents {

    event CreateStreamedSwap (
        uint256 swapStreamId,
        address sender,
        address recipient, 
        uint256 deposit, 
        address tokenAddress1,
        address tokenAddress2, 
        uint256 startTime, 
        uint256 stopTime
    );

}
