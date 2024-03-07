// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

import "../Hyperdust_Roles_Cfg.sol";
import "../MOSSAI_Storage.sol";
import "../token/MOSSAI_721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract MOSSAI_Island_NFG is OwnableUpgradeable {
    address public _MOSSAIRolesCfgAddress;
    address public _MOSSAIStorageAddress;
    address public _IslandNFTAddress;

    function initialize(address onlyOwner) public initializer {
        __Ownable_init(onlyOwner);
    }

    function mint(address to, uint32 location) public returns (uint256) {
        require(
            Hyperdust_Roles_Cfg(_MOSSAIRolesCfgAddress).hasAdminRole(
                msg.sender
            ),
            "not admin role"
        );

        MOSSAI_721 mossai721 = MOSSAI_721(_IslandNFTAddress);

        MOSSAI_Storage mossaiStorage = MOSSAI_Storage(_MOSSAIStorageAddress);

        string memory uri = mossaiStorage.getString(
            mossaiStorage.genKey("tokenURI", location)
        );
        require(bytes(uri).length > 0, "location not exists");

        uint256 seed = mossaiStorage.getUint(
            mossaiStorage.genKey("seed", location)
        );

        uint256 mintTokenId = mossaiStorage.getUint(
            mossaiStorage.genKey("seedToken", seed)
        );
        require(mintTokenId == 0, "seed already exists");

        uint256 tokenId = mossai721.safeMint(to, uri);

        mossaiStorage.setUint(mossaiStorage.genKey("tokenSeed", tokenId), seed);
        mossaiStorage.setUint(mossaiStorage.genKey("seedToken", seed), tokenId);

        mossaiStorage.setUintArray(
            mossaiStorage.genKey("mintTokens", seed),
            tokenId
        );

        return seed;
    }

    function mintBySeed(address to, uint256 seed) public returns (uint256) {
        require(
            Hyperdust_Roles_Cfg(_MOSSAIRolesCfgAddress).hasAdminRole(
                msg.sender
            ),
            "not admin role"
        );

        MOSSAI_721 mossai721 = MOSSAI_721(_IslandNFTAddress);

        MOSSAI_Storage mossaiStorage = MOSSAI_Storage(_MOSSAIStorageAddress);

        uint256 location = mossaiStorage.getUint(
            mossaiStorage.genKey("location", seed)
        );

        uint256 mintTokenId = mossaiStorage.getUint(
            mossaiStorage.genKey("seedToken", seed)
        );

        require(mintTokenId > 0, "seed not exists");

        string memory uri = mossaiStorage.getString(
            mossaiStorage.genKey("tokenURI", location)
        );

        require(bytes(uri).length > 0, "location not exists");

        uint256 tokenId = mossai721.safeMint(to, uri);

        mossaiStorage.setUint(mossaiStorage.genKey("tokenSeed", tokenId), seed);
        mossaiStorage.setUint(mossaiStorage.genKey("seedToken", seed), tokenId);

        mossaiStorage.setUintArray(
            mossaiStorage.genKey("mintTokens", seed),
            tokenId
        );

        return tokenId;
    }

    function getSeedOwer(uint256 seed) public view returns (address) {
        MOSSAI_Storage mossaiStorage = MOSSAI_Storage(_MOSSAIStorageAddress);

        uint256 tokenId = mossaiStorage.getUint(
            mossaiStorage.genKey("seedToken", seed)
        );

        require(tokenId > 0, "seed not exists");

        return IERC721(_IslandNFTAddress).ownerOf(tokenId);
    }

    function batchAddNFG(
        uint32[] memory seeds,
        string[] memory uris,
        uint32[] memory locations
    ) public {
        require(
            Hyperdust_Roles_Cfg(_MOSSAIRolesCfgAddress).hasAdminRole(
                msg.sender
            ),
            "not admin role"
        );

        MOSSAI_Storage mossaiStorage = MOSSAI_Storage(_MOSSAIStorageAddress);

        for (uint256 i = 0; i < seeds.length; i++) {
            mossaiStorage.setString(
                mossaiStorage.genKey("tokenURI", locations[i]),
                uris[i]
            );
            mossaiStorage.setUint(
                mossaiStorage.genKey("seed", locations[i]),
                seeds[i]
            );

            mossaiStorage.setUint(
                mossaiStorage.genKey("location", seeds[i]),
                locations[i]
            );
        }
    }

    function getMintTokens(
        uint256 seed
    ) public view returns (uint256[] memory) {
        MOSSAI_Storage mossaiStorage = MOSSAI_Storage(_MOSSAIStorageAddress);

        return
            mossaiStorage.getUintArray(
                mossaiStorage.genKey("mintTokens", seed)
            );
    }

    function setMOSSAIRolesCfgAddress(
        address MOSSAIRolesCfgAddress
    ) public onlyOwner {
        _MOSSAIRolesCfgAddress = MOSSAIRolesCfgAddress;
    }

    function setMOSSAIStorageAddress(
        address MOSSAIStorageAddress
    ) public onlyOwner {
        _MOSSAIStorageAddress = MOSSAIStorageAddress;
    }

    function setIslandNFTAddress(address IslandNFTAddress) public onlyOwner {
        _IslandNFTAddress = IslandNFTAddress;
    }

    function setContractAddress(
        address[] memory contractaddressArray
    ) public onlyOwner {
        _MOSSAIRolesCfgAddress = contractaddressArray[0];
        _MOSSAIStorageAddress = contractaddressArray[1];
        _IslandNFTAddress = contractaddressArray[2];
    }

    function getSeed(uint256 tokenId) public view returns (uint32) {
        MOSSAI_Storage mossaiStorage = MOSSAI_Storage(_MOSSAIStorageAddress);

        uint256 seed = mossaiStorage.getUint(
            mossaiStorage.genKey("tokenSeed", tokenId)
        );

        return uint32(seed);
    }
}
