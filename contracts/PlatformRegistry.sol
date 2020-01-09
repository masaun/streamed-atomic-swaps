pragma solidity ^0.5.11;
pragma experimental ABIEncoderV2;

// Storage
import "./storage/SmStorage.sol";
import "./storage/SmConstants.sol";

import "@openzeppelin/contracts-ethereum-package/contracts/ownership/Ownable.sol";


contract PlatformRegistry is Ownable, SmStorage, SmConstants {

    constructor() public {}

    function testFunc() public returns (bool) {
        return SmConstants.CONFIRMED;
    }

}
