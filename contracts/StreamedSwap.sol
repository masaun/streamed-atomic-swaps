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
        uint256 deposit, 
        address tokenAddress1,
        address tokenAddress2, 
        uint256 startTime, 
        uint256 stopTime
    ) public returns (uint256) {
        IERC20 token1 = IERC20(0xaD6D458402F60fD3Bd25163575031ACDce07538D); // get a handle for the token contract（DAI on ropsten）
        token1.approve(address(sablier), deposit); // approve the transfer

        IERC20 token2 = IERC20(0xDb0040451F373949A4Be60dcd7b6B8D6E42658B6); // get a handle for the token contract（BAT on ropsten）
        token2.approve(address(sablier), deposit); // approve the transfer

        // the stream id is needed later to withdraw from or cancel the stream
        //uint256 streamedSwapId = createStreamedSwap(recipient, deposit, address(token1), address(token2), startTime, stopTime);


        /*** 
         * @notice - Integrate createStreamedSwap() 
         ***/
        CreateStreamedSwapLocalVars memory vars;
        (vars.mathErr, vars.duration) = subUInt(stopTime, startTime);
        (vars.mathErr, vars.ratePerSecond) = divUInt(deposit, vars.duration);

        /* Create and store the swap stream object. */
        uint256 streamedSwapId = nextStreamedSwapId;
        streamedSwaps[streamedSwapId] = SmObjects.StreamedSwap({
            deposit: deposit,
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

        /* Swap (Transfer) streaming money */
        IERC20(tokenAddress1).transferFrom(msg.sender, address(this), deposit);
        IERC20(tokenAddress2).transferFrom(recipient, address(this), deposit);

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
