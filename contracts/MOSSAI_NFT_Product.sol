pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import "./utils/StrUtil.sol";
import "./Hyperdust_Roles_Cfg.sol";

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

    address public _MOSSAI_NFT_Market_Address;
    address public _MOSSAIRolesCfgAddress;
    address public _MOSSAI_Island_NFG_Address;
    address public _MOSSAIStorageAddress;
    address public _MOSSAIIslandAddress;

    event eveSave(uint256 id);

    function initialize(address onlyOwner) public initializer {
        __Ownable_init(onlyOwner);
    }

    function setMOSSAINFTMarketAddress(
        address __MOSSAI_NFT_Market_Address
    ) public onlyOwner {
        _MOSSAI_NFT_Market_Address = __MOSSAI_NFT_Market_Address;
    }

    function setMOSSAIRolesCfgAddress(
        address __MOSSAIRolesCfgAddress
    ) public onlyOwner {
        _MOSSAIRolesCfgAddress = __MOSSAIRolesCfgAddress;
    }

    function setMOSSAIIslandNFGAddress(
        address MOSSAI_Island_NFG_Address
    ) public onlyOwner {
        _MOSSAI_Island_NFG_Address = MOSSAI_Island_NFG_Address;
    }

    function setMOSSAIStorageAddress(
        address MOSSAIStorageAddress
    ) public onlyOwner {
        _MOSSAIStorageAddress = MOSSAIStorageAddress;
    }

    function setMOSSAIIslandAddress(
        address MOSSAIIslandAddress
    ) public onlyOwner {
        _MOSSAIIslandAddress = MOSSAIIslandAddress;
    }

    function setContractAddress(
        address[] memory contractaddressArray
    ) public onlyOwner {
        _MOSSAI_NFT_Market_Address = contractaddressArray[0];
        _MOSSAIRolesCfgAddress = contractaddressArray[1];
        _MOSSAI_Island_NFG_Address = contractaddressArray[2];
        _MOSSAIStorageAddress = contractaddressArray[3];
        _MOSSAIIslandAddress = contractaddressArray[4];
    }

    function saveNFTProduct(
        bytes32 sid,
        address contractAddress,
        uint256 tokenId,
        bytes1 status,
        uint32 putawayNum,
        uint256 price,
        bytes1 contractType
    ) public {
        revert("Not implemented");
    }

    function getNFTProduct(
        uint256 id
    )
        public
        view
        returns (
            uint256,
            address,
            uint256,
            uint256,
            address,
            uint256,
            uint256,
            bytes1,
            bytes1,
            bytes32
        )
    {
        revert("Not implemented");
    }

    function addSellNum(uint256 id, uint256 num) public {
        require(
            Hyperdust_Roles_Cfg(_MOSSAIRolesCfgAddress).hasAdminRole(
                msg.sender
            ),
            "not admin role"
        );

        MOSSAI_Storage mossaiStorage = MOSSAI_Storage(_MOSSAIStorageAddress);

        uint256 tokenId = mossaiStorage.getUint(
            mossaiStorage.genKey("tokenId", id)
        );

        require(tokenId > 0, "not found");

        uint256 sellNum = mossaiStorage.getUint(
            mossaiStorage.genKey("sellNum", id)
        );

        uint256 putawayNum = mossaiStorage.getUint(
            mossaiStorage.genKey("putawayNum", id)
        );

        require(sellNum + num <= putawayNum, "Insufficient stock");

        mossaiStorage.setUint(
            mossaiStorage.genKey("sellNum", id),
            sellNum + num
        );

        if (sellNum + num == putawayNum) {
            mossaiStorage.setBytes1(mossaiStorage.genKey("status", id), 0x00);
            mossaiStorage.setUint(mossaiStorage.genKey("sellNum", id), 0);
        }

        emit eveSave(id);
    }

    function saveNFTProductV2(
        bytes32 sid,
        address contractAddress,
        uint256 tokenId,
        bytes1 status,
        uint32 putawayNum,
        uint256 price,
        bytes1 contractType,
        uint256 allowBuyNum
    ) public {
        require(
            contractType == 0x01 || contractType == 0x02,
            "contractType error"
        );

        MOSSAI_Island islandService = MOSSAI_Island(_MOSSAIIslandAddress);
        MOSSAI_Island_NFG islandNFGService = MOSSAI_Island_NFG(
            _MOSSAI_Island_NFG_Address
        );

        (, , , , , , , uint256 seed, , , , , ) = islandService.getIsland(sid);

        address seedOwer = islandNFGService.getSeedOwer(seed);

        require(msg.sender == seedOwer, "not Island owner");

        require(status == 0x01 || status == 0x00, "status error");

        bool allow;

        if (contractType == 0x01) {
            allow =
                IERC721(contractAddress).getApproved(tokenId) ==
                _MOSSAI_NFT_Market_Address;
        } else {
            allow = IERC1155(contractAddress).isApprovedForAll(
                msg.sender,
                _MOSSAI_NFT_Market_Address
            );
        }

        require(allow, "not allow");

        MOSSAI_Storage mossaiStorage = MOSSAI_Storage(_MOSSAIStorageAddress);

        string memory key = string(
            abi.encodePacked(
                contractAddress.toHexString(),
                tokenId.toString(),
                msg.sender.toHexString()
            )
        );

        uint256 id = mossaiStorage.getUint(key);

        if (id == 0) {
            id = mossaiStorage.getNextId();
            mossaiStorage.setUint(key, id);
        } else {
            address owner = mossaiStorage.getAddress(
                mossaiStorage.genKey("owner", id)
            );

            require(owner == msg.sender, "not owner");
        }

        mossaiStorage.setUint(mossaiStorage.genKey("sellNum", id), 0);

        mossaiStorage.setBytes32(mossaiStorage.genKey("sid", id), sid);

        mossaiStorage.setAddress(mossaiStorage.genKey("owner", id), msg.sender);
        mossaiStorage.setUint(
            mossaiStorage.genKey("putawayNum", id),
            putawayNum
        );

        mossaiStorage.setAddress(
            mossaiStorage.genKey("contractAddress", id),
            contractAddress
        );

        mossaiStorage.setUint(mossaiStorage.genKey("tokenId", id), tokenId);
        mossaiStorage.setUint(mossaiStorage.genKey("price", id), price);
        mossaiStorage.setBytes1(mossaiStorage.genKey("status", id), status);
        mossaiStorage.setBytes1(
            mossaiStorage.genKey("contractType", id),
            contractType
        );

        mossaiStorage.setUint(
            mossaiStorage.genKey("allowBuyNum", id),
            allowBuyNum
        );

        emit eveSave(id);
    }

    function getNFTProductV2(
        uint256 id
    )
        public
        view
        returns (
            uint256,
            address,
            uint256,
            uint256,
            address,
            uint256,
            uint256,
            bytes1,
            bytes1,
            bytes32,
            uint256
        )
    {
        MOSSAI_Storage mossaiStorage = MOSSAI_Storage(_MOSSAIStorageAddress);

        uint256 tokenId = mossaiStorage.getUint(
            mossaiStorage.genKey("tokenId", id)
        );

        require(tokenId > 0, "not found");

        return (
            id,
            mossaiStorage.getAddress(mossaiStorage.genKey("owner", id)),
            mossaiStorage.getUint(mossaiStorage.genKey("putawayNum", id)),
            mossaiStorage.getUint(mossaiStorage.genKey("sellNum", id)),
            mossaiStorage.getAddress(
                mossaiStorage.genKey("contractAddress", id)
            ),
            tokenId,
            mossaiStorage.getUint(mossaiStorage.genKey("price", id)),
            mossaiStorage.getBytes1(mossaiStorage.genKey("status", id)),
            mossaiStorage.getBytes1(mossaiStorage.genKey("contractType", id)),
            mossaiStorage.getBytes32(mossaiStorage.genKey("sid", id)),
            mossaiStorage.getUint(mossaiStorage.genKey("allowBuyNum", id))
        );
    }
}
