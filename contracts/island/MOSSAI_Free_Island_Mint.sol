pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Strings.sol";

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

import "@openzeppelin/contracts/utils/Strings.sol";

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import "../HyperAGI_Wallet_Account.sol";
import "../HyperAGI_Transaction_Cfg.sol";
import "./MOSSAI_Island.sol";
import "../utils/StrUtil.sol";

contract MOSSAI_Free_Island_Mint is OwnableUpgradeable {
    using Strings for *;
    using StrUtil for *;

    address public _islandAddress;
    address public _walletAccountAddress;
    address public _transactionCfgAddress;
    address public _islandNFTAddress;

    function initialize(address onlyOwner) public initializer {
        __Ownable_init(onlyOwner);
    }

    function setIslandAddress(address islandAddress) public onlyOwner {
        _islandAddress = islandAddress;
    }

    function setWalletAccountAddress(address walletAccountAddress) public onlyOwner {
        _walletAccountAddress = walletAccountAddress;
    }

    function setTransactionCfgAddress(address transactionCfgAddress) public onlyOwner {
        _transactionCfgAddress = transactionCfgAddress;
    }

    function setIslandNFTAddress(address islandNFTAddress) public onlyOwner {
        _islandNFTAddress = islandNFTAddress;
    }

    function setContractAddress(address[] memory contractaddressArray) public onlyOwner {
        require(contractaddressArray.length >= 4, "Insufficient addresses provided");
        setIslandAddress(contractaddressArray[0]);
        setWalletAccountAddress(contractaddressArray[1]);
        setTransactionCfgAddress(contractaddressArray[2]);
        setIslandNFTAddress(contractaddressArray[3]);
    }

    function mintIsland(uint32 coordinate, string memory islandName, string[] memory names, string[] memory symbols) public payable {
        uint256 mintIslandAmount = IHyperAGI_Transaction_Cfg(_transactionCfgAddress).getGasFee("mintIsland");

        require(msg.value == mintIslandAmount, "Insufficient gas fee");

        IHyperAGI_Wallet_Account walletAccountAddress = IHyperAGI_Wallet_Account(_walletAccountAddress);

        address _GasFeeCollectionWallet = walletAccountAddress._GasFeeCollectionWallet();
        require(_GasFeeCollectionWallet != address(0), "not set GasFeeCollectionWallet");

        uint256 balance = IERC721(_islandNFTAddress).balanceOf(msg.sender);

        require(balance == 0, "You have held the island and are not allowed to cast it again");

        if (mintIslandAmount > 0) {
            transferETH(payable(_GasFeeCollectionWallet), mintIslandAmount);

            walletAccountAddress.addAmount(mintIslandAmount);
        }

        MOSSAI_Island(_islandAddress).mint(coordinate, msg.sender, islandName, names, symbols);
    }

    function transferETH(address payable recipient, uint256 amount) private {
        require(address(this).balance >= amount, "Insufficient balance in contract");
        recipient.transfer(amount);
    }
}
