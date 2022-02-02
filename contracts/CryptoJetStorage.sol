// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "contracts/Randomizer.sol";

contract CryptoJetStorage is Randomizer{
    
    enum Gene {
        COCKPIT,
        LEG,
		ARM,
		LAUNCHER,
		HEAD,
		WINGS,
		BULLETSHAPE,
		BULLETSIZE,
		GUNSTOCK,
		GUNBARREL,
		MISSILEBODY,
		MISSILESIZE,
		NUMMISSILE,
		MISSILEDAMAGE
		//NUM_GENES //There is probably a way to use this number as an array size, but solidity just doesn't want to do it :(
    }
    
    //This is the size of the Gene enumeration. I haven't been able to figure out how else to do this in Solidity :P
    uint constant numGenes = 14;
    
    /*
    This is the main CryptoJet object.
    It contains all the information for a single CryptoJet.
    */
    struct CryptoJet {
        
        /*
        This is the generation of the cryptojet.
        Generation starts at 0 and is incremented in each child crytojet.
        This affects the hatch time of new cryptojets.
        */
        uint8 generation;
        
        /*
        This is the number of cores this CryptoJet has remaining.
        CryptoJets start with 5 cores and the number is decremented every time it is combined.
        Once this number hits 0 the cryptojet cannot be combined anymore.
        */
        uint8 numCoresRemaining;
        
        /*
        This is the date/time that this cryptojet will hatch.
        The DNA is hidden and the cryptojet cannot be used until it has hatched.
        */
        uint256 readyTime;
        
        uint256 firstParentTokenId;
        
        uint256 secondParentTokenId;
        
        uint8[numGenes] dna;
        
        bool hasHatched;
    }
    
    //List of all the CryptoJet objects
    CryptoJet[] public cryptoJets;
    
    function StoreCryptoJet(CryptoJet memory cryptoJet) internal returns(uint256) {
        
        cryptoJets.push(cryptoJet);
        return cryptoJets.length - 1;
    }
    
    function Gen0Genes() internal returns (uint8[numGenes] memory) {
         return [
            NextRand(6, 13), //cockpitGene
            NextRand(6, 13), //legGene
    		NextRand(6, 13), //armGene
    		NextRand(6, 13), //launcherGene
    		NextRand(6, 13), //headGene
    		NextRand(6, 13), //wingsGene
    		NextRand(6, 13), //bulletShapeGene
    		NextRand(6, 13), //bulletSizeGene
    		NextRand(6, 13), //gunStockGene
    		NextRand(6, 13), //gunBarrelGene
    		NextRand(6, 13), //missileBodyGene
    		NextRand(6, 13), //missileSizeGene
    		NextRand(6, 13), //numMissileGene
    		NextRand(6, 13) //missileDamageGene
        ];
    }
    
    function BlankGenes() internal pure returns (uint8[numGenes] memory) {
         return [
            0, //cockpitGene
            0, //legGene
    		0, //armGene
    		0, //launcherGene
    		0, //headGene
    		0, //wingsGene
    		0, //bulletShapeGene
    		0, //bulletSizeGene
    		0, //gunStockGene
    		0, //gunBarrelGene
    		0, //missileBodyGene
    		0, //missileSizeGene
    		0, //numMissileGene
    		0 //missileDamageGene
        ];
    }
    
    function CombineGenes(
        uint8[numGenes] storage firstGenes, 
        uint8[numGenes] storage secondGenes
    ) 
        internal
        returns (uint8[numGenes] memory) 
    {
         return [
            CombineGene(firstGenes[uint(Gene.COCKPIT)], secondGenes[uint(Gene.COCKPIT)]), //cockpitGene
            CombineGene(firstGenes[uint(Gene.LEG)], secondGenes[uint(Gene.LEG)]), //legGene
    		CombineGene(firstGenes[uint(Gene.ARM)], secondGenes[uint(Gene.ARM)]), //armGene
    		CombineGene(firstGenes[uint(Gene.LAUNCHER)], secondGenes[uint(Gene.LAUNCHER)]), //launcherGene
    		CombineGene(firstGenes[uint(Gene.HEAD)], secondGenes[uint(Gene.HEAD)]), //headGene
    		CombineGene(firstGenes[uint(Gene.WINGS)], secondGenes[uint(Gene.WINGS)]), //wingsGene
    		CombineGene(firstGenes[uint(Gene.BULLETSHAPE)], secondGenes[uint(Gene.BULLETSHAPE)]), //bulletShapeGene
    		CombineGene(firstGenes[uint(Gene.BULLETSIZE)], secondGenes[uint(Gene.BULLETSIZE)]), //bulletSizeGene
    		CombineGene(firstGenes[uint(Gene.GUNSTOCK)], secondGenes[uint(Gene.GUNSTOCK)]), //gunStockGene
    		CombineGene(firstGenes[uint(Gene.GUNBARREL)], secondGenes[uint(Gene.GUNBARREL)]), //gunBarrelGene
    		CombineGene(firstGenes[uint(Gene.MISSILEBODY)], secondGenes[uint(Gene.MISSILEBODY)]), //missileBodyGene
    		CombineGene(firstGenes[uint(Gene.MISSILESIZE)], secondGenes[uint(Gene.MISSILESIZE)]), //missileSizeGene
    		CombineGene(firstGenes[uint(Gene.NUMMISSILE)], secondGenes[uint(Gene.NUMMISSILE)]), //numMissileGene
    		CombineGene(firstGenes[uint(Gene.MISSILEDAMAGE)], secondGenes[uint(Gene.MISSILEDAMAGE)]) //missileDamageGene
        ];
    }
    
    //Given two genes, run the business logic to get the child gene
    function CombineGene(
        uint8 firstGene, 
        uint8 secondGene
    ) 
        internal
        returns (uint8) 
    {
        //are the genes adjacent?
        if (firstGene == secondGene + 1 || firstGene == secondGene - 1) {
        
            //are the genes the same tier?
            if (GeneTier(firstGene) == GeneTier(secondGene)) {
            
                //there is possibility of a mutation, get a random number between 0 and 2
                uint8 geneToUse = NextRand(2);
                
                if (0 == geneToUse) {
                    //0: inherit the gene from the first parent
                    return firstGene;
                } else if (1 == geneToUse){
                    //1: inherit the gene from the second parent
                    return secondGene;
                }
                else {
                    //2: MUTATE!!!
                    return MutationResult(firstGene, secondGene);
                }
            } else {
                //These two genes are adjacent, but different tiers. They can't mutate, so just choose one.
                return ChooseParentGene(firstGene, secondGene);
            }
        }
        else {
            return ChooseParentGene(firstGene, secondGene);
        }
    }
    
    function ChooseParentGene(
        uint8 firstGene, 
        uint8 secondGene
    ) 
        internal
        returns (uint8) 
    {
        //get a random number between 0 and 1
        uint8 geneToUse = NextRand(1);
        
        if (0 == geneToUse) {
            //0: inherit the gene from the first parent
            return firstGene;
        } else {
            //1: inherit the gene from the second parent
            return secondGene;
        }
    }
    
    //Find the tier of a gene. See the whitepapet for an explanation of this logic.
    function GeneTier(uint8 gene) internal pure returns (uint8) {
        
        if (gene >= 19) {
            return 7;
        }
		else if (gene >= 17) {
			return 6;
		}
		else if (gene >= 14) {
			return 5;
		}
		else if (gene >= 10) {
			return 4;
		}
		else if (gene >= 6) {
			return 3;
		}
		else if (gene >= 3) {
			return 2;
		}
		else if (gene >= 1) {
			return 1;
		}
		else {
			return 0;
		}
    }
    
    //Given 2 genes, calculate the mutation. See the whitepapet for an explanation of this logic.
    function MutationResult(uint8 gene1, uint8 gene2) internal pure returns (uint8) {
        uint8 tier = GeneTier(gene1);
        
        //which class of gene are they?
        if (tier == 1) {
            return 0;
        } else if (tier == 2) {
            if (gene1 < gene2) {
                return gene1 - 3;
            }
            else {
                return gene2 - 3;
            }
        } else if (tier == 3) {
            if (gene1 < gene2) {
                return gene1 - 2;
            }
            else {
                return gene2 - 2;
            }
        } else if (tier == 4) {
            if (gene1 < gene2) {
                return gene1 + 4;
            }
            else {
                return gene2 + 4;
            }
        } else if (tier == 5) {
            if (gene1 < gene2) {
                return gene1 + 3;
            }
            else {
                return gene2 + 3;
            }
        } else {
            return 19;
        }
    }
}