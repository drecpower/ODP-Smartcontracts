// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/utils/Counters.sol";


contract ODPStore is ERC721Enumerable, Ownable {
    using Strings for uint256;
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    //Prices in NATIVE CURRENCY (ETH/MATIC/BNB)
    uint256 public currentCreatePrice = 10000000000000000;
    uint256 public currentUpdatePrice = 10000000000000000;
    uint256 public currentChangeCodeNamePrice = 10000000000000000;

    address public foundationPublicWallet;
    
    string appBaseUri;
    string contractMetaData;

    mapping(string => uint256) public codeName_to_tokenId;
    mapping(uint256 => string) public tokenId_to_hashCustomerApp;
    mapping(uint256 => string) public tokenId_to_codeName;

    constructor(
        string memory _appBaseUri,
        string memory _contractMetaData,
        address foundationWallet
    ) ERC721("ODP Store Token", "ODPST") {
        appBaseUri = _appBaseUri;
        contractMetaData = _contractMetaData;
        foundationPublicWallet = foundationWallet;
    }

    function updateCurrentCreatePrice(uint256 newPrice) public onlyOwner {
        currentCreatePrice = newPrice;
    }

    function updateCurrentUpdatePrice(uint256 newPrice) public onlyOwner {
        currentUpdatePrice = newPrice;
    }

    function updateCurrentChangeCodeNamePrice(uint256 newPrice) public onlyOwner {
        currentChangeCodeNamePrice = newPrice;
    }

    function updateBaseUri(string memory newBaseUri) public onlyOwner {
        appBaseUri = newBaseUri;
    }

    function updateContractMetaUri(string memory newUri) public onlyOwner {
        contractMetaData = newUri;
    }

    

    function updateTokenCodename(string memory codename,uint256 tokenId) public {
        require(codeName_to_tokenId[codename] == 0, "Code name is not available");
        require(msg.sender == ownerOf(tokenId));
        string memory lastCodename=tokenId_to_codeName[tokenId];
        codeName_to_tokenId[codename]=tokenId;
        codeName_to_tokenId[lastCodename]=0;
        tokenId_to_codeName[tokenId]=codename;
        payable(foundationPublicWallet).transfer(currentChangeCodeNamePrice);
    }

    function updateTokenURI(string memory newUri,uint256 tokenId) public {
        require(msg.sender == ownerOf(tokenId));
        tokenId_to_hashCustomerApp[tokenId]=newUri;
        payable(foundationPublicWallet).transfer(currentChangeCodeNamePrice);
    }

    function transfer(address to, uint256 amount) public onlyOwner {
        payable(to).transfer(amount);
    }

    function burn(uint256 tokenId) public {
        require(msg.sender == ownerOf(tokenId));
        _burn(tokenId);
    }
    

    function createNewStore(string memory codename, string memory ipfs_app)
        public
        payable
        returns (uint256)
    {
        require(msg.value > currentCreatePrice,"Value is less than currentCreatePrice");
        require(codeName_to_tokenId[codename] == 0, "Code name is not available");

        uint256 tokenId = _tokenIds.current()+1;
        _safeMint(msg.sender, tokenId);
        payable(foundationPublicWallet).transfer(currentCreatePrice);
        _tokenIds.increment();

        codeName_to_tokenId[codename] = tokenId;
        tokenId_to_codeName[tokenId] = codename;

        tokenId_to_hashCustomerApp[tokenId] = ipfs_app;
        
        
        return tokenId;
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override
        
        returns (string memory)
    {
        
        return
            string(
                abi.encodePacked(
                    appBaseUri,
                    tokenId_to_hashCustomerApp[tokenId]
                )
            );
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return appBaseUri;
    }

    function contractURI() public view returns (string memory) {
        return contractMetaData;
    }
}
