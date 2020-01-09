pragma solidity ^0.5.11;

import "@openzeppelin/contracts-ethereum-package/contracts/ownership/Ownable.sol";


contract SmModifier is Ownable {

    // example
    modifier onlyStakingPerson(uint _time) { 
        require (now >= _time);
        _;
    }
    
}
