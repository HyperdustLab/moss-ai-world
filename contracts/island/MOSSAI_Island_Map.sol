pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Strings.sol";

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import "../utils/StrUtil.sol";
import "../HyperAGI_Roles_Cfg.sol";
import "../MOSSAI_Storage.sol";

contract MOSSAI_Island_Map is OwnableUpgradeable {
    address public _rolesCfgAddress;
    address public _storageAddress;

    using Strings for *;
    using StrUtil for *;

    event eveAddIslandMap(uint256[] coordinates);
    event eveMintIslandMap(uint256[] coordinates);
    event eveDeleteIslandMap(uint256[] coordinates);
    event eveUpdateIslandMap(uint256 coordinate, bool isMint);

    function initialize(address onlyOwner) public initializer {
        __Ownable_init(onlyOwner);
    }

    function setRolesCfgAddress(address rolesCfgAddress) public onlyOwner {
        _rolesCfgAddress = rolesCfgAddress;
    }

    function setStorageAddress(address storageAddress) public onlyOwner {
        _storageAddress = storageAddress;
    }

    function setContractAddress(address[] memory contractaddressArray) public onlyOwner {
        require(contractaddressArray.length >= 2, "Insufficient addresses provided");
        setRolesCfgAddress(contractaddressArray[0]);
        setStorageAddress(contractaddressArray[1]);
    }

    function add(uint256 coordinate) private {
        MOSSAI_Storage storageAddress = MOSSAI_Storage(_storageAddress);

        string memory key = string(abi.encodePacked("coordinate_", coordinate.toString()));

        require(!storageAddress.getBool(key), coordinate.toString().toSlice().concat(" coordinate already exists".toSlice()));

        storageAddress.setBool(key, true);
    }

    function batchAdd(uint256[] memory coordinates) public {
        require(IHyperAGI_Roles_Cfg(_rolesCfgAddress).hasAdminRole(msg.sender), "not admin role");

        for (uint256 i = 0; i < coordinates.length; i++) {
            add(coordinates[i]);
        }

        emit eveAddIslandMap(coordinates);
    }

    function del(uint256 coordinate) private {
        MOSSAI_Storage storageAddress = MOSSAI_Storage(_storageAddress);

        string memory key = string(abi.encodePacked("coordinate_", coordinate.toString()));

        require(storageAddress.getBool(key), "coordinate not exists");

        storageAddress.setBool(key, false);
    }

    function batchDel(uint256[] memory coordinates) public {
        require(IHyperAGI_Roles_Cfg(_rolesCfgAddress).hasAdminRole(msg.sender), "not admin role");

        for (uint256 i = 0; i < coordinates.length; i++) {
            del(coordinates[i]);
        }
        emit eveDeleteIslandMap(coordinates);
    }

    function updateMintStatus(uint32 coordinate, bool isMint) public {
        require(IHyperAGI_Roles_Cfg(_rolesCfgAddress).hasAdminRole(msg.sender), "not admin role");

        MOSSAI_Storage storageAddress = MOSSAI_Storage(_storageAddress);

        string memory _key = string(abi.encodePacked("coordinate_", coordinate.toString()));

        require(storageAddress.getBool(_key), "coordinate not exists");

        string memory key = string(abi.encodePacked("mint_", coordinate.toString()));

        storageAddress.setBool(key, isMint);

        emit eveUpdateIslandMap(coordinate, isMint);
    }
}
