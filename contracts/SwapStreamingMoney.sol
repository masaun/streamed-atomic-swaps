pragma solidity ^0.5.11;
pragma experimental ABIEncoderV2;

// Sablier protocol
import "./sablier-protocol/protocol/contracts/Sablier.sol";

// Storage
import "./storage/SmStorage.sol";
import "./storage/SmConstants.sol";

import "@openzeppelin/contracts-ethereum-package/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts-ethereum-package/contracts/ownership/Ownable.sol";


contract SwapStreamingMoney is Ownable, SmStorage, SmConstants {

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
    function createSwapStream(
        address recipient, 
        uint256 deposit, 
        address tokenAddress1,
        address tokenAddress2, 
        uint256 startTime, 
        uint256 stopTime
    ) public returns (bool) {
        IERC20 token1 = IERC20(0xaD6D458402F60fD3Bd25163575031ACDce07538D); // get a handle for the token contract（DAI on ropsten）
        token1.approve(address(sablier), deposit); // approve the transfer

        IERC20 token2 = IERC20(0xaD6D458402F60fD3Bd25163575031ACDce07538D); // get a handle for the token contract（DAI on ropsten）
        token2.approve(address(sablier), deposit); // approve the transfer

        // the stream id is needed later to withdraw from or cancel the stream
        uint256 streamId = sablier.createStream(recipient, deposit, address(token1), startTime, stopTime);
    }
    
    
}
