pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Strings.sol";

import "@openzeppelin/contracts/access/Ownable.sol";

import "@openzeppelin/contracts/utils/Counters.sol";

import "../utils/StrUtil.sol";
import "../MOSSAI_Roles_Cfg.sol";

contract MOSSAI_Island_Map is Ownable {
    address public _MOSSAIRolesCfgAddress;

    using Counters for Counters.Counter;
    using Strings for *;
    using StrUtil for *;

    uint32[] public _coordinates;

    mapping(uint32 => bool) public _coordinateMap;

    event eveAddIslandMap(uint32[] coordinates);
    event eveMintIslandMap(uint32[] coordinates);
    event eveDeleteIslandMap(uint32[] coordinates);
    event eveUpdateIslandMap(uint32 coordinate, bool isMint);

    function setMOSSAIRolesCfgAddress(
        address MOSSAIRolesCfgAddress
    ) public onlyOwner {
        _MOSSAIRolesCfgAddress = MOSSAIRolesCfgAddress;
    }

    function add(uint32 coordinate) private {
        require(
            !_coordinateMap[coordinate],
            coordinate.toString().toSlice().concat(
                " coordinate already exists".toSlice()
            )
        );

        _coordinates.push(coordinate);
        _coordinateMap[coordinate] = true;
    }

    function batchAdd(uint32[] memory coordinates) public {
        require(
            MOSSAI_Roles_Cfg(_MOSSAIRolesCfgAddress).hasAdminRole(msg.sender),
            "not admin role"
        );

        for (uint256 i = 0; i < coordinates.length; i++) {
            add(coordinates[i]);
        }

        emit eveAddIslandMap(coordinates);
    }

    function del(uint32 coordinate) private {
        for (uint i = 0; i < _coordinates.length; i++) {
            if (_coordinates[i] == coordinate) {
                _coordinates[i] = _coordinates[_coordinates.length - 1];
                _coordinates.pop();
                _coordinateMap[coordinate] = false;
                return;
            }
        }

        revert("coordinate not found");
    }

    function batchDel(uint32[] memory coordinates) public {
        require(
            MOSSAI_Roles_Cfg(_MOSSAIRolesCfgAddress).hasAdminRole(msg.sender),
            "not admin role"
        );

        for (uint256 i = 0; i < coordinates.length; i++) {
            del(coordinates[i]);
        }
        emit eveDeleteIslandMap(coordinates);
    }

    function updateMintStatus(uint32 coordinate, bool isMint) public {
        require(
            MOSSAI_Roles_Cfg(_MOSSAIRolesCfgAddress).hasAdminRole(msg.sender),
            "not admin role"
        );

        for (uint i = 0; i < _coordinates.length; i++) {
            if (_coordinates[i] == coordinate) {
                _coordinateMap[coordinate] = isMint;

                emit eveUpdateIslandMap(coordinate, isMint);
                return;
            }
        }

        revert("coordinate not found");
    }
}
