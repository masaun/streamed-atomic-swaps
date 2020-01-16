pragma solidity ^0.5.11;

import "@openzeppelin/contracts-ethereum-package/contracts/ownership/Ownable.sol";

import "./SmObjects.sol";
import "./SmEvents.sol";


// shared storage
contract SmStorage is SmObjects, SmEvents, Ownable {

    //mapping (uint => ExampleObject) examples;

}

