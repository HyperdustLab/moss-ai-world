// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/utils/Strings.sol";

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "@openzeppelin/contracts/utils/Strings.sol";

import "../HyperAGI_Roles_Cfg.sol";
import "../HyperAGI_Wallet_Account.sol";
import "../HyperAGI_Transaction_Cfg.sol";

import "./Island_721.sol";
import "./Island_1155.sol";
import "../island/MOSSAI_Island_NFG.sol";
import "../island/MOSSAI_Island.sol";

import "../utils/StrUtil.sol";

contract Island_Mint is OwnableUpgradeable {
    address public _islandAddress;
    address public _walletAccountAddress;
    address public _transactionCfgAddress;
    address public _iandNFGAddress;
    address public _rolesCfgAddress;

    using Strings for *;
    using StrUtil for *;

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

    function setIandNFGAddress(address iandNFGAddress) public onlyOwner {
        _iandNFGAddress = iandNFGAddress;
    }

    function setRolesCfgAddress(address rolesCfgAddress) public onlyOwner {
        _rolesCfgAddress = rolesCfgAddress;
    }

    function setContractAddress(address[] memory contractaddressArray) public onlyOwner {
        require(contractaddressArray.length >= 5, "Insufficient addresses provided");
        setIslandAddress(contractaddressArray[0]);
        setWalletAccountAddress(contractaddressArray[1]);
        setTransactionCfgAddress(contractaddressArray[2]);
        setIandNFGAddress(contractaddressArray[3]);
        setRolesCfgAddress(contractaddressArray[4]);
    }

    function mint721(uint256 islandId, string memory tokenURI) public payable {
        IHyperAGI_Wallet_Account walletAccountAddress = IHyperAGI_Wallet_Account(_walletAccountAddress);

        uint256 gasFee = IHyperAGI_Transaction_Cfg(_transactionCfgAddress).getGasFee("mintNFT");

        require(msg.value == gasFee, "Insufficient gas fee");

        address _GasFeeCollectionWallet = walletAccountAddress._GasFeeCollectionWallet();

        require(_GasFeeCollectionWallet != address(0), "not set GasFeeCollectionWallet");
        (, , , , , address erc721Address, , , uint256 seed, , ) = MOSSAI_Island(_islandAddress).getIsland(islandId);
        address seedOwer = MOSSAI_Island_NFG(_iandNFGAddress).getSeedOwer(seed);
        require(seedOwer == msg.sender, "not island owner");

        if (gasFee > 0) {
            transferETH(_GasFeeCollectionWallet, gasFee);

            IHyperAGI_Wallet_Account(_walletAccountAddress).addAmount(gasFee);
        }

        Island_721(erc721Address).safeMint(msg.sender, tokenURI);
    }

    function mint1155(uint256 islandId, uint256 id, uint256 amount, string memory tokenURI) public {
        IWalletAccount walletAccountAddress = IWalletAccount(_WalletAccountAddress);

        uint256 gasFee = IHyperAGI_Transaction_Cfg(_transactionCfgAddress).getGasFee("mintNFT");

        require(msg.value == gasFee, "Insufficient gas fee");

        address _GasFeeCollectionWallet = walletAccountAddress._GasFeeCollectionWallet();

        require(_GasFeeCollectionWallet != address(0), "not set GasFeeCollectionWallet");
        (, , , , , , address erc1155Address, , uint256 seed, , ) = MOSSAI_Island(_islandAddress).getIsland(islandId);
        address seedOwer = MOSSAI_Island_NFG(_MOSSAIIslandNFGAddress).getSeedOwer(seed);
        require(seedOwer == msg.sender, "not island owner");

        if (gasFee > 0) {
            transferETH(_GasFeeCollectionWallet, gasFee);
            IHyperAGI_Wallet_Account(_walletAccountAddress).addAmount(gasFee);
        }

        Island_1155(erc1155Address).mint(msg.sender, id, amount, tokenURI, "");
    }

    function transferETH(address payable recipient, uint256 amount) private {
        require(address(this).balance >= amount, "Insufficient balance in contract");
        recipient.transfer(amount);
    }
}
