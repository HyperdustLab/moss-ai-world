pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Strings.sol";

import "@openzeppelin/contracts/access/Ownable.sol";

import "@openzeppelin/contracts/utils/Counters.sol";

import "../utils/StrUtil.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../MOSSAI_Roles_Cfg.sol";

abstract contract ITransactionCfg {
    function get(string memory func) public view returns (uint256) {}
}

abstract contract IWalletAccountAddress {
    function addAmount(uint256 amount) public {}
}

contract IslandAssetsCfg is Ownable {
    using Strings for *;
    using StrUtil for *;
    address public _transactionCfgAddress;

    address public _HYDTTokenAddress;

    address public _walletAccountAddres;

    address public _MOSSAIRolesCfgAddress;

    address public _HYDTPriceAddress;

    function setMOSSAIRolesCfgAddress(
        address rolesCfgAddress
    ) public onlyOwner {
        _MOSSAIRolesCfgAddress = rolesCfgAddress;
    }

    function setHYDTTokenAddress(address HYDTTokenAddress) public onlyOwner {
        _HYDTTokenAddress = HYDTTokenAddress;
    }

    function setWalletAccountAddres(
        address walletAccountAddres
    ) public onlyOwner {
        _walletAccountAddres = walletAccountAddres;
    }

    function setTransactionCfgAddress(
        address transactionCfgAddress
    ) public onlyOwner {
        _transactionCfgAddress = transactionCfgAddress;
    }

    function setContractAddress(
        address[] memory contractaddressArray
    ) public onlyOwner {
        _transactionCfgAddress = contractaddressArray[0];
        _HYDTTokenAddress = contractaddressArray[1];
        _walletAccountAddres = contractaddressArray[2];
        _MOSSAIRolesCfgAddress = contractaddressArray[3];
        _HYDTPriceAddress = contractaddressArray[4];
    }

    function getAddressConfList()
        public
        view
        returns (
            address transactionCfgAddress,
            address erc20Address,
            address walletAccountAddres,
            address rolesCfgAddress,
            address HYDTPriceAddress
        )
    {
        return (
            _transactionCfgAddress,
            _HYDTTokenAddress,
            _walletAccountAddres,
            _MOSSAIRolesCfgAddress,
            _HYDTPriceAddress
        );
    }
}
