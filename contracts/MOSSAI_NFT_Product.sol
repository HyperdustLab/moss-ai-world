pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

import "./utils/StrUtil.sol";
import "./MOSSAI_Roles_Cfg.sol";

/**
 * @title MOSSAI_NFT_Product
 * @dev This contract represents an NFT product marketplace where users can save, retrieve, and sell NFT products.
 */
contract MOSSAI_NFT_Product is Ownable {
    using Strings for *;
    using StrUtil for *;

    mapping(bytes32 => uint256) public _nftProductMap;

    NFTProduct[] public _NFTProducts;

    address public _MOSSAI_NFT_Market_Address;
    address public _MOSSAIRolesCfgAddress;
    address public _MOSSAI_Island_NFG_Address;
    using Counters for Counters.Counter;
    Counters.Counter private _id;
    /**
     * @dev Struct representing an NFT product.
     * @param id The unique identifier of the product.
     * @param owner The address of the owner of the product.
     * @param putawayNum The number of times the product has been put up for sale.
     * @param sellNum The number of times the product has been sold.
     * @param contractAddress The address of the NFT contract.
     * @param tokenId The unique identifier of the NFT.
     * @param price The price of the product.
     * @param status The status of the product.
     * @param contractType The type of NFT contract.
     */
    struct NFTProduct {
        uint256 id;
        address owner;
        uint32 putawayNum;
        uint32 sellNum;
        address contractAddress;
        uint256 tokenId;
        uint256 price;
        bytes1 status;
        bytes1 contractType;
    }

    event eveSave(uint256 id);

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

    function setContractAddress(
        address[] memory contractaddressArray
    ) public onlyOwner {
        _MOSSAI_NFT_Market_Address = contractaddressArray[0];
        _MOSSAIRolesCfgAddress = contractaddressArray[1];
        _MOSSAI_Island_NFG_Address = contractaddressArray[2];
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

        bytes32 key = keccak256(
            abi.encodePacked(contractAddress, tokenId, msg.sender)
        );

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

        uint256 id = _nftProductMap[key];

        NFTProduct memory nftProduct;

        if (id == 0) {
            _id.increment();
            id = _id.current();

            _nftProductMap[key] = id;

            nftProduct = NFTProduct({
                id: id,
                owner: msg.sender,
                putawayNum: putawayNum,
                contractAddress: contractAddress,
                sellNum: 0,
                tokenId: tokenId,
                price: price,
                status: status,
                contractType: contractType
            });

            _NFTProducts.push(nftProduct);

            _nftProductMap[key] = id;
        } else {
            _NFTProducts[id - 1].status = status;
            _NFTProducts[id - 1].putawayNum = putawayNum;
            _NFTProducts[id - 1].price = price;

            require(_NFTProducts[id - 1].owner == msg.sender, "not owner");
        }

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
            uint32,
            uint32,
            address,
            uint256,
            uint256,
            bytes1,
            bytes1
        )
    {
        NFTProduct memory nftProduct = _NFTProducts[id - 1];

        return (
            nftProduct.id,
            nftProduct.owner,
            nftProduct.putawayNum,
            nftProduct.sellNum,
            nftProduct.contractAddress,
            nftProduct.tokenId,
            nftProduct.price,
            nftProduct.status,
            nftProduct.contractType
        );
    }

    function getNFTProductObj(
        uint256 id
    ) public view returns (NFTProduct memory) {
        return _NFTProducts[id - 1];
    }

    function addSellNum(uint256 id, uint32 num) public {
        require(
            MOSSAI_Roles_Cfg(_MOSSAIRolesCfgAddress).hasAdminRole(msg.sender),
            "not admin role"
        );

        NFTProduct memory nftProduct = _NFTProducts[id - 1];

        require(
            nftProduct.sellNum + num <= nftProduct.putawayNum,
            "Insufficient stock"
        );

        _NFTProducts[id - 1].sellNum += num;

        if (nftProduct.sellNum + num == nftProduct.putawayNum) {
            _NFTProducts[id - 1].status = 0x00;
        }

        emit eveSave(id);
    }
}
