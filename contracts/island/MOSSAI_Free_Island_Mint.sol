pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Strings.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

import "@openzeppelin/contracts/utils/Strings.sol";

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import "./MOSSAI_Island.sol";

import "../utils/StrUtil.sol";

abstract contract IWalletAccount {
    function addAmount(uint256 amount) public {}

    function _GasFeeCollectionWallet() public view returns (address) {}
}

abstract contract IHyperdustTransactionCfg {
    function getGasFee(string memory func) public view returns (uint256) {}
}

contract MOSSAI_Free_Island_Mint is OwnableUpgradeable {
    using Strings for *;
    using StrUtil for *;

    address public _MOSSAIIslandAddres;
    address public _WalletAccountAddress;
    address public _HyperdustTransactionCfgAddress;
    address public _erc20Address;
    address public _MOSSAIIslandNFGAddress;

    function initialize(address onlyOwner) public initializer {
        __Ownable_init(onlyOwner);
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

    function setHyperdustTransactionCfg(
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

    function setContractAddress(
        address[] memory contractaddressArray
    ) public onlyOwner {
        _MOSSAIIslandAddres = contractaddressArray[0];
        _WalletAccountAddress = contractaddressArray[1];
        _HyperdustTransactionCfgAddress = contractaddressArray[2];
        _erc20Address = contractaddressArray[3];
        _MOSSAIIslandNFGAddress = contractaddressArray[4];
    }

    function mintIsland(
        uint32 coordinate,
        string memory islandName,
        string[] memory names,
        string[] memory symbols
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

        uint256 balance = IERC721(_MOSSAIIslandNFGAddress).balanceOf(
            msg.sender
        );

        require(
            balance == 0,
            "You have held the island and are not allowed to cast it again"
        );

        IERC20 erc20 = IERC20(_erc20Address);

        uint256 mintIslandAmount = IHyperdustTransactionCfg(
            _HyperdustTransactionCfgAddress
        ).getGasFee("mintIsland");

        uint256 amount = erc20.allowance(msg.sender, address(this));

        require(amount >= mintIslandAmount, "Insufficient authorized amount");

        if (mintIslandAmount > 0) {
            erc20.transferFrom(
                msg.sender,
                _WalletAccountAddress,
                mintIslandAmount
            );

            walletAccountAddress.addAmount(mintIslandAmount);
        }


        MOSSAI_Island(_MOSSAIIslandAddres).mint(
            coordinate,
            msg.sender,
            islandName,
            names,
            symbols
        );
    }
}
