pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Strings.sol";

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import "../utils/StrUtil.sol";
import "./MOSSAI_Island_Map.sol";
import "../Hyperdust_Roles_Cfg.sol";
import "../MOSSAI_Storage.sol";
import "./MOSSAI_Island_NFG.sol";

import "@openzeppelin/contracts/utils/Strings.sol";
import "../utils/StrUtil.sol";

abstract contract IIslandFactory {
    function deploy(
        address account,
        string memory name,
        string memory symbol
    ) public returns (address) {}
}

contract MOSSAI_Island is OwnableUpgradeable {
    using Strings for *;
    using StrUtil for *;

    address public _islandNFGAddress;
    address public _MOSSAIIslandMapAddress;
    address public _island721FactoryAddress;
    address public _island1155FactoryAddress;
    address public _HyperdustRolesCfgAddress;
    address public _MOSSAIStorageAddress;
    address public _IslandMintAddress;

    string public defCoverImage;
    string public defFile;
    string public fileHash;

    event eveSaveIsland(uint256 id);

    function initialize(address onlyOwner) public initializer {
        __Ownable_init(onlyOwner);
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

    function setHyperdustRolesCfgAddress(
        address HyperdustRolesCfgAddress
    ) public onlyOwner {
        _HyperdustRolesCfgAddress = HyperdustRolesCfgAddress;
    }

    function setMOSSAIStorageAddress(
        address MOSSAIStorageAddress
    ) public onlyOwner {
        _MOSSAIStorageAddress = MOSSAIStorageAddress;
    }

    function setIslandMintAddress(address IslandMintAddress) public onlyOwner {
        _IslandMintAddress = IslandMintAddress;
    }

    function setContractAddress(
        address[] memory contractaddressArray
    ) public onlyOwner {
        _islandNFGAddress = contractaddressArray[0];
        _MOSSAIIslandMapAddress = contractaddressArray[1];
        _island721FactoryAddress = contractaddressArray[2];
        _island1155FactoryAddress = contractaddressArray[3];
        _HyperdustRolesCfgAddress = contractaddressArray[4];
        _MOSSAIStorageAddress = contractaddressArray[5];
        _IslandMintAddress = contractaddressArray[6];
    }

    function mint(
        uint32 coordinate,
        address owner,
        string[] memory names,
        string[] memory symbols
    ) public {
        require(
            Hyperdust_Roles_Cfg(_HyperdustRolesCfgAddress).hasAdminRole(
                msg.sender
            ),
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

        uint256 seed = MOSSAI_Island_NFG(_islandNFGAddress).mint(
            owner,
            coordinate
        );

        address island721Address = IIslandFactory(_island721FactoryAddress)
            .deploy(_IslandMintAddress, names[0], symbols[0]);

        address island1155Address = IIslandFactory(_island1155FactoryAddress)
            .deploy(_IslandMintAddress, names[1], symbols[1]);

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

        address owner = MOSSAI_Island_NFG(_islandNFGAddress).getSeedOwer(
            uint32(seed)
        );

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
            string memory
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

    function updateErc721Address(
        uint256 islandId,
        string memory name,
        string memory symbol
    ) public {
        MOSSAI_Storage mossaiStorage = MOSSAI_Storage(_MOSSAIStorageAddress);
        string memory _name = mossaiStorage.getString(
            mossaiStorage.genKey("name", islandId)
        );
        require(bytes(_name).length > 0, "not found");

        uint256 seed = mossaiStorage.getUint(
            mossaiStorage.genKey("seed", islandId)
        );

        address owner = MOSSAI_Island_NFG(_islandNFGAddress).getSeedOwer(
            uint32(seed)
        );

        require(owner == msg.sender, "not owner");

        address erc721Address = IIslandFactory(_island721FactoryAddress).deploy(
            _IslandMintAddress,
            name,
            symbol
        );

        mossaiStorage.setAddress(
            mossaiStorage.genKey("erc721Address", islandId),
            erc721Address
        );
        emit eveSaveIsland(islandId);
    }

    function updateErc1155Address(
        uint256 islandId,
        string memory name,
        string memory symbol
    ) public {
        MOSSAI_Storage mossaiStorage = MOSSAI_Storage(_MOSSAIStorageAddress);
        string memory _name = mossaiStorage.getString(
            mossaiStorage.genKey("name", islandId)
        );
        require(bytes(_name).length > 0, "not found");

        uint256 seed = mossaiStorage.getUint(
            mossaiStorage.genKey("seed", islandId)
        );

        address owner = MOSSAI_Island_NFG(_islandNFGAddress).getSeedOwer(
            uint32(seed)
        );

        require(owner == msg.sender, "not owner");

        address erc1155Address = IIslandFactory(_island1155FactoryAddress)
            .deploy(_IslandMintAddress, name, symbol);

        mossaiStorage.setAddress(
            mossaiStorage.genKey("erc1155Address", islandId),
            erc1155Address
        );
        emit eveSaveIsland(islandId);
    }
}
