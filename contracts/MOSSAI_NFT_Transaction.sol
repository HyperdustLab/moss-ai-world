pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import "./utils/StrUtil.sol";
import "./MOSSAI_NFT_Product.sol";

import "./MOSSAI_Storage.sol";

abstract contract IWalletAccount {
    function addAmount(uint256 amount) public {}

    function _GasFeeCollectionWallet() public view returns (address) {}
}

abstract contract IHyperdustTransactionCfg {
    function getGasFee(string memory func) public view returns (uint256) {}
}

contract MOSSAI_NFT_Transaction is OwnableUpgradeable {
    using Strings for *;
    using StrUtil for *;

    address public _MOSSAI_NFT_Product_Address;
    address public _walletAccountAddress;
    address public _HyperdustTransactionCfgAddress;
    address public _HYDTTokenAddress;
    address public _MOSSAIStorageAddress;

    function initialize(address onlyOwner) public initializer {
        __Ownable_init(onlyOwner);
    }

    function setWalletAccountAddress(address walletAccountAddress) public onlyOwner {
        _walletAccountAddress = walletAccountAddress;
    }

    function setHyperdustTransactionCfgAddress(address HyperdustTransactionCfgAddress) public onlyOwner {
        _HyperdustTransactionCfgAddress = HyperdustTransactionCfgAddress;
    }

    function setHYDTTokenAddress(address HYDTTokenAddress) public onlyOwner {
        _HYDTTokenAddress = HYDTTokenAddress;
    }

    function setMOSSAIStorageAddress(address MOSSAIStorageAddress) public onlyOwner {
        _MOSSAIStorageAddress = MOSSAIStorageAddress;
    }

    function setMOSSAINFTProductAddress(address MOSSAI_NFT_Product_Address) public onlyOwner {
        _MOSSAI_NFT_Product_Address = MOSSAI_NFT_Product_Address;
    }

    function setContractAddress(address[] memory contractaddressArray) public onlyOwner {
        _MOSSAI_NFT_Product_Address = contractaddressArray[0];
        _walletAccountAddress = contractaddressArray[1];
        _HyperdustTransactionCfgAddress = contractaddressArray[2];
        _HYDTTokenAddress = contractaddressArray[3];
        _MOSSAIStorageAddress = contractaddressArray[4];
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
        MOSSAI_Storage mossaiStorage = MOSSAI_Storage(_MOSSAIStorageAddress);

        uint256 NFTProductId = mossaiStorage.getUint(mossaiStorage.genKey("NFTProductId", id));

        require(NFTProductId > 0, "not found");

        return (
            id,
            NFTProductId,
            mossaiStorage.getAddress(mossaiStorage.genKey("buyer", id)),
            mossaiStorage.getAddress(mossaiStorage.genKey("seller", id)),
            mossaiStorage.getUint(mossaiStorage.genKey("payAmount", id)),
            mossaiStorage.getUint(mossaiStorage.genKey("price", id)),
            mossaiStorage.getUint(mossaiStorage.genKey("num", id)),
            mossaiStorage.getUint(mossaiStorage.genKey("commission", id)),
            mossaiStorage.getBytes32(mossaiStorage.genKey("sid", id))
        );
    }

    function buyNFTProduct(uint256 NFTProductId, uint256 num) public {
        IWalletAccount walletAccountAddress = IWalletAccount(_walletAccountAddress);

        address _GasFeeCollectionWallet = walletAccountAddress._GasFeeCollectionWallet();

        require(_GasFeeCollectionWallet != address(0), "not set GasFeeCollectionWallet");

        require(num > 0, "num error");
        require(NFTProductId > 0, "NFTProductId error");

        MOSSAI_NFT_Product MOSSAINFTProductAddres = MOSSAI_NFT_Product(_MOSSAI_NFT_Product_Address);

        MOSSAI_Storage mossaiStorage = MOSSAI_Storage(_MOSSAIStorageAddress);

        (, address owner, uint256 putawayNum, uint256 sellNum, address contractAddress, uint256 tokenId, uint256 price, bytes1 status, bytes1 contractType, bytes32 sid, uint256 allowBuyNum) = MOSSAINFTProductAddres.getNFTProductV2(NFTProductId);

        if (allowBuyNum > 0) {
            string memory buyNumKey = string(abi.encode(NFTProductId.toString(), msg.sender.toHexString()));

            uint256 buyNum = mossaiStorage.getUint(buyNumKey);

            require(buyNum + num <= allowBuyNum, "exceeds the purchase limit");

            mossaiStorage.setUint(buyNumKey, buyNum + num);
        }

        require(status == 0x01, "status error");
        require(sellNum + num <= putawayNum, "in no stock");

        require(msg.sender != owner, "You can't buy your own products");

        uint256 amount = price * num;

        uint256 commission = IHyperdustTransactionCfg(_HyperdustTransactionCfgAddress).getGasFee("NFT_Market");

        uint256 payAmount = amount + commission;

        IERC20 erc20 = IERC20(_HYDTTokenAddress);

        require(erc20.allowance(msg.sender, address(this)) >= payAmount, "Insufficient authorized amount");

        require(erc20.balanceOf(msg.sender) >= payAmount, "balance error");

        erc20.transferFrom(msg.sender, owner, amount);

        if (commission > 0) {
            erc20.transferFrom(msg.sender, _GasFeeCollectionWallet, commission);

            IWalletAccount(_walletAccountAddress).addAmount(commission);
        }

        if (contractType == 0x01) {
            IERC721(contractAddress).safeTransferFrom(owner, msg.sender, tokenId);
        } else {
            IERC1155(contractAddress).safeTransferFrom(owner, msg.sender, tokenId, num, "0x0");
        }

        MOSSAINFTProductAddres.addSellNum(NFTProductId, num);

        uint256 id = mossaiStorage.getNextId();

        mossaiStorage.setUint(mossaiStorage.genKey("NFTProductId", id), NFTProductId);

        mossaiStorage.setAddress(mossaiStorage.genKey("buyer", id), msg.sender);
        mossaiStorage.setAddress(mossaiStorage.genKey("seller", id), owner);

        mossaiStorage.setUint(mossaiStorage.genKey("payAmount", id), payAmount);
        mossaiStorage.setUint(mossaiStorage.genKey("price", id), price);

        mossaiStorage.setUint(mossaiStorage.genKey("num", id), num);
        mossaiStorage.setUint(mossaiStorage.genKey("commission", id), commission);
        mossaiStorage.setBytes32(mossaiStorage.genKey("sid", id), sid);

        emit eveSave(id);
    }
}
