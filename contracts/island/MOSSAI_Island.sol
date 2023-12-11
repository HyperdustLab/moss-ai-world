pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Strings.sol";

import "@openzeppelin/contracts/access/Ownable.sol";

import "@openzeppelin/contracts/utils/Counters.sol";

import "../utils/StrUtil.sol";
import "./MOSSAI_Island_Map.sol";
import "../MOSSAI_Roles_Cfg.sol";

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

contract MOSSAI_Island is Ownable {
    Counters.Counter private _index;
    address public _MOSSAIRolesCfgAddress;
    address public _islandNFGAddress;
    address public _MOSSAIIslandMapAddress;
    address public _island721FactoryAddress;
    address public _island1155FactoryAddress;
    address public _islandAssetsCfgAddress;
    address public _HyperdustRolesCfgAddress;

    using Counters for Counters.Counter;
    Counters.Counter private _id;

    using Strings for *;
    using StrUtil for *;

    Island[] public _islands;

    mapping(uint32 => bool) public _coordinateExists;

    mapping(bytes32 => bool) public hashExists;

    string public defCoverImage;
    string public defFile;
    string public fileHash;

    struct Island {
        uint256 id;
        string name;
        string coverImage;
        string file;
        string fileHash;
        address erc721Address;
        address erc1155Address;
        uint256 coordinate;
        uint32 seed;
        bytes32 sid;
    }

    event eveSaveIsland(uint256 id);

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
    }

    function mint(uint32 coordinate, address owner) public {
        require(
            MOSSAI_Roles_Cfg(_MOSSAIRolesCfgAddress).hasAdminRole(msg.sender),
            "not admin role"
        );

        require(!_coordinateExists[coordinate], "Location has been cast");

        _coordinateExists[coordinate] = true;

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

        bytes32 sid = generateHash(
            (block.timestamp + _index.current()).toString()
        );

        _index.increment();

        Island memory island = Island({
            id: _index.current(),
            name: owner.toHexString(),
            coverImage: defCoverImage,
            file: defFile,
            fileHash: fileHash,
            erc721Address: island721Address,
            erc1155Address: island1155Address,
            coordinate: coordinate,
            seed: seed,
            sid: sid
        });

        _islands.push(island);

        emit eveSaveIsland(_index.current());
    }

    function update(
        uint256 id,
        string memory name,
        string memory coverImage,
        string memory file,
        string memory fileHash
    ) public {
        for (uint256 i = 0; i < _islands.length; i++) {
            if (_islands[i].id == id) {
                address owner = INFG(_islandNFGAddress).getSeedOwer(
                    _islands[i].seed
                );

                require(owner == msg.sender, "not owner");

                _islands[i].name = name;
                _islands[i].coverImage = coverImage;
                _islands[i].file = file;
                _islands[i].fileHash = fileHash;

                emit eveSaveIsland(id);
                return;
            }
        }
        revert("island does not exist");
    }

    function generateHash(string memory input) public returns (bytes32) {
        bytes32 hash = keccak256(abi.encodePacked(input));
        require(!hashExists[hash], "Hash already exists");
        hashExists[hash] = true;
        return hash;
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
            uint32,
            bytes32
        )
    {
        for (uint i = 0; i < _islands.length; i++) {
            if (_islands[i].id == islandId) {
                return (
                    _islands[i].id,
                    _islands[i].name,
                    _islands[i].coverImage,
                    _islands[i].file,
                    _islands[i].fileHash,
                    _islands[i].erc721Address,
                    _islands[i].erc1155Address,
                    _islands[i].coordinate,
                    _islands[i].seed,
                    _islands[i].sid
                );
            }
        }
        revert("not found");
    }
}
