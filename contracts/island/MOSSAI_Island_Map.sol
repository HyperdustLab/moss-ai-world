pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Strings.sol";

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import "../utils/StrUtil.sol";
import "../Hyperdust_Roles_Cfg.sol";
import "../MOSSAI_Storage.sol";

contract MOSSAI_Island_Map is OwnableUpgradeable {
    address public _MOSSAIRolesCfgAddress;
    address public _MOSSAIStorageAddress;

    using Strings for *;
    using StrUtil for *;

    event eveAddIslandMap(uint256[] coordinates);
    event eveMintIslandMap(uint256[] coordinates);
    event eveDeleteIslandMap(uint256[] coordinates);
    event eveUpdateIslandMap(uint256 coordinate, bool isMint);

    function initialize() public initializer {
        __Ownable_init(msg.sender);
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

    function add(uint256 coordinate) private {
        MOSSAI_Storage mossaiStorage = MOSSAI_Storage(_MOSSAIStorageAddress);

        string memory key = string(
            abi.encodePacked("coordinate_", coordinate.toString())
        );

        require(
            !mossaiStorage.getBool(key),
            coordinate.toString().toSlice().concat(
                " coordinate already exists".toSlice()
            )
        );

        mossaiStorage.setBool(key, true);
    }

    function batchAdd(uint256[] memory coordinates) public {
        require(
            Hyperdust_Roles_Cfg(_MOSSAIRolesCfgAddress).hasAdminRole(
                msg.sender
            ),
            "not admin role"
        );

        for (uint256 i = 0; i < coordinates.length; i++) {
            add(coordinates[i]);
        }

        emit eveAddIslandMap(coordinates);
    }

    function del(uint256 coordinate) private {
        MOSSAI_Storage mossaiStorage = MOSSAI_Storage(_MOSSAIStorageAddress);

        string memory key = string(
            abi.encodePacked("coordinate_", coordinate.toString())
        );

        require(mossaiStorage.getBool(key), "coordinate not exists");

        mossaiStorage.setBool(key, false);
    }

    function batchDel(uint256[] memory coordinates) public {
        require(
            Hyperdust_Roles_Cfg(_MOSSAIRolesCfgAddress).hasAdminRole(
                msg.sender
            ),
            "not admin role"
        );

        for (uint256 i = 0; i < coordinates.length; i++) {
            del(coordinates[i]);
        }
        emit eveDeleteIslandMap(coordinates);
    }

    function updateMintStatus(uint32 coordinate, bool isMint) public {
        require(
            Hyperdust_Roles_Cfg(_MOSSAIRolesCfgAddress).hasAdminRole(
                msg.sender
            ),
            "not admin role"
        );

        MOSSAI_Storage mossaiStorage = MOSSAI_Storage(_MOSSAIStorageAddress);

        string memory _key = string(
            abi.encodePacked("coordinate_", coordinate.toString())
        );

        require(mossaiStorage.getBool(_key), "coordinate not exists");

        string memory key = string(
            abi.encodePacked("mint_", coordinate.toString())
        );

        mossaiStorage.setBool(key, isMint);

        emit eveUpdateIslandMap(coordinate, isMint);
    }
}
