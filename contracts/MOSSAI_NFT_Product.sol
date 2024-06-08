pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import "./utils/StrUtil.sol";
import "./HyperAGI_Roles_Cfg.sol";
import "./HyperAGI_Transaction_Cfg.sol";

import "./MOSSAI_Storage.sol";
import "./island/MOSSAI_Island.sol";
import "./island/MOSSAI_Island_NFG.sol";

/**
 * @title MOSSAI_NFT_Product
 * @dev This contract represents an NFT product marketplace where users can save, retrieve, and sell NFT products.
 */
contract MOSSAI_NFT_Product is OwnableUpgradeable {
    using Strings for *;
    using StrUtil for *;

    address public _NFT_Market_Address;
    address public _rolesCfgAddress;
    address public _island_NFG_Address;
    address public _storageAddress;
    address public _islandAddress;

    event eveSave(uint256 id);

    function initialize(address onlyOwner) public initializer {
        __Ownable_init(onlyOwner);
    }

    function setNFTMarketAddress(address NFTMarketAddress) public onlyOwner {
        _NFT_Market_Address = NFTMarketAddress;
    }

    function setRolesCfgAddress(address rolesCfgAddress) public onlyOwner {
        _rolesCfgAddress = rolesCfgAddress;
    }

    function setIslandNFGAddress(address islandNFGAddress) public onlyOwner {
        _island_NFG_Address = islandNFGAddress;
    }

    function setStorageAddress(address storageAddress) public onlyOwner {
        _storageAddress = storageAddress;
    }

    function setIslandAddress(address islandAddress) public onlyOwner {
        _islandAddress = islandAddress;
    }

    function setContractAddress(address[] memory contractaddressArray) public onlyOwner {
        require(contractaddressArray.length >= 5, "Insufficient addresses provided");
        setNFTMarketAddress(contractaddressArray[0]);
        setRolesCfgAddress(contractaddressArray[1]);
        setIslandNFGAddress(contractaddressArray[2]);
        setStorageAddress(contractaddressArray[3]);
        setIslandAddress(contractaddressArray[4]);
    }

    function addSellNum(uint256 id, uint256 num) public {
        require(IHyperAGI_Roles_Cfg(_rolesCfgAddress).hasAdminRole(msg.sender), "not admin role");

        MOSSAI_Storage storageAddress = MOSSAI_Storage(_storageAddress);

        uint256 tokenId = storageAddress.getUint(storageAddress.genKey("tokenId", id));

        require(tokenId > 0, "not found");

        uint256 sellNum = storageAddress.getUint(storageAddress.genKey("sellNum", id));

        uint256 putawayNum = storageAddress.getUint(storageAddress.genKey("putawayNum", id));

        require(sellNum + num <= putawayNum, "Insufficient stock");

        storageAddress.setUint(storageAddress.genKey("sellNum", id), sellNum + num);

        if (sellNum + num == putawayNum) {
            storageAddress.setBytes1(storageAddress.genKey("status", id), 0x00);
            storageAddress.setUint(storageAddress.genKey("sellNum", id), 0);
        }

        emit eveSave(id);
    }

    function getNFTProduct(uint256 id) public view returns (uint256[] memory, address, address, bytes1, bytes1, bytes32) {
        MOSSAI_Storage storageAddress = MOSSAI_Storage(_storageAddress);

        uint256 tokenId = storageAddress.getUint(storageAddress.genKey("tokenId", id));

        require(tokenId > 0, "not found");

        uint256[] memory uint256Array = new uint256[](6);
        uint256Array[0] = id;
        uint256Array[1] = storageAddress.getUint(storageAddress.genKey("putawayNum", id));
        uint256Array[2] = storageAddress.getUint(storageAddress.genKey("sellNum", id));
        uint256Array[3] = storageAddress.getUint(storageAddress.genKey("price", id));
        uint256Array[4] = storageAddress.getUint(storageAddress.genKey("allowBuyNum", id));
        uint256Array[5] = tokenId;

        return (
            uint256Array,
            storageAddress.getAddress(storageAddress.genKey("owner", id)),
            storageAddress.getAddress(storageAddress.genKey("contractAddress", id)),
            storageAddress.getBytes1(storageAddress.genKey("status", id)),
            storageAddress.getBytes1(storageAddress.genKey("contractType", id)),
            storageAddress.getBytes32(storageAddress.genKey("sid", id))
        );
    }

    function saveNFTProduct(bytes32 sid, address contractAddress, uint256 tokenId, bytes1 status, uint32 putawayNum, uint256 price, bytes1 contractType, uint256 allowBuyNum) public {
        require(contractType == 0x01 || contractType == 0x02, "contractType error");

        MOSSAI_Island islandAddress = MOSSAI_Island(_islandAddress);

        (, , address[] memory addressArray) = islandAddress.getIsland(sid);

        require(msg.sender == addressArray[2], "not Island owner");

        require(status == 0x01 || status == 0x00, "status error");

        bool allow;

        if (contractType == 0x01) {
            allow = IERC721(contractAddress).getApproved(tokenId) == _NFT_Market_Address;
        } else {
            allow = IERC1155(contractAddress).isApprovedForAll(msg.sender, _NFT_Market_Address);
        }

        require(allow, "not allow");

        MOSSAI_Storage storageAddress = MOSSAI_Storage(_storageAddress);

        string memory key = string(abi.encodePacked(contractAddress.toHexString(), tokenId.toString(), msg.sender.toHexString()));

        uint256 id = storageAddress.getUint(key);

        if (id == 0) {
            id = storageAddress.getNextId();
            storageAddress.setUint(key, id);
        } else {
            address owner = storageAddress.getAddress(storageAddress.genKey("owner", id));

            require(owner == msg.sender, "not owner");
        }

        storageAddress.setUint(storageAddress.genKey("sellNum", id), 0);

        storageAddress.setBytes32(storageAddress.genKey("sid", id), sid);

        storageAddress.setAddress(storageAddress.genKey("owner", id), msg.sender);
        storageAddress.setUint(storageAddress.genKey("putawayNum", id), putawayNum);

        storageAddress.setAddress(storageAddress.genKey("contractAddress", id), contractAddress);

        storageAddress.setUint(storageAddress.genKey("tokenId", id), tokenId);
        storageAddress.setUint(storageAddress.genKey("price", id), price);
        storageAddress.setBytes1(storageAddress.genKey("status", id), status);
        storageAddress.setBytes1(storageAddress.genKey("contractType", id), contractType);

        storageAddress.setUint(storageAddress.genKey("allowBuyNum", id), allowBuyNum);

        emit eveSave(id);
    }
}
