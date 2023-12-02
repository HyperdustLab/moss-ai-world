pragma solidity ^0.8.0;
import "./MOSSAI_Island.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import "@openzeppelin/contracts/access/Ownable.sol";

import "@openzeppelin/contracts/utils/Counters.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

abstract contract IWalletAccount {
    function addAmount(uint256 amount) public {}
}

abstract contract IHyperdustTransactionCfg {
    function getGasFee(string memory func) public view returns (uint256) {}
}

contract MOSSAI_Free_Island_Mint is Ownable {
    address public _MOSSAIIslandAddres;
    address public _WalletAccountAddress;
    address public _HyperdustTransactionCfgAddress;
    address public _erc20Address;

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

    function setContractAddress(
        address[] memory contractaddressArray
    ) public onlyOwner {
        _MOSSAIIslandAddres = contractaddressArray[0];
        _WalletAccountAddress = contractaddressArray[1];
        _HyperdustTransactionCfgAddress = contractaddressArray[2];
        _erc20Address = contractaddressArray[3];
    }

    function mintIsland(uint32 coordinate) public {
        IERC20 erc20 = IERC20(_erc20Address);

        uint256 mintIslandAmount = IHyperdustTransactionCfg(
            _HyperdustTransactionCfgAddress
        ).getGasFee("mintIsland");

        uint256 amount = erc20.allowance(msg.sender, address(this));

        require(amount >= mintIslandAmount, "Insufficient authorized amount");

        erc20.transferFrom(msg.sender, _WalletAccountAddress, mintIslandAmount);

        IWalletAccount walletAccountAddress = IWalletAccount(
            _WalletAccountAddress
        );

        walletAccountAddress.addAmount(mintIslandAmount);

        MOSSAI_Island(_MOSSAIIslandAddres).mint(coordinate, msg.sender);
    }
}
