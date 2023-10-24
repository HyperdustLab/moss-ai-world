pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./utils/StrUtil.sol";
import "./MOSSAI_Roles_Cfg.sol";

abstract contract IWalletAccount {
    function addAmount(uint256 amount) public {}
}

abstract contract IERC721 {
    function safeMint(address to, string memory uri) public returns (uint256) {}
}

abstract contract IERC1155 {
    function mint(
        address to,
        uint256 id,
        uint256 amount,
        string memory tokenURI,
        bytes calldata data
    ) public virtual {}
}

contract MOSSAI_mNFT_Mint is Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _id;

    using Strings for *;
    using StrUtil for *;

    address public _MOSSAIRolesCfgAddress;
    address public _HYDTTokenAddress;
    address public _walletAccountAddres;

    struct MintInfo {
        uint256 id;
        string tokenURI;
        uint256 price;
        address contractAddress;
        uint256 tokenId;
        uint8 contractType;
        uint256 mintNum;
        uint256 allowNum;
    }

    event eveSave(uint256 id);

    event eveMint(
        uint256 id,
        address account,
        uint256 mintNum,
        uint256 price,
        uint256 amount
    );

    event eveDelete(uint256 id);

    MintInfo[] public _mintInfos;

    function setMOSSAIRolesCfgAddress(
        address MOSSAIRolesCfgAddress
    ) public onlyOwner {
        _MOSSAIRolesCfgAddress = MOSSAIRolesCfgAddress;
    }

    function setHYDTTokenAddress(address HYDTTokenAddress) public onlyOwner {
        _HYDTTokenAddress = HYDTTokenAddress;
    }

    function setWalletAccountAddres(
        address walletAccountAddres
    ) public onlyOwner {
        _walletAccountAddres = walletAccountAddres;
    }

    function setContractAddress(
        address[] memory contractaddressArray
    ) public onlyOwner {
        _MOSSAIRolesCfgAddress = contractaddressArray[0];
        _HYDTTokenAddress = contractaddressArray[1];
        _walletAccountAddres = contractaddressArray[2];
    }

    function addMintInfo(
        string memory tokenURI,
        uint256 price,
        address contractAddress,
        uint256 tokenId,
        uint8 contractType,
        uint256 allowNum
    ) public {
        require(
            MOSSAI_Roles_Cfg(_MOSSAIRolesCfgAddress).hasAdminRole(msg.sender),
            "not admin role"
        );
        _id.increment();
        uint256 id = _id.current();
        _mintInfos.push(
            MintInfo(
                id,
                tokenURI,
                price,
                contractAddress,
                tokenId,
                contractType,
                0,
                allowNum
            )
        );

        emit eveSave(id);
    }

    function updateNFT(
        uint256 id,
        string memory tokenURI,
        uint256 price,
        address contractAddress,
        uint256 tokenId,
        uint8 contractType,
        uint256 allowNum
    ) public {
        require(
            MOSSAI_Roles_Cfg(_MOSSAIRolesCfgAddress).hasAdminRole(msg.sender),
            "not admin role"
        );
        for (uint256 i = 0; i < _mintInfos.length; i++) {
            if (_mintInfos[i].id == id) {
                _mintInfos[i].tokenURI = tokenURI;
                _mintInfos[i].price = price;
                _mintInfos[i].contractAddress = contractAddress;
                _mintInfos[i].tokenId = tokenId;
                _mintInfos[i].contractType = contractType;
                _mintInfos[i].allowNum = allowNum;

                emit eveSave(id);

                return;
            }
        }

        revert("NFT does not exist");
    }

    function getMintInfo(
        uint256 id
    )
        public
        view
        returns (
            uint256,
            string memory,
            uint256,
            address,
            uint256,
            uint8,
            uint256,
            uint256
        )
    {
        for (uint256 i = 0; i < _mintInfos.length; i++) {
            if (_mintInfos[i].id == id) {
                return (
                    _mintInfos[i].id,
                    _mintInfos[i].tokenURI,
                    _mintInfos[i].price,
                    _mintInfos[i].contractAddress,
                    _mintInfos[i].tokenId,
                    _mintInfos[i].contractType,
                    _mintInfos[i].mintNum,
                    _mintInfos[i].allowNum
                );
            }
        }
        revert("NFT does not exist");
    }

    function deleteMintInfo(uint256 id) public {
        require(
            MOSSAI_Roles_Cfg(_MOSSAIRolesCfgAddress).hasAdminRole(msg.sender),
            "not admin role"
        );
        for (uint256 i = 0; i < _mintInfos.length; i++) {
            if (_mintInfos[i].id == id) {
                _mintInfos[i] = _mintInfos[_mintInfos.length - 1];
                _mintInfos.pop();
                emit eveDelete(id);
                return;
            }
        }

        revert("NFT does not exist");
    }

    function mint(uint256 id, uint256 num) public {
        IERC20 erc20 = IERC20(_HYDTTokenAddress);
        IWalletAccount walletAccountAddress = IWalletAccount(
            _walletAccountAddres
        );

        MintInfo memory mintInfo;

        for (uint256 i = 0; i < _mintInfos.length; i++) {
            if (_mintInfos[i].id == id) {
                mintInfo = _mintInfos[i];
                break;
            }
        }

        require(mintInfo.id > 0, "NFT does not exist");

        uint256 amount = erc20.allowance(msg.sender, address(this));

        require(
            amount >= mintInfo.price * num,
            "Insufficient authorized amount"
        );

        require(
            mintInfo.allowNum >= mintInfo.mintNum + num,
            "Insufficient inventory"
        );

        erc20.transferFrom(
            msg.sender,
            _walletAccountAddres,
            mintInfo.price * num
        );

        walletAccountAddress.addAmount(mintInfo.price * num);

        if (mintInfo.contractType == 1) {
            for (uint i = 0; i < num; i++) {
                IERC721(mintInfo.contractAddress).safeMint(
                    msg.sender,
                    mintInfo.tokenURI
                );
            }
        } else if (mintInfo.contractType == 2) {
            IERC1155(mintInfo.contractAddress).mint(
                msg.sender,
                mintInfo.tokenId,
                num,
                mintInfo.tokenURI,
                ""
            );
        } else {
            revert("invalid contract type");
        }

        for (uint256 i = 0; i < _mintInfos.length; i++) {
            if (_mintInfos[i].id == id) {
                _mintInfos[i].mintNum += num;
                break;
            }
        }

        emit eveSave(id);

        emit eveMint(id, msg.sender, num, mintInfo.price, amount);
    }
}
