pragma solidity ^0.5.11;
pragma experimental ABIEncoderV2;

// Sablier protocol
import "./sablier-protocol/protocol/contracts/Sablier.sol";

// Storage
import "./storage/SmStorage.sol";
import "./storage/SmConstants.sol";

import "@openzeppelin/contracts-ethereum-package/contracts/ownership/Ownable.sol";


contract PlatformRegistry is Ownable, SmStorage, SmConstants {

    Sablier public sablier;

    constructor(address _sablierContractAddress) public {
        sablier = Sablier(_sablierContractAddress);
    }

    function testFunc() public returns (bool) {
        return SmConstants.CONFIRMED;
    }

    function createSreamingMoney(
        address recipient, 
        uint256 deposit, 
        address tokenAddress, 
        uint256 startTime, 
        uint256 stopTime
    ) public returns (bool) {
        sablier.createStream(recipient, deposit, tokenAddress, startTime, stopTime);
    }

}
