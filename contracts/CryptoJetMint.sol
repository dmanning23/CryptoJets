// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "contracts/CryptoJetFactory.sol";

contract CryptoJetMint is CryptoJetFactory {
    
    //The current number of Gen0 CryptoJets
    uint256 numGen0CryptoJets;
    
    //The total number of allowed Gen0 CryptoJets
    uint256 maxNumGen0CryptoJets;
    
    //Cost to mint a Gen0 CryptoJet, unless you are a sneaky-ass developer (see below) ;)
    uint256 gen0MintFee;
    
    /*
    The number of CryptoJets the developers have minted.
    Stored separately from the public pool so that I can mint a few for giveaway purposes or whatever.
    */
    uint256 numDeveloperGen0CryptoJets;
    
    //The maximum number of CryptoJets the developers are allowed to mint.
    uint256 maxNumDeveloperGen0CryptoJets = 1000;
    
    event Gen0Added(uint256 num, uint256 price);
    
    event Gen0CryptoJetMinted(uint256 tokenId);
    
    function AddGen0CryptoJets(uint256 num, uint256 price) external onlyOwner {

        //Set the price
        gen0MintFee = price;
        
        //Update the number of max gen0 CryptoJets
        maxNumGen0CryptoJets = maxNumGen0CryptoJets + num;
        
        emit Gen0Added(num, price);
    }
    
    function MintGen0CryptoJet() external payable {
        
        //better have my money!
        require(msg.value >= gen0MintFee);
        
        //Make sure the public can still mint Gen0 cryptojets
        require(numGen0CryptoJets < maxNumGen0CryptoJets);
        
        //increment the number of minted gen0 cryptojets
        numGen0CryptoJets = numGen0CryptoJets + 1;
        
        //create the CryptoJet and return its token Id
        uint256 tokenId = _createGen0(msg.sender);
        
        emit Gen0CryptoJetMinted(tokenId);
    }
    
    function NefariousMintGen0ForDeveloper() external onlyOwner {
        
        //Make sure the developer can still mint Gen0 cryptojets
        require(numDeveloperGen0CryptoJets < maxNumDeveloperGen0CryptoJets);
        
        //increment the number of minted gen0 cryptojets
        numDeveloperGen0CryptoJets = numDeveloperGen0CryptoJets + 1;
        
        //create the CryptoJet and return its token Id
        uint256 tokenId = _createGen0(msg.sender);
        
        emit Gen0CryptoJetMinted(tokenId);
    }
}
    