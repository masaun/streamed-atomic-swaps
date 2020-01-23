pragma solidity ^0.5.11;
pragma experimental ABIEncoderV2;

// Sablier protocol
import "./sablier-protocol/protocol/contracts/Sablier.sol";

// Inherit CarefulMath.sol via Exponential.sol
import "./sablier-protocol/shared-contracts/compound/Exponential.sol";

// Storage
import "./storage/SmStorage.sol";
import "./storage/SmConstants.sol";

//import "@openzeppelin/contracts-ethereum-package/contracts/token/ERC20/ERC20.sol"; // ERC20
import "@openzeppelin/contracts-ethereum-package/contracts/token/ERC20/IERC20.sol";  // IERC20
import "@openzeppelin/contracts-ethereum-package/contracts/ownership/Ownable.sol";

import "@openzeppelin/contracts-ethereum-package/contracts/math/SafeMath.sol";


contract StreamedSwap is Ownable, SmStorage, SmConstants {

    using SafeMath for uint256;

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
        (vars.mathErr, vars.ratePerSecond) = divUInt(deposit1, vars.duration);

        /* Create and store the swap stream object. */
        uint256 streamedSwapId = nextStreamedSwapId;
        streamedSwaps[streamedSwapId] = SmObjects.StreamedSwap({
            deposit1: deposit1,  // Deposited amount of token Address 1
            deposit2: deposit2,  // Deposited amount of token Address 2
            ratePerSecond: vars.ratePerSecond,
            remainingBalance1: deposit1,
            remainingBalance2: deposit2,
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
        IERC20(tokenAddress1).transferFrom(msg.sender, address(this), deposit1.div(10**18));
        IERC20(tokenAddress2).transferFrom(recipient, address(this), deposit2.div(10**18));

        // [2nd Step]: Transfer exchanged money from contract address to address of each other.
        IERC20(tokenAddress1).transferFrom(address(this), recipient, deposit1.div(10**18));
        IERC20(tokenAddress2).transferFrom(address(this), msg.sender, deposit2.div(10**18));


        /* Increment the next stream id. */
        (vars.mathErr, nextStreamedSwapId) = addUInt(nextStreamedSwapId, uint256(1));

        emit CreateStreamedSwap(streamedSwapId, 
                                msg.sender, 
                                recipient, 
                                deposit1,
                                deposit2, 
                                tokenAddress1, 
                                tokenAddress2, 
                                startTime, 
                                stopTime);

        return streamedSwapId;
    }


    /*** View Functions ***/

    /**
     * @notice Returns the compounding stream with all its properties.
     * @dev Throws if the id does not point to a valid streamedSwap.
     * @param streamedSwapId The id of the stream to query.
     * @return The streamedSwap object.
     */
    function getStreamedSwap(uint256 streamedSwapId)
        external
        view
        //streamedSwapExists(streamedSwapId)
        returns (
            address sender,
            address recipient,
            uint256 deposit1,
            uint256 deposit2,
            address tokenAddress1,
            address tokenAddress2,
            uint256 startTime,
            uint256 stopTime,
            uint256 remainingBalance1,
            uint256 remainingBalance2,
            uint256 ratePerSecond
        )
    {
        sender = streamedSwaps[streamedSwapId].sender;
        recipient = streamedSwaps[streamedSwapId].recipient;
        deposit1 = streamedSwaps[streamedSwapId].deposit1;
        deposit2 = streamedSwaps[streamedSwapId].deposit2;
        tokenAddress1 = streamedSwaps[streamedSwapId].tokenAddress1;
        tokenAddress2 = streamedSwaps[streamedSwapId].tokenAddress2;
        startTime = streamedSwaps[streamedSwapId].startTime;
        stopTime = streamedSwaps[streamedSwapId].stopTime;
        remainingBalance1 = streamedSwaps[streamedSwapId].remainingBalance1;
        remainingBalance2 = streamedSwaps[streamedSwapId].remainingBalance2;
        ratePerSecond = streamedSwaps[streamedSwapId].ratePerSecond;
    }


    /***
     * @notice - This method is for streamed-compounding-swap
     ***/
    function createStreamedCompoundingSwap(
        address recipient,
        uint256 deposit,
        address tokenAddress,
        uint256 startTime,
        uint256 stopTime,
        uint256 senderSharePercentage,
        uint256 recipientSharePercentage
    ) external whenNotPaused returns (uint256) {
        require(cTokenManager.isCToken(tokenAddress), "cToken is not whitelisted");
        CreateStreamedCompoundingSwapLocalVars memory vars;

        /* Ensure that the interest shares sum up to 100%. */
        (vars.mathErr, vars.shareSum) = addUInt(senderSharePercentage, recipientSharePercentage);
        require(vars.mathErr == MathError.NO_ERROR, "share sum calculation error");
        require(vars.shareSum == 100, "shares do not sum up to 100");

        uint256 streamId = _createStreamedSwap(recipient, deposit, tokenAddress, startTime, stopTime);

        /*
         * `senderSharePercentage` and `recipientSharePercentage` will be stored as mantissas, so we scale them up
         * by one percent in Exp terms.
         */
        (vars.mathErr, vars.senderShareMantissa) = mulUInt(senderSharePercentage, onePercent);
        /*
         * `mulUInt` can only return MathError.INTEGER_OVERFLOW but we control `onePercent` and
         * we know `senderSharePercentage` is maximum 100.
         */
        assert(vars.mathErr == MathError.NO_ERROR);

        (vars.mathErr, vars.recipientShareMantissa) = mulUInt(recipientSharePercentage, onePercent);
        /*
         * `mulUInt` can only return MathError.INTEGER_OVERFLOW but we control `onePercent` and
         * we know `recipientSharePercentage` is maximum 100.
         */
        assert(vars.mathErr == MathError.NO_ERROR);


        /* Create and store the compounding stream vars. */
        uint256 exchangeRateCurrent = ICERC20(tokenAddress).exchangeRateCurrent();
        compoundingStreamsVars[streamId] = Types.CompoundingStreamVars({
            exchangeRateInitial: Exp({ mantissa: exchangeRateCurrent }),
            isEntity: true,
            recipientShare: Exp({ mantissa: vars.recipientShareMantissa }),
            senderShare: Exp({ mantissa: vars.senderShareMantissa })
        });

        emit CreateCompoundingStream(streamId, exchangeRateCurrent, senderSharePercentage, recipientSharePercentage);
        return streamId;
    }
}
