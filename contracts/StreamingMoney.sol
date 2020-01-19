pragma solidity ^0.5.11;
pragma experimental ABIEncoderV2;

// Sablier protocol
import "./sablier-protocol/protocol/contracts/Sablier.sol";

// Storage
import "./storage/SmStorage.sol";
import "./storage/SmConstants.sol";

import "@openzeppelin/contracts-ethereum-package/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts-ethereum-package/contracts/ownership/Ownable.sol";


contract StreamingMoney is Ownable, SmStorage, SmConstants {

    Sablier public sablier;

    constructor(address _sablierContractAddress) public {
        sablier = Sablier(_sablierContractAddress);
    }

    function testFunc() public returns (bool) {
        return SmConstants.CONFIRMED;
    }

    function _createStream(
        address recipient, 
        uint256 deposit, 
        //address tokenAddress, 
        uint256 startTime, 
        uint256 stopTime
    ) public returns (bool) {
        //address recipient = 0x8Fc9d07b1B9542A71C4ba1702Cd230E160af6EB3;
        //uint256 deposit = 2999999999;                          // almost 3,000, but not quite
        //uint256 startTime = block.timestamp + 3600;            // 1 hour from now
        //uint256 stopTime = block.timestamp + 2592000 + 3600;   // 30 days and 1 hour from now

        //IERC20 token = IERC20(tokenAddress); // get a handle for the token contract（DAI on ropsten）
        //IERC20 token = IERC20(0x2D69aD895797C880abce92437788047BA0Eb7fF6); // get a handle for the token contract（TestDAI on ropsten）
        IERC20 token = IERC20(0xaD6D458402F60fD3Bd25163575031ACDce07538D); // get a handle for the token contract（DAI on ropsten）
        token.approve(address(sablier), deposit); // approve the transfer

        // the stream id is needed later to withdraw from or cancel the stream
        //uint256 streamId = sablier.createStream(recipient, deposit, tokenAddress, startTime, stopTime);
        uint256 streamId = sablier.createStream(recipient, deposit, address(token), startTime, stopTime);
    }


    function _getStream(uint256 streamId)
        public
        returns (
            address sender,
            address recipient,
            uint256 deposit,
            address tokenAddress,
            uint256 startTime,
            uint256 stopTime,
            uint256 remainingBalance,
            uint256 ratePerSecond
        )
    {
        return sablier.getStream(streamId);
    }
    

    function _balanceOf(uint256 streamId, address who) public returns (uint256 balance) {
        return sablier.balanceOf(streamId, who);
    }
    

    function _withdrawFromStream(uint256 streamId, uint256 amount) public returns (bool) {
        sablier.withdrawFromStream(streamId, amount);
    }
   
    
}
