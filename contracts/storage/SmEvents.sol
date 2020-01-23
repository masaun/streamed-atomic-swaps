pragma solidity ^0.5.11;


contract SmEvents {

    event CreateStreamedSwap (
        uint256 swapStreamId,
        address sender,
        address recipient, 
        uint256 deposit1,  // Deposited amount of token Address 1
        uint256 deposit2,  // Deposited amount of token Address 2 
        address tokenAddress1,
        address tokenAddress2, 
        uint256 startTime, 
        uint256 stopTime
    );

    event CreateCompoundingStreamedSwap(
        uint256 indexed streamedSwapId, 
        uint256 exchangeRateCurrent, 
        uint256 senderSharePercentage, 
        uint256 recipientSharePercentage
    );
}
