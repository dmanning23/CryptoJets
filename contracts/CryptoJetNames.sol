// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "contracts/CryptoJetMint.sol";

contract CryptoJetNames is CryptoJetMint {
    
     /*
    Mapping of CryptoJet name to token.
    Used to enforce name uniqueness
    */
    mapping (string => uint256) public cryptoJetNameToToken;
    
    //Mapping of token to name
    mapping (uint256 => string) public cryptoJetTokenToName;
    
    event CryptoJetNamed(uint256 tokenId, string name);
    
    function NameCryptoJet(uint256 tokenId, string memory name) external onlyOwnerOf(tokenId) {
        
        //check the max length of the name
        require (bytes(name).length > 0 && bytes(name).length <= 64);
        
        //check that the cryptojet doesn't already have a name
        require (bytes(cryptoJetTokenToName[tokenId]).length == 0);
        
        //check that the name isn't already taken
        require (cryptoJetNameToToken[name] == 0);
        
        //Only hatched cryptojets can be named
        require (cryptoJets[tokenId].hasHatched);
        
        //set the name of the cryptojet
        cryptoJetTokenToName[tokenId] = name;
        
        //point the name to the cryptojet
        cryptoJetNameToToken[name] = tokenId;
        
        emit CryptoJetNamed(tokenId, name);
    }
    
    //If someone names a CrpyotJet something naughty, the dev can go in and nuke the name.
    function RenameCryptoJet(uint256 tokenId, string memory name) external onlyOwner {
        
        //check the max length of the name
        require (bytes(name).length >= 0 && bytes(name).length <= 64);
        
        //set the name of the cryptojet
        cryptoJetTokenToName[tokenId] = name;
        
        //point the name to the cryptojet
        cryptoJetNameToToken[name] = tokenId;
        
        emit CryptoJetNamed(tokenId, name);
    }
}