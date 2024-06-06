pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Strings.sol";

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import "../utils/StrUtil.sol";
import "./MOSSAI_Island_Map.sol";
import "../HyperAGI_Roles_Cfg.sol";
import "../HyperAGI_GYM_Space.sol";
import "../MOSSAI_Storage.sol";
import "./MOSSAI_Island_NFG.sol";

abstract contract IIslandFactory {
    function deploy(address account, string memory name, string memory symbol) public returns (address) {}
}

contract MOSSAI_Island is OwnableUpgradeable {
    using Strings for *;
    using StrUtil for *;

    address public _islandNFGAddress;
    address public _islandMapAddress;
    address public _island721FactoryAddress;
    address public _island1155FactoryAddress;
    address public _rolesCfgAddress;
    address public _storageAddress;
    address public _IslandMintAddress;
    address public _GYMSpaceAddress;

    string public defCoverImage;
    string public defFile;
    string public fileHash;

    uint256 public _erc721Version;
    uint256 public _erc1155Version;

    event eveSaveIsland(bytes32 sid);

    event eveErc721Version();
    event eveErc1155Version();

    function initialize(address onlyOwner) public initializer {
        __Ownable_init(onlyOwner);
    }

    function setDefParameter(string memory _defCoverImage, string memory _defFile, string memory _fileHash) public onlyOwner {
        defCoverImage = _defCoverImage;
        defFile = _defFile;
        fileHash = _fileHash;
    }

    function set_islandNFGAddress(address newAddress) public onlyOwner {
        _islandNFGAddress = newAddress;
    }

    function set_islandMapAddress(address newAddress) public onlyOwner {
        _islandMapAddress = newAddress;
    }

    function set_island721FactoryAddress(address newAddress) public onlyOwner {
        _island721FactoryAddress = newAddress;
    }

    function set_island1155FactoryAddress(address newAddress) public onlyOwner {
        _island1155FactoryAddress = newAddress;
    }

    function set_rolesCfgAddress(address newAddress) public onlyOwner {
        _rolesCfgAddress = newAddress;
    }

    function set_storageAddress(address newAddress) public onlyOwner {
        _storageAddress = newAddress;
    }

    function set_IslandMintAddress(address newAddress) public onlyOwner {
        _IslandMintAddress = newAddress;
    }

    function set_GYMSpaceAddress(address newAddress) public onlyOwner {
        _GYMSpaceAddress = newAddress;
    }

    function setContractAddress(address[] memory contractaddressArray) public onlyOwner {
        require(contractaddressArray.length == 8, "Input array length must be 8");

        _islandNFGAddress = contractaddressArray[0];
        _islandMapAddress = contractaddressArray[1];
        _island721FactoryAddress = contractaddressArray[2];
        _island1155FactoryAddress = contractaddressArray[3];
        _rolesCfgAddress = contractaddressArray[4];
        _storageAddress = contractaddressArray[5];
        _IslandMintAddress = contractaddressArray[6];
        _GYMSpaceAddress = contractaddressArray[7];
    }

    function mint(uint32 coordinate, address owner, string memory islandName, string[] memory names, string[] memory symbols) public {
        require(IHyperAGI_Roles_Cfg(_rolesCfgAddress).hasAdminRole(msg.sender), "not admin role");

        MOSSAI_Storage storageAddress = MOSSAI_Storage(_storageAddress);

        IIHyperAGI_GYM_Space GYMSpaceAddress = IIHyperAGI_GYM_Space(_GYMSpaceAddress);

        string memory key = string(abi.encodePacked("coordinate_", coordinate.toString()));

        require(!storageAddress.getBool(key), coordinate.toString().toSlice().concat(" coordinate already exists".toSlice()));

        storageAddress.setBool(key, true);

        MOSSAI_Island_Map(_islandMapAddress).updateMintStatus(coordinate, true);

        uint256 seed = MOSSAI_Island_NFG(_islandNFGAddress).mint(owner, coordinate);

        address island721Address = IIslandFactory(_island721FactoryAddress).deploy(_IslandMintAddress, names[0], symbols[0]);

        address island1155Address = IIslandFactory(_island1155FactoryAddress).deploy(_IslandMintAddress, names[1], symbols[1]);

        uint256 id = storageAddress.getNextId();

        bytes32 sid = GYMSpaceAddress.add(islandName, defCoverImage, "", "");
        storageAddress.setBytes32Uint(sid, id);

        storageAddress.setString(storageAddress.genKey("name", id), islandName);

        storageAddress.setString(storageAddress.genKey("coverImage", id), defCoverImage);

        storageAddress.setString(storageAddress.genKey("file", id), defFile);
        storageAddress.setString(storageAddress.genKey("fileHash", id), fileHash);

        storageAddress.setAddress(storageAddress.genKey("erc721Address", id), island721Address);

        storageAddress.setAddress(storageAddress.genKey("erc1155Address", id), island1155Address);

        storageAddress.setUint(storageAddress.genKey("coordinate", id), coordinate);

        storageAddress.setUint(storageAddress.genKey("seed", id), seed);
        storageAddress.setBytes32(storageAddress.genKey("sid", id), sid);

        storageAddress.setUint(storageAddress.genKey("erc721Version", id), _erc721Version);

        storageAddress.setUint(storageAddress.genKey("erc1155Version", id), _erc1155Version);

        emit eveSaveIsland(sid);
    }

    function updateErc721Address(bytes32 sid, string memory name, string memory symbol) public {
        MOSSAI_Storage storageAddress = MOSSAI_Storage(_storageAddress);

        uint256 id = storageAddress.getBytes32Uint(sid);

        require(id > 0, "not found");

        string memory _name = storageAddress.getString(storageAddress.genKey("name", id));
        require(bytes(_name).length > 0, "not found");

        uint256 seed = storageAddress.getUint(storageAddress.genKey("seed", id));

        address owner = MOSSAI_Island_NFG(_islandNFGAddress).getSeedOwer(uint32(seed));

        require(owner == msg.sender, "not owner");

        address erc721Address = IIslandFactory(_island721FactoryAddress).deploy(_IslandMintAddress, name, symbol);

        storageAddress.setAddress(storageAddress.genKey("erc721Address", id), erc721Address);
        storageAddress.setUint(storageAddress.genKey("erc721Version", id), _erc721Version);

        emit eveSaveIsland(sid);
    }

    function updateErc1155Address(bytes32 sid, string memory name, string memory symbol) public {
        MOSSAI_Storage storageAddress = MOSSAI_Storage(_storageAddress);

        uint256 id = storageAddress.getBytes32Uint(sid);

        require(id > 0, "not found");

        string memory _name = storageAddress.getString(storageAddress.genKey("name", id));
        require(bytes(_name).length > 0, "not found");

        uint256 seed = storageAddress.getUint(storageAddress.genKey("seed", id));

        address owner = MOSSAI_Island_NFG(_islandNFGAddress).getSeedOwer(uint32(seed));

        require(owner == msg.sender, "not owner");

        address erc1155Address = IIslandFactory(_island1155FactoryAddress).deploy(_IslandMintAddress, name, symbol);

        storageAddress.setAddress(storageAddress.genKey("erc1155Address", id), erc1155Address);

        storageAddress.setUint(storageAddress.genKey("erc1155Version", id), _erc1155Version);
        emit eveSaveIsland(sid);
    }

    function update(bytes32 sid, string memory name, string memory coverImage, string memory file, string memory fileHash, string memory scenesData, string memory placementRecord) public {
        MOSSAI_Storage storageAddress = MOSSAI_Storage(_storageAddress);
        IHyperAGI_GYM_Space GYMSpaceAddress = IHyperAGI_GYM_Space(_GYMSpaceAddress);

        uint256 id = storageAddress.getBytes32Uint(sid);
        require(id > 0, "not found");

        string memory _name = storageAddress.getString(storageAddress.genKey("name", id));

        require(bytes(_name).length > 0, "not found");

        uint256 seed = storageAddress.getUint(storageAddress.genKey("seed", id));

        address owner = MOSSAI_Island_NFG(_islandNFGAddress).getSeedOwer(uint32(seed));

        require(owner == msg.sender, "not owner");

        storageAddress.setString(storageAddress.genKey("name", id), name);
        storageAddress.setString(storageAddress.genKey("coverImage", id), coverImage);

        storageAddress.setString(storageAddress.genKey("file", id), file);
        storageAddress.setString(storageAddress.genKey("fileHash", id), fileHash);
        storageAddress.setString(storageAddress.genKey("scenesData", id), scenesData);

        storageAddress.setString(storageAddress.genKey("placementRecord", id), placementRecord);

        GYMSpaceAddress.edit(sid, name, coverImage, "", "");

        emit eveSaveIsland(sid);
    }

    function getIsland(bytes32 sid) public view returns (string memory, string memory, string memory, string memory, address, address, uint256, uint256, bytes32, string memory, string memory, uint256, uint256) {
        MOSSAI_Storage storageAddress = MOSSAI_Storage(_storageAddress);
        uint256 islandId = storageAddress.getBytes32Uint(sid);

        string memory _name = storageAddress.getString(storageAddress.genKey("name", islandId));

        require(bytes(_name).length > 0, "not found");

        return (
            _name,
            storageAddress.getString(storageAddress.genKey("coverImage", islandId)),
            storageAddress.getString(storageAddress.genKey("file", islandId)),
            storageAddress.getString(storageAddress.genKey("fileHash", islandId)),
            storageAddress.getAddress(storageAddress.genKey("erc721Address", islandId)),
            storageAddress.getAddress(storageAddress.genKey("erc1155Address", islandId)),
            storageAddress.getUint(storageAddress.genKey("coordinate", islandId)),
            storageAddress.getUint(storageAddress.genKey("seed", islandId)),
            storageAddress.getBytes32(storageAddress.genKey("sid", islandId)),
            storageAddress.getString(storageAddress.genKey("scenesData", islandId)),
            storageAddress.getString(storageAddress.genKey("placementRecord", islandId)),
            storageAddress.getUint(storageAddress.genKey("erc721Version", islandId)),
            storageAddress.getUint(storageAddress.genKey("erc1155Version", islandId))
        );
    }

    function updateErc721Version(uint256 version) public {
        require(IHyperAGI_Roles_Cfg(_HyperdustRolesCfgAddress).hasAdminRole(msg.sender), "not admin role");
        _erc721Version = version;
        emit eveErc721Version();
    }

    function updateErc1155Version(uint256 version) public {
        require(IHyperAGI_Roles_Cfg(_HyperdustRolesCfgAddress).hasAdminRole(msg.sender), "not admin role");
        _erc1155Version = version;

        emit eveErc1155Version();
    }

    function getVersions() public view returns (uint256, uint256) {
        return (_erc721Version, _erc1155Version);
    }
}
