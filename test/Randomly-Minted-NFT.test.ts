import { expect } from "chai";
import { ethers } from "hardhat";

describe("Randomly-Minted-NFT", function () {

  let randomlyMintedNFT: any;

  beforeEach(async () => {
    
    const RandomlyMintedNFT = await ethers.getContractFactory("RandomlyMintedNFT");
    randomlyMintedNFT = await RandomlyMintedNFT.deploy('Name', 'RND');
    await randomlyMintedNFT.deployed();

  })

  describe('initialization', () => {

    xit('creates the availableTokenArray when deployed', () => {

    })

  })

  describe('minting', () => {

    const TOTAL_SUPPLY = 10;

    it('mints all NFTs with different tokenIds', () => {

      for(let i = 0; i < TOTAL_SUPPLY; i++) {

        // randomlyMintedNFT.mint()        

      }

    })

  })

});
