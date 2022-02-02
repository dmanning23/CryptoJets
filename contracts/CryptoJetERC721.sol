// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts@4.3.2/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts@4.3.2/access/Ownable.sol";

contract CryptoJetERC721 is ERC721Enumerable, Ownable {
    constructor() ERC721("CryptoJet", "CRPTJT") Ownable() {}

    function _baseURI() internal pure override returns (string memory) {
        return "https://cryptojets.io";
    }
    
    //TODO: get paid for erc721 transfers?
    
    //TODO: withdraw funds?
}
