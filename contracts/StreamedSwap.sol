pragma solidity ^0.5.11;
pragma experimental ABIEncoderV2;

// Sablier protocol
import "./sablier-protocol/protocol/contracts/Sablier.sol";

// Inherit CarefulMath.sol via Exponential.sol
import "./sablier-protocol/shared-contracts/compound/Exponential.sol";

// Storage
import "./storage/SmStorage.sol";
import "./storage/SmConstants.sol";

import "@openzeppelin/contracts-ethereum-package/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts-ethereum-package/contracts/ownership/Ownable.sol";


contract StreamedSwap is Ownable, SmStorage, SmConstants {

    /**
     * @notice Counter for new stream ids.
     */
    uint256 public nextStreamedSwapId;

    /**
     * @notice The stream objects identifiable by their unsigned integer ids.
     */
    mapping(uint256 => SmObjects.StreamedSwap) private streamedSwaps;




    Sablier public sablier;

    constructor(address _sablierContractAddress) public {
        sablier = Sablier(_sablierContractAddress);
    }

    function testFunc() public returns (bool) {
        return SmConstants.CONFIRMED;
    }


    /*********************************
     * @notice - Streamed Atomic Swap
     *********************************/
    function _createStreamedSwap(
        address recipient, 
        uint256 deposit1,      // Deposited amount of token Address 1
        uint256 deposit2,      // Deposited amount of token Address 2 
        address tokenAddress1, // Token Address 1
        address tokenAddress2, // Token Address 2
        uint256 startTime, 
        uint256 stopTime
    ) public returns (uint256) {
        /*** 
         * @notice - Integrate createStreamedSwap() 
         ***/
        CreateStreamedSwapLocalVars memory vars;
        (vars.mathErr, vars.duration) = subUInt(stopTime, startTime);
        (vars.mathErr, vars.ratePerSecond) = divUInt(deposit, vars.duration);

        /* Create and store the swap stream object. */
        uint256 streamedSwapId = nextStreamedSwapId;
        streamedSwaps[streamedSwapId] = SmObjects.StreamedSwap({
            deposit1: deposit1,  // Deposited amount of token Address 1
            deposit2: deposit2,  // Deposited amount of token Address 2
            ratePerSecond: vars.ratePerSecond,
            remainingBalance: deposit,
            startTime: startTime,
            stopTime: stopTime,
            recipient: recipient,
            sender: msg.sender,
            tokenAddress1: tokenAddress1,  // Token Address 1
            tokenAddress2: tokenAddress2,  // Token Address 2
            isEntity: true
        });

        /*** 
         * @notice - Swap streamed money
         * @dev - The step is from 1st to 2nd  
         ***/
        // [1st Step]: Transfer deposited money from address of each other to contract address.
        IERC20(tokenAddress1).transferFrom(msg.sender, address(this), deposit);
        IERC20(tokenAddress2).transferFrom(recipient, address(this), deposit);

        // [2nd Step]: Transfer exchanged money from contract address to address of each other.
        IERC20(tokenAddress1).transferFrom(address(this), msg.sender, deposit);
        IERC20(tokenAddress2).transferFrom(address(this), recipient, deposit);        


        /* Increment the next stream id. */
        (vars.mathErr, nextStreamedSwapId) = addUInt(nextStreamedSwapId, uint256(1));

        emit CreateStreamedSwap(streamedSwapId, 
                                msg.sender, 
                                recipient, 
                                deposit, 
                                tokenAddress1, 
                                tokenAddress2, 
                                startTime, 
                                stopTime);

        return streamedSwapId;
    }
    
}
