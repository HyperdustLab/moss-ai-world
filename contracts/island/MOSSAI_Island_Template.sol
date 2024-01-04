pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Strings.sol";

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import "../utils/StrUtil.sol";
import "../MOSSAI_Roles_Cfg.sol";
import "../MOSSAI_Storage.sol";

contract MOSSAI_Island_Template is OwnableUpgradeable {
    address public _MOSSAIRolesCfgAddress;

    address public _MOSSAIStorageAddress;

    using Strings for *;
    using StrUtil for *;

    event eveDeleteIslandTemplate(uint256 id);

    event eveSaveIslandTemplate(uint256 id);

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

        MOSSAI_Storage mossaiStorage = MOSSAI_Storage(_MOSSAIStorageAddress);

        uint256 id = mossaiStorage.getNextId();

        mossaiStorage.setString(mossaiStorage.genKey("name", id), name);
        mossaiStorage.setString(
            mossaiStorage.genKey("coverImage", id),
            coverImage
        );

        mossaiStorage.setString(mossaiStorage.genKey("file", id), file);
        mossaiStorage.setString(mossaiStorage.genKey("fileHash", id), fileHash);

        emit eveSaveIslandTemplate(id);
    }

    function update(
        uint256 id,
        string memory name,
        string memory coverImage,
        string memory file,
        string memory fileHash
    ) public {
        require(
            MOSSAI_Roles_Cfg(_MOSSAIRolesCfgAddress).hasAdminRole(msg.sender),
            "not admin role"
        );

        MOSSAI_Storage mossaiStorage = MOSSAI_Storage(_MOSSAIStorageAddress);

        string memory _name = mossaiStorage.getString(
            mossaiStorage.genKey("name", id)
        );

        require(bytes(_name).length > 0, "not found");

        mossaiStorage.setString(mossaiStorage.genKey("name", id), name);
        mossaiStorage.setString(
            mossaiStorage.genKey("coverImage", id),
            coverImage
        );

        mossaiStorage.setString(mossaiStorage.genKey("file", id), file);
        mossaiStorage.setString(mossaiStorage.genKey("fileHash", id), fileHash);

        emit eveSaveIslandTemplate(id);
    }

    function deleteIslandTemplate(uint256 id) public {
        require(
            MOSSAI_Roles_Cfg(_MOSSAIRolesCfgAddress).hasAdminRole(msg.sender),
            "not admin role"
        );

        MOSSAI_Storage mossaiStorage = MOSSAI_Storage(_MOSSAIStorageAddress);

        string memory _name = mossaiStorage.getString(
            mossaiStorage.genKey("name", id)
        );

        require(bytes(_name).length > 0, "not found");

        mossaiStorage.setString(mossaiStorage.genKey("name", id), "");

        emit eveDeleteIslandTemplate(id);
    }

    function getIslandTemplate(
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
        MOSSAI_Storage mossaiStorage = MOSSAI_Storage(_MOSSAIStorageAddress);

        string memory _name = mossaiStorage.getString(
            mossaiStorage.genKey("name", id)
        );
        return (
            id,
            _name,
            mossaiStorage.getString(mossaiStorage.genKey("coverImage", id)),
            mossaiStorage.getString(mossaiStorage.genKey("file", id)),
            mossaiStorage.getString(mossaiStorage.genKey("fileHash", id))
        );
    }
}
