pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Strings.sol";

import "@openzeppelin/contracts/access/Ownable.sol";

import "@openzeppelin/contracts/utils/Counters.sol";

import "../utils/StrUtil.sol";
import "../MOSSAI_Roles_Cfg.sol";

contract MOSSAI_Island_Template is Ownable {
    address public _MOSSAIRolesCfgAddress;

    IslandTemplate[] public _islandTemplates;

    using Counters for Counters.Counter;
    Counters.Counter private _id;
    using Strings for *;
    using StrUtil for *;

    struct IslandTemplate {
        uint256 id;
        string name;
        string coverImage;
        string file;
        string fileHash;
    }

    event eveDeleteIslandTemplate(uint256 id);

    event eveSaveIslandTemplate(uint256 id);

    function setMOSSAIRolesCfgAddress(
        address MOSSAIRolesCfgAddress
    ) public onlyOwner {
        _MOSSAIRolesCfgAddress = MOSSAIRolesCfgAddress;
    }

    function add(
        string memory name,
        string memory coverImage,
        string memory file,
        string memory fileHash
    ) public {
        require(
            MOSSAI_Roles_Cfg(_MOSSAIRolesCfgAddress).hasAdminRole(msg.sender),
            "not admin role"
        );
        _id.increment();
        uint256 id = _id.current();
        _islandTemplates.push(
            IslandTemplate({
                id: id,
                name: name,
                coverImage: coverImage,
                file: file,
                fileHash: fileHash
            })
        );
        emit eveSaveIslandTemplate(id);
    }

    function update(
        uint256 id,
        string memory name,
        string memory coverImage,
        string memory file,
        uint256 spaceTypeId,
        string memory fileHash
    ) public {
        require(
            MOSSAI_Roles_Cfg(_MOSSAIRolesCfgAddress).hasAdminRole(msg.sender),
            "not admin role"
        );

        for (uint256 i = 0; i < _islandTemplates.length; i++) {
            if (_islandTemplates[i].id == id) {
                _islandTemplates[i].name = name;
                _islandTemplates[i].coverImage = coverImage;
                _islandTemplates[i].file = file;
                _islandTemplates[i].fileHash = fileHash;

                emit eveSaveIslandTemplate(id);
                return;
            }
        }
        revert("not found");
    }

    function deleteSpaceTemplate(uint256 id) public {
        require(
            MOSSAI_Roles_Cfg(_MOSSAIRolesCfgAddress).hasAdminRole(msg.sender),
            "not admin role"
        );

        uint256 index = 0;

        for (uint i = 0; i < _islandTemplates.length; i++) {
            if (_islandTemplates[i].id == id) {
                _islandTemplates[i] = _islandTemplates[
                    _islandTemplates.length - 1
                ];
                _islandTemplates.pop();
                emit eveDeleteIslandTemplate(id);
            }
        }

        revert("not found");
    }

    function getSpaceTemplate(
        uint256 id
    )
        public
        view
        returns (
            uint256,
            string memory,
            string memory,
            string memory,
            string memory
        )
    {
        for (uint256 i = 0; i < _islandTemplates.length; i++) {
            if (_islandTemplates[i].id == id) {
                return (
                    _islandTemplates[i].id,
                    _islandTemplates[i].name,
                    _islandTemplates[i].coverImage,
                    _islandTemplates[i].file,
                    _islandTemplates[i].fileHash
                );
            }
        }
        revert("not found");
    }
}
