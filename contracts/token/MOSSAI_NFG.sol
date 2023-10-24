// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "../MOSSAI_Roles_Cfg.sol";

contract MOSSAI_NFG is ERC721, ERC721URIStorage, ERC721Burnable, Ownable {
    uint256 private _nextTokenId;
    address public _MOSSAIRolesCfgAddress;

    struct NFG {
        uint32 seed;
        string tokenURI;
    }

    NFG[] public _NFGs;
    mapping(uint32 => bool) _seeds;
    mapping(uint256 => uint32) _tokenSeed;
    mapping(uint32 => uint256) _seedToken;
    mapping(uint32 => uint256[]) _mintTokens;

    constructor(
        string memory name_,
        string memory symbol_
    ) ERC721(name_, symbol_) {}

    function mint(address to) public returns (uint32) {
        require(
            MOSSAI_Roles_Cfg(_MOSSAIRolesCfgAddress).hasAdminRole(msg.sender),
            "not admin role"
        );

        require(_NFGs.length > 0, "NFGs is empty");

        NFG memory nfg = _NFGs[0];

        require(_seedToken[nfg.seed] == 0, "seed already exists");

        uint256 tokenId = _nextTokenId++;
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, nfg.tokenURI);

        _tokenSeed[tokenId] = nfg.seed;
        _seedToken[nfg.seed] = tokenId;

        _mintTokens[nfg.seed].push(tokenId);

        deleteNFG(nfg.seed);

        return nfg.seed;
    }

    function mintBySeed(address to, uint32 seed) public returns (uint256) {
        require(
            MOSSAI_Roles_Cfg(_MOSSAIRolesCfgAddress).hasAdminRole(msg.sender),
            "not admin role"
        );

        require(_NFGs.length > 0, "NFGs is empty");

        require(_seedToken[seed] > 0, "seed not exists");

        NFG memory nfg = getNFG(seed);

        uint256 tokenId = _nextTokenId++;
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, nfg.tokenURI);

        _tokenSeed[tokenId] = seed;
        _seedToken[seed] = tokenId;

        _mintTokens[seed].push(tokenId);

        deleteNFG(seed);

        return tokenId;
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

    function batchAddNFG(uint32[] memory seeds, string[] memory uris) public {
        require(
            MOSSAI_Roles_Cfg(_MOSSAIRolesCfgAddress).hasAdminRole(msg.sender),
            "not admin role"
        );

        for (uint256 i = 0; i < seeds.length; i++) {
            require(!_seeds[seeds[i]], "seed already exists");
            _seeds[seeds[i]] = true;
            _NFGs.push(NFG(seeds[i], uris[i]));
        }
    }

    function batchDeleteNFG(uint32[] memory seeds) public {
        require(
            MOSSAI_Roles_Cfg(_MOSSAIRolesCfgAddress).hasAdminRole(msg.sender),
            "not admin role"
        );

        for (uint i = 0; i < seeds.length; i++) {
            deleteNFG(seeds[i]);
        }
    }

    function deleteNFG(uint32 seed) private {
        for (uint i = 0; i < _NFGs.length; i++) {
            if (_NFGs[i].seed == seed) {
                _NFGs[i] = _NFGs[_NFGs.length - 1];
                _NFGs.pop();
                _seeds[seed] = false;
                return;
            }
        }

        revert("seed not found");
    }

    function getNFG(uint32 seed) public view returns (NFG memory) {
        for (uint i = 0; i < _NFGs.length; i++) {
            if (_NFGs[i].seed == seed) {
                return _NFGs[i];
            }
        }

        revert("seed not found");
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
