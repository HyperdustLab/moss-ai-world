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

    function setContractAddress(
        address[] memory contractaddressArray
    ) public onlyOwner {
        _MOSSAI_NFT_Market_Address = contractaddressArray[0];
        _MOSSAIRolesCfgAddress = contractaddressArray[1];
        _MOSSAI_Island_NFG_Address = contractaddressArray[2];
        _MOSSAIStorageAddress = contractaddressArray[3];
    }

    /**
     * @dev Saves an NFT product to the marketplace.
     * @param contractAddress The address of the NFT contract.
     * @param tokenId The ID of the NFT.
     * @param status The status of the NFT product.
     * @param putawayNum The number of NFT products put away.
     * @param price The price of the NFT product.
     * @param contractType The type of the NFT contract.
     */
    function saveNFTProduct(
        address contractAddress,
        uint256 tokenId,
        bytes1 status,
        uint32 putawayNum,
        uint256 price,
        bytes1 contractType
    ) public {
        require(
            contractType == 0x01 || contractType == 0x02,
            "contractType error"
        );

        uint256 balance = IERC721(_MOSSAI_Island_NFG_Address).balanceOf(
            msg.sender
        );

        require(
            balance > 0,
            "You must have an Island NFG in order to list an NFT"
        );

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

        emit eveSave(id);
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
            bytes1
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
            mossaiStorage.getBytes1(mossaiStorage.genKey("contractType", id))
        );
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
        }

        emit eveSave(id);
    }
}
