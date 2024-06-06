// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "../HyperAGI_Roles_Cfg.sol";
import "../MOSSAI_Storage.sol";
import "../token/MOSSAI_721.sol";

contract MOSSAI_Island_NFG is OwnableUpgradeable {
    address public _rolesCfgAddress;
    address public _storageAddress;
    address public _islandNFTAddress;

    function initialize(address onlyOwner) public initializer {
        __Ownable_init(onlyOwner);
    }

    function setRolesCfgAddress(address rolesCfgAddress) public onlyOwner {
        _rolesCfgAddress = rolesCfgAddress;
    }

    function setStorageAddress(address storageAddress) public onlyOwner {
        _storageAddress = storageAddress;
    }

    function setIslandNFTAddress(address islandNFTAddress) public onlyOwner {
        _islandNFTAddress = islandNFTAddress;
    }

    function setContractAddress(address[] memory contractaddressArray) public onlyOwner {
        require(contractaddressArray.length >= 3, "Insufficient addresses provided");
        setRolesCfgAddress(contractaddressArray[0]);
        setStorageAddress(contractaddressArray[1]);
        setIslandNFTAddress(contractaddressArray[2]);
    }

    function mint(address to, uint32 location) public returns (uint256) {
        require(IHyperAGI_Roles_Cfg(_rolesCfgAddress).hasAdminRole(msg.sender), "not admin role");

        MOSSAI_721 mossai721 = MOSSAI_721(_islandNFTAddress);

        MOSSAI_Storage storageAddress = MOSSAI_Storage(_storageAddress);

        string memory uri = storageAddress.getString(storageAddress.genKey("tokenURI", location));
        require(bytes(uri).length > 0, "location not exists");

        uint256 seed = storageAddress.getUint(storageAddress.genKey("seed", location));

        uint256 mintTokenId = storageAddress.getUint(storageAddress.genKey("seedToken", seed));
        require(mintTokenId == 0, "seed already exists");

        uint256 tokenId = mossai721.safeMint(to, uri);

        storageAddress.setUint(storageAddress.genKey("tokenSeed", tokenId), seed);
        storageAddress.setUint(storageAddress.genKey("seedToken", seed), tokenId);

        storageAddress.setUintArray(storageAddress.genKey("mintTokens", seed), tokenId);

        return seed;
    }

    function mintBySeed(address to, uint256 seed) public returns (uint256) {
        require(IHyperAGI_Roles_Cfg(_rolesCfgAddress).hasAdminRole(msg.sender), "not admin role");

        MOSSAI_721 mossai721 = MOSSAI_721(_islandNFTAddress);

        MOSSAI_Storage storageAddress = MOSSAI_Storage(_storageAddress);

        uint256 location = storageAddress.getUint(storageAddress.genKey("location", seed));

        uint256 mintTokenId = storageAddress.getUint(storageAddress.genKey("seedToken", seed));

        require(mintTokenId > 0, "seed not exists");

        string memory uri = storageAddress.getString(storageAddress.genKey("tokenURI", location));

        require(bytes(uri).length > 0, "location not exists");

        uint256 tokenId = mossai721.safeMint(to, uri);

        storageAddress.setUint(storageAddress.genKey("tokenSeed", tokenId), seed);
        storageAddress.setUint(storageAddress.genKey("seedToken", seed), tokenId);

        storageAddress.setUintArray(storageAddress.genKey("mintTokens", seed), tokenId);

        return tokenId;
    }

    function getSeedOwer(uint256 seed) public view returns (address) {
        MOSSAI_Storage storageAddress = MOSSAI_Storage(_storageAddress);

        uint256 tokenId = storageAddress.getUint(storageAddress.genKey("seedToken", seed));

        require(tokenId > 0, "seed not exists");

        return IERC721(_islandNFTAddress).ownerOf(tokenId);
    }

    function batchAddNFG(uint32[] memory seeds, string[] memory uris, uint32[] memory locations) public {
        require(IHyperAGI_Roles_Cfg(_rolesCfgAddress).hasAdminRole(msg.sender), "not admin role");

        MOSSAI_Storage storageAddress = MOSSAI_Storage(_storageAddress);

        for (uint256 i = 0; i < seeds.length; i++) {
            storageAddress.setString(storageAddress.genKey("tokenURI", locations[i]), uris[i]);
            storageAddress.setUint(storageAddress.genKey("seed", locations[i]), seeds[i]);

            storageAddress.setUint(storageAddress.genKey("location", seeds[i]), locations[i]);
        }
    }

    function getMintTokens(uint256 seed) public view returns (uint256[] memory) {
        MOSSAI_Storage storageAddress = MOSSAI_Storage(_storageAddress);

        return storageAddress.getUintArray(storageAddress.genKey("mintTokens", seed));
    }
}
