// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "../MOSSAI_Roles_Cfg.sol";

contract MOSSAI_Island_NFG is
    ERC721,
    ERC721URIStorage,
    ERC721Burnable,
    Ownable
{
    uint256 private _nextTokenId;
    address public _MOSSAIRolesCfgAddress;

    mapping(uint256 => uint32) public _tokenSeed;
    mapping(uint32 => uint256) public _seedToken;
    mapping(uint32 => uint256[]) public _mintTokens;
    mapping(uint32 => string) public _locationTokenURI;
    mapping(uint32 => uint32) public _locationSeed;
    mapping(uint32 => uint32) public _seedLocation;

    constructor() ERC721("MOSSAI_Island_NFG", "MIN") {}

    function mint(address to, uint32 location) public returns (uint32) {
        require(
            MOSSAI_Roles_Cfg(_MOSSAIRolesCfgAddress).hasAdminRole(msg.sender),
            "not admin role"
        );

        string memory uri = _locationTokenURI[location];
        uint32 seed = _locationSeed[location];
        require(bytes(uri).length > 0, "location not exists");

        require(_seedToken[seed] == 0, "seed already exists");

        _nextTokenId++;
        _safeMint(to, _nextTokenId);
        _setTokenURI(_nextTokenId, uri);

        _tokenSeed[_nextTokenId] = seed;
        _seedToken[seed] = _nextTokenId;

        _mintTokens[seed].push(_nextTokenId);

        return seed;
    }

    function mintBySeed(address to, uint32 seed) public returns (uint256) {
        require(
            MOSSAI_Roles_Cfg(_MOSSAIRolesCfgAddress).hasAdminRole(msg.sender),
            "not admin role"
        );

        uint32 location = _seedLocation[seed];

        string memory uri = _locationTokenURI[location];
        require(bytes(uri).length > 0, "location not exists");

        require(_seedToken[seed] > 0, "seed not exists");

        _nextTokenId++;
        _safeMint(to, _nextTokenId);
        _setTokenURI(_nextTokenId, uri);

        _tokenSeed[_nextTokenId] = seed;
        _seedToken[seed] = _nextTokenId;

        _mintTokens[seed].push(_nextTokenId);

        return _nextTokenId;
    }

    function getSeedOwer(uint32 seed) public view returns (address) {
        uint256 tokenId = _seedToken[seed];
        require(tokenId > 0, "seed not exists");

        return ownerOf(tokenId);
    }

    function getToken(
        uint256 tokenId
    ) public view returns (uint32, string memory) {
        require(_exists(tokenId), "token not exists");

        uint32 seed = _tokenSeed[tokenId];
        string memory tokenURI = tokenURI(tokenId);

        return (seed, tokenURI);
    }

    function _burn(
        uint256 tokenId
    ) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(
        uint256 tokenId
    ) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC721, ERC721URIStorage) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function batchAddNFG(
        uint32[] memory seeds,
        string[] memory uris,
        uint32[] memory locations
    ) public {
        require(
            MOSSAI_Roles_Cfg(_MOSSAIRolesCfgAddress).hasAdminRole(msg.sender),
            "not admin role"
        );

        for (uint256 i = 0; i < seeds.length; i++) {
            _locationTokenURI[locations[i]] = uris[i];
            _locationSeed[locations[i]] = seeds[i];
            _seedLocation[seeds[i]] = locations[i];
        }
    }

    function getMintTokens(uint32 seed) public view returns (uint256[] memory) {
        return _mintTokens[seed];
    }

    function setMOSSAIRolesCfgAddress(
        address MOSSAIRolesCfgAddress
    ) public onlyOwner {
        _MOSSAIRolesCfgAddress = MOSSAIRolesCfgAddress;
    }
}
