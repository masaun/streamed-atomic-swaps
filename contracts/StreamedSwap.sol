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
    ) public returns (bool) {
        IERC20 token1 = IERC20(0xaD6D458402F60fD3Bd25163575031ACDce07538D); // get a handle for the token contract（DAI on ropsten）
        token1.approve(address(sablier), deposit); // approve the transfer

        IERC20 token2 = IERC20(0xDb0040451F373949A4Be60dcd7b6B8D6E42658B6); // get a handle for the token contract（BAT on ropsten）
        token2.approve(address(sablier), deposit); // approve the transfer

        // the stream id is needed later to withdraw from or cancel the stream
        uint256 streamedSwapId = createStreamedSwap(recipient, deposit, address(token1), address(token2), startTime, stopTime);
    }
    

    /**
     * @notice Creates a new stream funded by `msg.sender` and paid towards `recipient`.
     * @dev Throws if paused.
     *  Throws if the recipient is the zero address, the contract itself or the caller.
     *  Throws if the deposit is 0.
     *  Throws if the start time is before `block.timestamp`.
     *  Throws if the stop time is before the start time.
     *  Throws if the duration calculation has a math error.
     *  Throws if the deposit is smaller than the duration.
     *  Throws if the deposit is not a multiple of the duration.
     *  Throws if the rate calculation has a math error.
     *  Throws if the next stream id calculation has a math error.
     *  Throws if the contract is not allowed to transfer enough tokens.
     *  Throws if there is a token transfer failure.
     * @param recipient The address towards which the money is streamed.
     * @param deposit The amount of money to be streamed.
     * @param tokenAddress The ERC20 token to use as streaming currency.
     * @param startTime The unix timestamp for when the stream starts.
     * @param stopTime The unix timestamp for when the stream stops.
     * @return The uint256 id of the newly created stream.
     */
    function createStreamedSwap(
        address recipient, 
        uint256 deposit, 
        address tokenAddress1, 
        address tokenAddress2, 
        uint256 startTime, 
        uint256 stopTime
    )
        public
        //whenNotPaused
        returns (uint256)
    {
        require(recipient != address(0x00), "stream to the zero address");
        require(recipient != address(this), "stream to the contract itself");
        require(recipient != msg.sender, "stream to the caller");
        require(deposit > 0, "deposit is zero");
        require(startTime >= block.timestamp, "start time before block.timestamp");
        require(stopTime > startTime, "stop time before the start time");

        CreateStreamedSwapLocalVars memory vars;
        (vars.mathErr, vars.duration) = subUInt(stopTime, startTime);
        /* `subUInt` can only return MathError.INTEGER_UNDERFLOW but we know `stopTime` is higher than `startTime`. */
        //assert(vars.mathErr == MathError.NO_ERROR);

        /* Without this, the rate per second would be zero. */
        //require(deposit >= vars.duration, "deposit smaller than time delta");

        /* This condition avoids dealing with remainders */
        //require(deposit % vars.duration == 0, "deposit not multiple of time delta");

        (vars.mathErr, vars.ratePerSecond) = divUInt(deposit, vars.duration);
        /* `divUInt` can only return MathError.DIVISION_BY_ZERO but we know `duration` is not zero. */
        //assert(vars.mathErr == MathError.NO_ERROR);

        /* Create and store the swap stream object. */
        uint256 streamedSwapId = nextStreamedSwapId;
        streamedSwaps[streamedSwapId] = SmObjects.StreamedSwap({
            remainingBalance: deposit,
            deposit: deposit,
            isEntity: true,
            ratePerSecond: vars.ratePerSecond,
            recipient: recipient,
            sender: msg.sender,
            tokenAddress1: tokenAddress1,  // Token Address 1
            tokenAddress2: tokenAddress2,  // Token Address 2
            startTime: startTime,
            stopTime: stopTime
        });

        /* Swap (Transfer) streaming money */
        IERC20(tokenAddress1).transferFrom(msg.sender, address(this), deposit);
        IERC20(tokenAddress2).transferFrom(recipient, address(this), deposit);


        /* Increment the next stream id. */
        (vars.mathErr, nextStreamedSwapId) = addUInt(nextStreamedSwapId, uint256(1));
        //require(vars.mathErr == MathError.NO_ERROR, "next stream id calculation error");

        //require(IERC20(tokenAddress).transferFrom(msg.sender, address(this), deposit), "token transfer failure");
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
