// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "contracts/CryptoJetERC721.sol";
import "contracts/CryptoJetStorage.sol";

contract CryptoJetFactory is CryptoJetERC721, CryptoJetStorage  {
    
    modifier onlyOwnerOf(uint tokenId) {
        require(msg.sender == ownerOf(tokenId));
        _;
    }
    
    bool initialized = false;
    
    event CryptoJetsCombined(uint256 tokenId);
    
    event CryptoJetHatched(uint256 tokenId);
    
    constructor() CryptoJetERC721() CryptoJetStorage() {
    }
    
    function Init() external onlyOwner {
        require(initialized == false);
        
        //TODO: create genesis CryptoJet
        
        //TODO: event?
        
        //TODO: name genesis cryptojet
        
        
        //TODO: create nemesis CryptoJet
        
        //TODO: event?
        
        //TODO: name nemesis cryptojet
        
        initialized = true;
    }
    
    function _createGen0(address sender) internal returns(uint256) {

        //create the CryptoJet
        CryptoJet memory cryptoJet = CryptoJet(
            0, //generation
            3, //numCoresRemaining
            block.timestamp, //readyTime,
            0, //firstParentTokenId
            0, //secondParentTokenId
            Gen0Genes(), //dna for this cryptojet
            true //isHatched
        );
        
        //Create the cryptojet token
        uint256 tokenId = StoreCryptoJet(cryptoJet);
        
        //mint the token
        _safeMint(sender, tokenId);
        
        return tokenId;
    }
    
    function CombineCryptoJets(
        uint256 firstTokenId, 
        uint256 secondTokenId
    ) 
        onlyOwnerOf(firstTokenId) 
        onlyOwnerOf(secondTokenId) 
        external
    {
        //Make sure the cryptoJets have enough cores
        require(cryptoJets[firstTokenId].numCoresRemaining > 0);
        require(cryptoJets[secondTokenId].numCoresRemaining > 0);
        require(cryptoJets[firstTokenId].hasHatched);
        require(cryptoJets[secondTokenId].hasHatched);
        
        //Decrement the number of cores
        cryptoJets[firstTokenId].numCoresRemaining = cryptoJets[firstTokenId].numCoresRemaining - 1;
        cryptoJets[secondTokenId].numCoresRemaining = cryptoJets[secondTokenId].numCoresRemaining - 1;
        
        //Get the generation of the new cryptojet
        uint8 generation = cryptoJets[firstTokenId].generation + 1;
        if (cryptoJets[firstTokenId].generation > cryptoJets[secondTokenId].generation) {
            cryptoJets[secondTokenId].generation + 1;
        }
        
        //create the CryptoJet
        CryptoJet memory cryptoJet = CryptoJet(
            generation, //generation
            3, //numCoresRemaining
            block.timestamp + (2**generation * 1 days), //readyTime,
            firstTokenId, //firstParentTokenId
            secondTokenId, //secondParentTokenId
            BlankGenes(), //The dna for this cryptojet will be generated when it is hatched
            false //isHatched
        );
        
        //Create the cryptojet token
        uint256 tokenId = StoreCryptoJet(cryptoJet);
        
        //mint the token
        _safeMint(msg.sender, tokenId);
        
        emit CryptoJetsCombined(tokenId);
    }
    
    function HatchCryptoJet(uint256 tokenId) external onlyOwnerOf(tokenId) {
        
        require(!cryptoJets[tokenId].hasHatched);
        require(cryptoJets[tokenId].readyTime <= uint(block.timestamp));
        
        //set the cryptojet to hatched
        cryptoJets[tokenId].hasHatched = true;
        
        //Get the parent cryptoJets
        CryptoJet storage firstParent = cryptoJets[cryptoJets[tokenId].firstParentTokenId];
        CryptoJet storage secondParent = cryptoJets[cryptoJets[tokenId].secondParentTokenId];
        
        //set the genes of the cryptojet
        cryptoJets[tokenId].dna = CombineGenes(firstParent.dna, secondParent.dna);
        
        emit CryptoJetHatched(tokenId);
    }
}
