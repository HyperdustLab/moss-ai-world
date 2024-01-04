pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Strings.sol";

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import "../utils/StrUtil.sol";
import "./MOSSAI_Island_Map.sol";
import "../MOSSAI_Roles_Cfg.sol";
import "../MOSSAI_Storage.sol";

abstract contract OldMOSSAIIsland {
    function getIsland(
        uint256 islandId
    )
        public
        view
        returns (
            uint256,
            string memory,
            string memory,
            string memory,
            string memory,
            address,
            address,
            uint256,
            uint32,
            bytes32,
            string memory
        )
    {}
}

abstract contract INFG {
    function mint(address to, uint32 location) public returns (uint32) {}

    function getSeedOwer(uint32 seed) public view returns (address) {}
}

abstract contract IIslandFactory {
    function deploy(
        address account,
        address islandAssetsCfgAddress
    ) public returns (address) {}
}

contract MOSSAI_Island is OwnableUpgradeable {
    address public _MOSSAIRolesCfgAddress;
    address public _islandNFGAddress;
    address public _MOSSAIIslandMapAddress;
    address public _island721FactoryAddress;
    address public _island1155FactoryAddress;
    address public _islandAssetsCfgAddress;
    address public _HyperdustRolesCfgAddress;
    address public _OldMOSSAIIslandAddress;
    address public _MOSSAIStorageAddress;

    using Strings for *;
    using StrUtil for *;

    string public defCoverImage;
    string public defFile;
    string public fileHash;

    event eveSaveIsland(uint256 id);

    function initialize() public initializer {
        __Ownable_init(msg.sender);
    }

    function setDefParameter(
        string memory _defCoverImage,
        string memory _defFile,
        string memory _fileHash
    ) public onlyOwner {
        defCoverImage = _defCoverImage;
        defFile = _defFile;
        fileHash = _fileHash;
    }

    function setMOSSAIRolesCfgAddress(
        address MOSSAIRolesCfgAddress
    ) public onlyOwner {
        _MOSSAIRolesCfgAddress = MOSSAIRolesCfgAddress;
    }

    function setIslandNFGAddress(address islandNFGAddress) public onlyOwner {
        _islandNFGAddress = islandNFGAddress;
    }

    function setMOSSAIIslandMapAddress(
        address MOSSAIIslandMapAddress
    ) public onlyOwner {
        _MOSSAIIslandMapAddress = MOSSAIIslandMapAddress;
    }

    function setIsland721FactoryAddress(
        address island721FactoryAddress
    ) public onlyOwner {
        _island721FactoryAddress = island721FactoryAddress;
    }

    function setIsland1155FactoryAddress(
        address island1155FactoryAddress
    ) public onlyOwner {
        _island1155FactoryAddress = island1155FactoryAddress;
    }

    function setIslandAssetsCfgAddress(
        address islandAssetsCfgAddress
    ) public onlyOwner {
        _islandAssetsCfgAddress = islandAssetsCfgAddress;
    }

    function setHyperdustRolesCfgAddress(
        address HyperdustRolesCfgAddress
    ) public onlyOwner {
        _HyperdustRolesCfgAddress = HyperdustRolesCfgAddress;
    }

    function setOldMOSSAIIslandAddress(
        address OldMOSSAIIslandAddress
    ) public onlyOwner {
        _OldMOSSAIIslandAddress = OldMOSSAIIslandAddress;
    }

    function setMOSSAIStorageAddress(
        address MOSSAIStorageAddress
    ) public onlyOwner {
        _MOSSAIStorageAddress = MOSSAIStorageAddress;
    }

    function setContractAddress(
        address[] memory contractaddressArray
    ) public onlyOwner {
        _MOSSAIRolesCfgAddress = contractaddressArray[0];
        _islandNFGAddress = contractaddressArray[1];
        _MOSSAIIslandMapAddress = contractaddressArray[2];
        _island721FactoryAddress = contractaddressArray[3];
        _island1155FactoryAddress = contractaddressArray[4];
        _islandAssetsCfgAddress = contractaddressArray[5];
        _HyperdustRolesCfgAddress = contractaddressArray[6];
        _OldMOSSAIIslandAddress = contractaddressArray[7];
        _MOSSAIStorageAddress = contractaddressArray[8];
    }

    function mint(uint32 coordinate, address owner) public {
        require(
            MOSSAI_Roles_Cfg(_MOSSAIRolesCfgAddress).hasAdminRole(msg.sender),
            "not admin role"
        );

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

        MOSSAI_Island_Map(_MOSSAIIslandMapAddress).updateMintStatus(
            coordinate,
            true
        );

        uint32 seed = INFG(_islandNFGAddress).mint(owner, coordinate);

        address island721Address = IIslandFactory(_island721FactoryAddress)
            .deploy(owner, _islandAssetsCfgAddress);

        address island1155Address = IIslandFactory(_island1155FactoryAddress)
            .deploy(owner, _islandAssetsCfgAddress);

        MOSSAI_Roles_Cfg(_HyperdustRolesCfgAddress).addAdmin2(island721Address);
        MOSSAI_Roles_Cfg(_HyperdustRolesCfgAddress).addAdmin2(
            island1155Address
        );

        uint256 id = mossaiStorage.getNextId();

        bytes32 sid = generateHash((block.timestamp + id).toString());

        mossaiStorage.setString(
            mossaiStorage.genKey("name", id),
            owner.toHexString()
        );

        mossaiStorage.setString(
            mossaiStorage.genKey("coverImage", id),
            defCoverImage
        );

        mossaiStorage.setString(mossaiStorage.genKey("file", id), defFile);
        mossaiStorage.setString(mossaiStorage.genKey("fileHash", id), fileHash);

        mossaiStorage.setAddress(
            mossaiStorage.genKey("erc721Address", id),
            island721Address
        );

        mossaiStorage.setAddress(
            mossaiStorage.genKey("erc1155Address", id),
            island1155Address
        );

        mossaiStorage.setUint(
            mossaiStorage.genKey("coordinate", id),
            coordinate
        );

        mossaiStorage.setUint(mossaiStorage.genKey("seed", id), seed);
        mossaiStorage.setBytes32(mossaiStorage.genKey("sid", id), sid);

        emit eveSaveIsland(id);
    }

    function update(
        uint256 id,
        string memory name,
        string memory coverImage,
        string memory file,
        string memory fileHash,
        string memory scenesData
    ) public {
        MOSSAI_Storage mossaiStorage = MOSSAI_Storage(_MOSSAIStorageAddress);
        string memory _name = mossaiStorage.getString(
            mossaiStorage.genKey("name", id)
        );

        require(bytes(_name).length > 0, "not found");

        uint256 seed = mossaiStorage.getUint(mossaiStorage.genKey("seed", id));

        address owner = INFG(_islandNFGAddress).getSeedOwer(uint32(seed));

        require(owner == msg.sender, "not owner");

        mossaiStorage.setString(mossaiStorage.genKey("name", id), name);
        mossaiStorage.setString(
            mossaiStorage.genKey("coverImage", id),
            coverImage
        );

        mossaiStorage.setString(mossaiStorage.genKey("file", id), file);
        mossaiStorage.setString(mossaiStorage.genKey("fileHash", id), fileHash);
        mossaiStorage.setString(
            mossaiStorage.genKey("scenesData", id),
            scenesData
        );

        emit eveSaveIsland(id);
    }

    function generateHash(string memory input) public returns (bytes32) {
        bytes32 hash = keccak256(abi.encodePacked(input));

        string memory hashStr = bytes32ToString(hash);

        MOSSAI_Storage mossaiStorage = MOSSAI_Storage(_MOSSAIStorageAddress);

        bool hashExists = mossaiStorage.getBool(hashStr);

        require(!hashExists, "Hash already exists");

        mossaiStorage.setBool(hashStr, true);

        return hash;
    }

    function bytes32ToString(
        bytes32 _bytes32
    ) public pure returns (string memory) {
        uint8 i = 0;
        while (i < 32 && _bytes32[i] != 0) {
            i++;
        }
        bytes memory bytesArray = new bytes(i);
        for (i = 0; i < 32 && _bytes32[i] != 0; i++) {
            bytesArray[i] = _bytes32[i];
        }
        return string(bytesArray);
    }

    function getIsland(
        uint256 islandId
    )
        public
        view
        returns (
            uint256,
            string memory,
            string memory,
            string memory,
            string memory,
            address,
            address,
            uint256,
            uint256,
            bytes32,
            string memory scenesData
        )
    {
        MOSSAI_Storage mossaiStorage = MOSSAI_Storage(_MOSSAIStorageAddress);
        string memory _name = mossaiStorage.getString(
            mossaiStorage.genKey("name", islandId)
        );

        require(bytes(_name).length > 0, "not found");

        return (
            islandId,
            _name,
            mossaiStorage.getString(
                mossaiStorage.genKey("coverImage", islandId)
            ),
            mossaiStorage.getString(mossaiStorage.genKey("file", islandId)),
            mossaiStorage.getString(mossaiStorage.genKey("fileHash", islandId)),
            mossaiStorage.getAddress(
                mossaiStorage.genKey("erc721Address", islandId)
            ),
            mossaiStorage.getAddress(
                mossaiStorage.genKey("erc1155Address", islandId)
            ),
            mossaiStorage.getUint(mossaiStorage.genKey("coordinate", islandId)),
            mossaiStorage.getUint(mossaiStorage.genKey("seed", islandId)),
            mossaiStorage.getBytes32(mossaiStorage.genKey("sid", islandId)),
            mossaiStorage.getString(
                mossaiStorage.genKey("scenesData", islandId)
            )
        );
    }

    function migration(uint256 start, uint256 end) public onlyOwner {
        OldMOSSAIIsland oldMOSSAIIsland = OldMOSSAIIsland(
            _OldMOSSAIIslandAddress
        );

        MOSSAI_Storage mossaiStorage = MOSSAI_Storage(_MOSSAIStorageAddress);

        for (uint256 i = start; i <= end; i++) {
            (
                uint256 id,
                string memory name,
                string memory coverImage,
                string memory file,
                string memory fileHash,
                address erc721Address,
                address erc1155Address,
                uint256 coordinate,
                uint32 seed,
                bytes32 sid,
                string memory scenesData
            ) = oldMOSSAIIsland.getIsland(i);

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

            string memory hashStr = bytes32ToString(sid);

            mossaiStorage.setBool(hashStr, true);

            MOSSAI_Island_Map(_MOSSAIIslandMapAddress).updateMintStatus(
                uint32(coordinate),
                true
            );

            mossaiStorage.getNextId();

            mossaiStorage.setString(mossaiStorage.genKey("name", id), name);

            mossaiStorage.setString(
                mossaiStorage.genKey("coverImage", id),
                defCoverImage
            );

            mossaiStorage.setString(mossaiStorage.genKey("file", id), defFile);
            mossaiStorage.setString(
                mossaiStorage.genKey("fileHash", id),
                fileHash
            );

            mossaiStorage.setAddress(
                mossaiStorage.genKey("erc721Address", id),
                erc721Address
            );

            mossaiStorage.setAddress(
                mossaiStorage.genKey("erc1155Address", id),
                erc1155Address
            );

            mossaiStorage.setUint(
                mossaiStorage.genKey("coordinate", id),
                coordinate
            );

            mossaiStorage.setUint(mossaiStorage.genKey("seed", id), seed);
            mossaiStorage.setBytes32(mossaiStorage.genKey("sid", id), sid);

            mossaiStorage.setString(
                mossaiStorage.genKey("scenesData", id),
                scenesData
            );
        }
    }
}
