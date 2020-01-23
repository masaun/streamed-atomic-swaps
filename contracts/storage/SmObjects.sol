pragma solidity ^0.5.11;

// Inherit CarefulMath.sol via Exponential.sol
import "../sablier-protocol/shared-contracts/compound/Exponential.sol";


contract SmObjects is Exponential {

    struct StreamedSwap {
        uint256 deposit1;  // Deposited amount of token Address 1
        uint256 deposit2;  // Deposited amount of token Address 2
        uint256 ratePerSecond;
        uint256 remainingBalance1;
        uint256 remainingBalance2;        
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


    /***
     * @notice - This struct is for streamed-compounding-swap
     ***/
    struct StreamedCompoundingSwapVars {
        Exponential.Exp exchangeRateInitial;
        Exponential.Exp senderShare;
        Exponential.Exp recipientShare;
        bool isEntity;
    }

    struct CreateStreamedCompoundingSwapLocalVars {
        MathError mathErr;
        uint256 shareSum;
        uint256 underlyingBalance;
        uint256 senderShareMantissa;
        uint256 recipientShareMantissa;
    }


    struct ExampleObject {
        address addr;
        uint amount;
    }
    
}
