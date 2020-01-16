pragma solidity ^0.5.11;

//import "../sablier-protocol/shared-contracts/compound/CarefulMath.sol";
import "./shared-contracts/compound/CarefulMath.sol";


contract SmObjects {

    struct StreamedSwap {
        uint256 deposit;
        uint256 ratePerSecond;
        uint256 remainingBalance;
        uint256 startTime;
        uint256 stopTime;
        address recipient;
        address sender;
        address tokenAddress1;  // Token Address 1
        address tokenAddress2;  // Token Address 2
        bool isEntity;
    }


    struct CreateStreamedSwapLocalVars {
        MathError mathErr;
        uint256 duration;
        uint256 ratePerSecond;
    }
}
