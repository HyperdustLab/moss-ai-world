pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import "./utils/StrUtil.sol";
import "./MOSSAI_NFT_Product.sol";
import "./MOSSAI_Storage.sol";
import "./HyperAGI_Transaction_Cfg.sol";
import "./HyperAGI_Wallet_Account.sol";

contract MOSSAI_NFT_Transaction is OwnableUpgradeable {
    using Strings for *;
    using StrUtil for *;

    address public _NFT_Product_Address;
    address public _walletAccountAddress;
    address public _transactionCfgAddress;
    address public _storageAddress;

    function initialize(address onlyOwner) public initializer {
        __Ownable_init(onlyOwner);
    }

    function setNFTProductAddress(address NFTProductAddress) public onlyOwner {
        _NFT_Product_Address = NFTProductAddress;
    }

    function setWalletAccountAddress(address walletAccountAddress) public onlyOwner {
        _walletAccountAddress = walletAccountAddress;
    }

    function setTransactionCfgAddress(address transactionCfgAddress) public onlyOwner {
        _transactionCfgAddress = transactionCfgAddress;
    }

    function setStorageAddress(address storageAddress) public onlyOwner {
        _storageAddress = storageAddress;
    }

    function setContractAddress(address[] memory contractaddressArray) public onlyOwner {
        require(contractaddressArray.length >= 4, "Insufficient addresses provided");
        setNFTProductAddress(contractaddressArray[0]);
        setWalletAccountAddress(contractaddressArray[1]);
        setTransactionCfgAddress(contractaddressArray[2]);
        setStorageAddress(contractaddressArray[3]);
    }

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

    function getTransactionRecord(uint256 id) public view returns (uint256, uint256, address, address, uint256, uint256, uint256, uint256, bytes32) {
        MOSSAI_Storage storageAddress = MOSSAI_Storage(_storageAddress);

        uint256 NFTProductId = storageAddress.getUint(storageAddress.genKey("NFTProductId", id));

        require(NFTProductId > 0, "not found");

        return (
            id,
            NFTProductId,
            storageAddress.getAddress(storageAddress.genKey("buyer", id)),
            storageAddress.getAddress(storageAddress.genKey("seller", id)),
            storageAddress.getUint(storageAddress.genKey("payAmount", id)),
            storageAddress.getUint(storageAddress.genKey("price", id)),
            storageAddress.getUint(storageAddress.genKey("num", id)),
            storageAddress.getUint(storageAddress.genKey("commission", id)),
            storageAddress.getBytes32(storageAddress.genKey("sid", id))
        );
    }

    function buyNFTProduct(uint256 NFTProductId, uint256 num) public payable {
        IHyperAGI_Wallet_Account walletAccountAddress = IHyperAGI_Wallet_Account(_walletAccountAddress);
        IHyperAGI_Transaction_Cfg transactionCfgAddress = IHyperAGI_Transaction_Cfg(_transactionCfgAddress);

        address _GasFeeCollectionWallet = walletAccountAddress._GasFeeCollectionWallet();

        require(_GasFeeCollectionWallet != address(0), "not set GasFeeCollectionWallet");

        require(num > 0, "num error");
        require(NFTProductId > 0, "NFTProductId error");

        MOSSAI_NFT_Product NFT_Product_Address = MOSSAI_NFT_Product(_NFT_Product_Address);

        MOSSAI_Storage storageAddress = MOSSAI_Storage(_storageAddressAddress);

        (, address owner, uint256 putawayNum, uint256 sellNum, address contractAddress, uint256 tokenId, uint256 price, bytes1 status, bytes1 contractType, bytes32 sid, uint256 allowBuyNum) = NFT_Product_Address.getNFTProduct(NFTProductId);

        if (allowBuyNum > 0) {
            string memory buyNumKey = string(abi.encode(NFTProductId.toString(), msg.sender.toHexString()));

            uint256 buyNum = storageAddress.getUint(buyNumKey);

            require(buyNum + num <= allowBuyNum, "exceeds the purchase limit");

            storageAddress.setUint(buyNumKey, buyNum + num);
        }

        require(status == 0x01, "status error");
        require(sellNum + num <= putawayNum, "in no stock");

        require(msg.sender != owner, "You can't buy your own products");

        uint256 amount = price * num;

        uint256 commission = transactionCfgAddress.getGasFee("NFT_Market");

        uint256 payAmount = amount + commission;

        require(msg.value == payAmount, "Insufficient gas fee");

        transferETH(owner, amount);

        if (commission > 0) {
            transferETH(_GasFeeCollectionWallet, commission);
            walletAccountAddress.addAmount(commission);
        }

        if (contractType == 0x01) {
            IERC721(contractAddress).safeTransferFrom(owner, msg.sender, tokenId);
        } else {
            IERC1155(contractAddress).safeTransferFrom(owner, msg.sender, tokenId, num, "0x0");
        }

        MOSSAINFTProductAddres.addSellNum(NFTProductId, num);

        uint256 id = storageAddress.getNextId();

        storageAddress.setUint(storageAddress.genKey("NFTProductId", id), NFTProductId);

        storageAddress.setAddress(storageAddress.genKey("buyer", id), msg.sender);
        storageAddress.setAddress(storageAddress.genKey("seller", id), owner);

        storageAddress.setUint(storageAddress.genKey("payAmount", id), payAmount);
        storageAddress.setUint(storageAddress.genKey("price", id), price);

        storageAddress.setUint(storageAddress.genKey("num", id), num);
        storageAddress.setUint(storageAddress.genKey("commission", id), commission);
        storageAddress.setBytes32(storageAddress.genKey("sid", id), sid);

        emit eveSave(id);
    }

    function transferETH(address payable recipient, uint256 amount) private {
        require(address(this).balance >= amount, "Insufficient balance in contract");
        recipient.transfer(amount);
    }
}
