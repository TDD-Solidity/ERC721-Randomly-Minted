//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";

    // SPDX-License-Identifier: GPL-3.0

// Amended by HashLips
/**
    !Disclaimer!
    These contracts have been used to create tutorials,
    and was created for the purpose to teach people
    how to create smart contracts on the blockchain.
    please review this code on your own before using any of
    the following code for production.
    HashLips will not be liable in any way if for the use 
    of the code. That being said, the code has been tested 
    to the best of the developers' knowledge to work as intended.
*/

// pragma solidity >=0.7.0 <0.9.0;

contract RandomlyMintedNFT is VRFConsumerBase, ERC721Enumerable, Ownable {
  
  using Strings for uint256;

  string public baseURI;
  string public baseExtension = ".json";
  uint256 public cost = 0.05 ether;
  uint256 public maxSupply = 10;
  uint256 public maxMintAmount = 20;
  bool public paused = false;

    address mainnetLinkAddress = 0xb0897686c545045aFc77CF20eC7A532E3120E0F1;
    address testnetLinkAddress = 0x326C977E6efc84E512bB9C30f76E30c160eD06FB;

    address mainnetVrfCoordinator = 0x3d2341ADb2D31f1c5530cDC622016af293177AE0;
    address testnetVrfCoordinator = 0x8C7382F9D8f56b33781fE506E897a4F1e2d17255;

    bytes32 mainnetOracleKeyHash =
        0xf86195cf7690c55907b2b611ebb7343a6f649bff128701cc542f0569e2c549da;

    bytes32 testnetOracleKeyHash =
        0x6e75b569a01ef56d18cab6a8e71e6600d6ce853834d4a5748b720d06f878b3a4;

    uint256 MUMBAI_TESTNET_CHAINID = 80001;

    address __linkTokenAddress =
        getChainId() == MUMBAI_TESTNET_CHAINID
            ? testnetLinkAddress
            : mainnetLinkAddress;

    address __vrfCoordinatorAddress =
        getChainId() == MUMBAI_TESTNET_CHAINID
            ? testnetVrfCoordinator
            : mainnetVrfCoordinator;

    bytes32 __oracleKeyhash =
        getChainId() == MUMBAI_TESTNET_CHAINID
            ? testnetOracleKeyHash
            : mainnetOracleKeyHash;

  uint256[] public availableTokenIds;

  mapping(bytes32 => address) requestId_to_requester;

  constructor (
    string memory _name,
    string memory _symbol,
    string memory _initBaseURI
  ) public
    ERC721(_name, _symbol) 
    VRFConsumerBase(__vrfCoordinatorAddress, __linkTokenAddress);
    {
        setBaseURI(_initBaseURI);

        for (uint256 i = 0; i < maxSupply; i++) {
          availableTokenIds.push(i+1);
        }
    }

  // public
  function mint(address _to) public payable {
    require(!paused);

    uint256 supply = totalSupply();
    uint256 _mintAmount = 1;
    require(supply + _mintAmount <= maxSupply);

    require(msg.value == cost);

    bytes32 requestId = requestRandomness(keyHash, fee);

    requestId_to_requester[requestId] = _to;
  }

  function fulfillRandomness(bytes32 requestId, uint256 randomness)
        internal
        override
    {
        uint256 random_token_index = (randomness % maxSupply) + 1;

        uint256 random_token_id = availableTokenIds[random_token_index];

        _safeMint(requestId_to_requester[requestId], random_token_index);

        availableTokenIds[random_token_index] = availableTokenIds[availableTokenIds.length - 1];

        availableTokenIds.pop();

    }
  
  // internal
  function _baseURI() internal view virtual override returns (string memory) {
    return baseURI;
  }

  function walletOfOwner(address _owner)
    public
    view
    returns (uint256[] memory)
  {
    uint256 ownerTokenCount = balanceOf(_owner);
    uint256[] memory tokenIds = new uint256[](ownerTokenCount);
    for (uint256 i; i < ownerTokenCount; i++) {
      tokenIds[i] = tokenOfOwnerByIndex(_owner, i);
    }
    return tokenIds;
  }

  function tokenURI(uint256 tokenId)
    public
    view
    virtual
    override
    returns (string memory)
  {
    require(
      _exists(tokenId),
      "ERC721Metadata: URI query for nonexistent token"
    );

    string memory currentBaseURI = _baseURI();
    return bytes(currentBaseURI).length > 0
        ? string(abi.encodePacked(currentBaseURI, tokenId.toString(), baseExtension))
        : "";
  }

  //only owner
  function setCost(uint256 _newCost) public onlyOwner {
    cost = _newCost;
  }

  function setmaxMintAmount(uint256 _newmaxMintAmount) public onlyOwner {
    maxMintAmount = _newmaxMintAmount;
  }

  function setBaseURI(string memory _newBaseURI) public onlyOwner {
    baseURI = _newBaseURI;
  }

  function setBaseExtension(string memory _newBaseExtension) public onlyOwner {
    baseExtension = _newBaseExtension;
  }

  function pause(bool _state) public onlyOwner {
    paused = _state;
  }

  function withdraw() public payable onlyOwner {
    // This will pay HashLips 5% of the initial sale.
    // You can remove this if you want, or keep it in to support HashLips and his channel.
    // =============================================================================
    (bool hs, ) = payable(0x943590A42C27D08e3744202c4Ae5eD55c2dE240D).call{value: address(this).balance * 5 / 100}("");
    require(hs);
    // =============================================================================
    
    // This will payout the owner 95% of the contract balance.
    // Do not remove this otherwise you will not be able to withdraw the funds.
    // =============================================================================
    (bool os, ) = payable(owner()).call{value: address(this).balance}("");
    require(os);
    // =============================================================================
  }
}