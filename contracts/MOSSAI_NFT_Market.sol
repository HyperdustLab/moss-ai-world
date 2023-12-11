/**
 * @title MOSSAI_NFT_Market
 * @dev This contract represents the marketplace for MOSSAI NFT products. It allows users to buy NFT products using HYDT tokens, and records transaction details in a transaction record struct.
 */
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

import "./utils/StrUtil.sol";
import "./MOSSAI_NFT_Product.sol";

abstract contract IWalletAccount {
    function addAmount(uint256 amount) public {}
}

abstract contract IHyperdustTransactionCfg {
    function getGasFee(string memory func) public view returns (uint256) {}
}

contract MOSSAI_NFT_Market is Ownable {
    using Strings for *;
    using StrUtil for *;

    using Counters for Counters.Counter;

    Counters.Counter private _id;

    mapping(string => uint256) public _nftProductMap;

    TransactionRecord[] public _transactionRecords;
    /**
     * @dev Contract variables for MOSSAI NFT Market.
     */
    address public _MOSSAI_NFT_Product_Address;
    address public _walletAccountAddress;
    address public _HyperdustTransactionCfgAddress;
    address public _HYDTTokenAddress;

    function setMOSSAINFTProductAddress(
        address MOSSAI_NFT_Product_Address
    ) public onlyOwner {
        _MOSSAI_NFT_Product_Address = MOSSAI_NFT_Product_Address;
    }

    function setWalletAccountAddress(
        address walletAccountAddress
    ) public onlyOwner {
        _walletAccountAddress = walletAccountAddress;
    }

    function setHyperdustTransactionCfgAddress(
        address HyperdustTransactionCfgAddress
    ) public onlyOwner {
        _HyperdustTransactionCfgAddress = HyperdustTransactionCfgAddress;
    }

    function setHYDTTokenAddress(address HYDTTokenAddress) public onlyOwner {
        _HYDTTokenAddress = HYDTTokenAddress;
    }

    function setContractAddress(
        address[] memory contractaddressArray
    ) public onlyOwner {
        _MOSSAI_NFT_Product_Address = contractaddressArray[0];
        _walletAccountAddress = contractaddressArray[1];
        _HyperdustTransactionCfgAddress = contractaddressArray[2];
        _HYDTTokenAddress = contractaddressArray[3];
    }

    /**
     * @dev Struct representing a transaction record in the MOSSAI NFT Market.
     * @param id The unique identifier of the transaction.
     * @param NFTProductId The ID of the NFT product being transacted.
     * @param buyer The address of the buyer in the transaction.
     * @param seller The address of the seller in the transaction.
     * @param amount The amount of NFT products being transacted.
     * @param price The price of each NFT product in the transaction.
     * @param num The number of NFT products being transacted.
     * @param commission The commission fee charged by the platform for the transaction.
     */
    struct TransactionRecord {
        uint256 id;
        uint256 NFTProductId;
        address buyer;
        address seller;
        uint256 amount;
        uint256 price;
        uint32 num;
        uint256 commission;
    }

    event eveSave(uint256 id);

    /**
     * @dev Buy NFT product from the market.
     * @param NFTProductId The ID of the NFT product to buy.
     * @param num The number of NFT products to buy.
     */
    function buyNFTProduct(uint256 NFTProductId, uint32 num) public {
        require(num > 0, "num error");
        require(NFTProductId > 0, "NFTProductId error");

        MOSSAI_NFT_Product MOSSAINFTProductAddres = MOSSAI_NFT_Product(
            _MOSSAI_NFT_Product_Address
        );

        MOSSAI_NFT_Product.NFTProduct memory nftProduct = MOSSAINFTProductAddres
            .getNFTProductObj(NFTProductId);

        require(nftProduct.status == 0x01, "status error");
        require(
            nftProduct.sellNum + num <= nftProduct.putawayNum,
            "in no stock"
        );

        uint256 amount = nftProduct.price * num;

        uint256 commission = IHyperdustTransactionCfg(
            _HyperdustTransactionCfgAddress
        ).getGasFee("NFT_Market");

        uint256 payAmount = amount + commission;

        IERC20 erc20 = IERC20(_HYDTTokenAddress);

        require(
            erc20.allowance(msg.sender, address(this)) >= payAmount,
            "Insufficient authorized amount"
        );

        require(erc20.balanceOf(msg.sender) >= payAmount, "balance error");

        erc20.transferFrom(msg.sender, nftProduct.owner, amount);
        erc20.transferFrom(msg.sender, _walletAccountAddress, commission);

        IWalletAccount(_walletAccountAddress).addAmount(commission);

        if (nftProduct.contractType == 0x01) {
            IERC721(nftProduct.contractAddress).safeTransferFrom(
                nftProduct.owner,
                msg.sender,
                nftProduct.tokenId
            );
        } else {
            IERC1155(nftProduct.contractAddress).safeTransferFrom(
                nftProduct.owner,
                msg.sender,
                nftProduct.tokenId,
                num,
                "0x0"
            );
        }

        MOSSAINFTProductAddres.addSellNum(nftProduct.id, num);

        _id.increment();
        uint256 id = _id.current();

        TransactionRecord memory transactionRecord = TransactionRecord(
            id,
            NFTProductId,
            msg.sender,
            nftProduct.owner,
            payAmount,
            nftProduct.price,
            num,
            commission
        );

        _transactionRecords.push(transactionRecord);

        emit eveSave(id);
    }

    function getTransactionRecord(
        uint256 id
    )
        public
        view
        returns (
            uint256,
            uint256,
            address,
            address,
            uint256,
            uint256,
            uint32,
            uint256
        )
    {
        TransactionRecord memory transactionRecord = _transactionRecords[
            id - 1
        ];

        return (
            transactionRecord.id,
            transactionRecord.NFTProductId,
            transactionRecord.buyer,
            transactionRecord.seller,
            transactionRecord.amount,
            transactionRecord.price,
            transactionRecord.num,
            transactionRecord.commission
        );
    }
}
