// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

contract Randomizer {
    
    // Initializing the state variable
    uint randNonce = 0;
    
    function NextRand() internal returns(uint8)
    {
        // increase nonce
        randNonce++;
        uint result = uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, randNonce)));
        return uint8(result);
    }
    
    // Defining a function to generate, up to the max.
    //This method is inclusive: The result will be between 0-max, so result may be max
    function NextRand(uint8 max) internal returns(uint8)
    {
        return NextRand() % (max + 1);
    }
    
    //Get a random number between a min and max value (inclusive)
    function NextRand(uint8 min, uint8 max) internal returns(uint8)
    {
        assert(max > min);
        
        //get a random number bewteen 0 and the delta, and add the min
        return NextRand(max - min) + min;
    }
}