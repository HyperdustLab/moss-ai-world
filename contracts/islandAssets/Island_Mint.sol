// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/utils/Strings.sol";

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "@openzeppelin/contracts/utils/Strings.sol";

import "../Hyperdust_Roles_Cfg.sol";

import "./Island_721.sol";
import "./Island_1155.sol";
import "../island/MOSSAI_Island_NFG.sol";

import "../utils/StrUtil.sol";

abstract contract IWalletAccount {
    function addAmount(uint256 amount) public {}

    function _GasFeeCollectionWallet() public view returns (address) {}
}

abstract contract IHyperdustTransactionCfg {
    function getGasFee(string memory func) public view returns (uint256) {}
}

abstract contract IMOSSAIIsland {
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
            uint256,
            bytes32,
            string memory
        )
    {}
}

contract Island_Mint is OwnableUpgradeable {
    address public _MOSSAIIslandAddres;
    address public _WalletAccountAddress;
    address public _HyperdustTransactionCfgAddress;
    address public _erc20Address;
    address public _MOSSAIIslandNFGAddress;
    address public _HyperdustRolesCfgAddress;

    using Strings for *;
    using StrUtil for *;

    function initialize() public initializer {
        __Ownable_init(msg.sender);
    }

    function setMOSSAIIslandAddres(
        address MOSSAIIslandAddres
    ) public onlyOwner {
        _MOSSAIIslandAddres = MOSSAIIslandAddres;
    }

    function setWalletAccountAddress(
        address WalletAccountAddress
    ) public onlyOwner {
        _WalletAccountAddress = WalletAccountAddress;
    }

    function setHyperdustTransactionCfgAddress(
        address HyperdustTransactionCfgAddress
    ) public onlyOwner {
        _HyperdustTransactionCfgAddress = HyperdustTransactionCfgAddress;
    }

    function setErc20Address(address erc20Address) public onlyOwner {
        _erc20Address = erc20Address;
    }

    function setMOSSAIIslandNFGAddress(
        address MOSSAIIslandNFGAddress
    ) public onlyOwner {
        _MOSSAIIslandNFGAddress = MOSSAIIslandNFGAddress;
    }

    function setHyperdustRolesCfgAddress(
        address HyperdustRolesCfgAddress
    ) public onlyOwner {
        _HyperdustRolesCfgAddress = HyperdustRolesCfgAddress;
    }

    function setContractAddress(
        address[] memory contractaddressArray
    ) public onlyOwner {
        _MOSSAIIslandAddres = contractaddressArray[0];
        _WalletAccountAddress = contractaddressArray[1];
        _HyperdustTransactionCfgAddress = contractaddressArray[2];
        _erc20Address = contractaddressArray[3];
        _MOSSAIIslandNFGAddress = contractaddressArray[4];
        _HyperdustRolesCfgAddress = contractaddressArray[5];
    }

    function mint721(uint256 islandId, string memory tokenURI) public {
        IWalletAccount walletAccountAddress = IWalletAccount(
            _WalletAccountAddress
        );

        address _GasFeeCollectionWallet = walletAccountAddress
            ._GasFeeCollectionWallet();

        require(
            _GasFeeCollectionWallet != address(0),
            "not set GasFeeCollectionWallet"
        );
        (, , , , , address erc721Address, , , uint256 seed, , ) = IMOSSAIIsland(
            _MOSSAIIslandAddres
        ).getIsland(islandId);
        address seedOwer = MOSSAI_Island_NFG(_MOSSAIIslandNFGAddress)
            .getSeedOwer(seed);
        require(seedOwer == msg.sender, "not island owner");
        IERC20 erc20 = IERC20(_erc20Address);
        uint256 balance = erc20.balanceOf(msg.sender);
        uint256 gasFee = IHyperdustTransactionCfg(
            _HyperdustTransactionCfgAddress
        ).getGasFee("mintNFT");
        require(balance >= gasFee, "not enough balance");
        uint256 allowance = erc20.allowance(msg.sender, address(this));
        require(allowance >= gasFee, "not enough allowance");

        if (gasFee > 0) {
            erc20.transferFrom(msg.sender, _GasFeeCollectionWallet, gasFee);
            IWalletAccount(_WalletAccountAddress).addAmount(gasFee);
        }

        Island_721(erc721Address).safeMint(msg.sender, tokenURI);
    }

    function mint1155(
        uint256 islandId,
        uint256 id,
        uint256 amount,
        string memory tokenURI
    ) public {
        IWalletAccount walletAccountAddress = IWalletAccount(
            _WalletAccountAddress
        );

        address _GasFeeCollectionWallet = walletAccountAddress
            ._GasFeeCollectionWallet();

        require(
            _GasFeeCollectionWallet != address(0),
            "not set GasFeeCollectionWallet"
        );
        (
            ,
            ,
            ,
            ,
            ,
            ,
            address erc1155Address,
            ,
            uint256 seed,
            ,

        ) = IMOSSAIIsland(_MOSSAIIslandAddres).getIsland(islandId);
        address seedOwer = MOSSAI_Island_NFG(_MOSSAIIslandNFGAddress)
            .getSeedOwer(seed);
        require(seedOwer == msg.sender, "not island owner");
        IERC20 erc20 = IERC20(_erc20Address);
        uint256 balance = erc20.balanceOf(msg.sender);
        uint256 gasFee = IHyperdustTransactionCfg(
            _HyperdustTransactionCfgAddress
        ).getGasFee("mint");
        require(balance >= gasFee, "not enough balance");
        uint256 allowance = erc20.allowance(msg.sender, address(this));
        require(allowance >= gasFee, "not enough allowance");

        if (gasFee > 0) {
            erc20.transferFrom(msg.sender, _GasFeeCollectionWallet, gasFee);
            IWalletAccount(_WalletAccountAddress).addAmount(gasFee);
        }

        Island_1155(erc1155Address).mint(msg.sender, id, amount, tokenURI, "");
    }
}
