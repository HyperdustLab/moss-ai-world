/**
 * @title MOSSAI_mNFT_Mint
 * @dev Contract for minting mNFTs with HYDT tokens.
 */
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

abstract contract IHyperdustTransactionCfg {
    function getGasFee(string memory func) public view returns (uint256) {}
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
    address public _HyperdustTransactionCfgAddress;

    /**
     * @dev Struct containing information about a mint request.
     * @param id The ID of the mint request.
     * @param tokenURI The URI of the token being minted.
     * @param price The price of the mint request.
     * @param contractAddress The address of the contract being used for minting.
     * @param tokenId The ID of the token being minted.
     * @param contractType The type of contract being used for minting.
     * @param mintNum The number of tokens being minted.
     * @param allowNum The number of tokens allowed to be minted.
     */
    struct MintInfo {
        uint256 id;
        string tokenURI;
        uint256 price;
        address contractAddress;
        uint256 tokenId;
        bytes1 contractType;
        uint256 mintNum;
        uint256 allowNum;
    }

    event eveSave(uint256 id);

    event eveMint(
        uint256 id,
        address account,
        uint256 mintNum,
        uint256 price,
        uint256 amount,
        uint256 gasFee
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

    function setHyperdustTransactionCfgAddress(
        address HyperdustTransactionCfgAddress
    ) public onlyOwner {
        _HyperdustTransactionCfgAddress = HyperdustTransactionCfgAddress;
    }

    /**
     * @dev Sets the contract addresses for the MOSSAI mNFT minting contract.
     * @param contractaddressArray An array of contract addresses to be set.
     *  - contractaddressArray[0]: The address of the MOSSAI roles configuration contract.
     *  - contractaddressArray[1]: The address of the HYDT token contract.
     *  - contractaddressArray[2]: The address of the wallet account.
     *  - contractaddressArray[3]: The address of the Hyperdust transaction configuration contract.
     * Requirements:
     * - Only the contract owner can call this function.
     */
    function setContractAddress(
        address[] memory contractaddressArray
    ) public onlyOwner {
        _MOSSAIRolesCfgAddress = contractaddressArray[0];
        _HYDTTokenAddress = contractaddressArray[1];
        _walletAccountAddres = contractaddressArray[2];
        _HyperdustTransactionCfgAddress = contractaddressArray[3];
    }

    /**
     * @dev Adds mint information to the `_mintInfos` array.
     * @param tokenURI The URI of the token being minted.
     * @param price The price of the token being minted.
     * @param contractAddress The address of the contract being used to mint the token.
     * @param tokenId The ID of the token being minted.
     * @param contractType The type of contract being used to mint the token.
     * @param allowNum The number of tokens allowed to be minted.
     */
    function addMintInfo(
        string memory tokenURI,
        uint256 price,
        address contractAddress,
        uint256 tokenId,
        bytes1 contractType,
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

    /**
     * @dev Updates the information of an existing mNFT.
     * @param id The ID of the mNFT to update.
     * @param tokenURI The new token URI of the mNFT.
     * @param price The new price of the mNFT.
     * @param contractAddress The new contract address of the mNFT.
     * @param tokenId The new token ID of the mNFT.
     * @param contractType The new contract type of the mNFT.
     * @param allowNum The new allowed number of the mNFT.
     * Requirements:
     * - The caller must have the admin role.
     * - The mNFT with the given ID must exist.
     */
    function updateNFT(
        uint256 id,
        string memory tokenURI,
        uint256 price,
        address contractAddress,
        uint256 tokenId,
        bytes1 contractType,
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

    /**
     * @dev Retrieves the mint information for a given NFT ID.
     * @param id The ID of the NFT to retrieve the mint information for.
     * @return A tuple containing the mint information for the NFT, including its ID, token URI, price, contract address, token ID, contract type, mint number, and allowed number.
     * @dev If the NFT does not exist, reverts with an error message.
     */
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
            bytes1,
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

    /**
     * @dev Deletes the mint information of an NFT with the given ID.
     * @param id The ID of the NFT to delete the mint information of.
     * Requirements:
     * - The caller must have the admin role.
     * - The NFT with the given ID must exist.
     */
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

    /**
     * @dev Mint NFTs with the given id and quantity.
     * @param id The id of the NFT to be minted.
     * @param num The quantity of NFTs to be minted.
     * Emits a {eveSave} event indicating that the NFT has been saved.
     * Emits a {eveMint} event indicating that the NFT has been minted.
     * Requirements:
     * - The NFT with the given id must exist.
     * - The caller must have authorized the contract to spend the required amount of tokens.
     * - The inventory of the NFT must be sufficient to mint the requested quantity.
     * - The contract type must be either ERC721 or ERC1155.
     */
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

        uint256 gasFee = IHyperdustTransactionCfg(
            _HyperdustTransactionCfgAddress
        ).getGasFee("mint_mNFT");

        require(
            amount >= mintInfo.price * num + gasFee,
            "Insufficient authorized amount"
        );

        require(
            mintInfo.allowNum >= mintInfo.mintNum + num + gasFee,
            "Insufficient inventory"
        );

        erc20.transferFrom(
            msg.sender,
            _walletAccountAddres,
            mintInfo.price * num + gasFee
        );

        walletAccountAddress.addAmount(mintInfo.price * num + gasFee);

        if (mintInfo.contractType == 0x11) {
            for (uint i = 0; i < num; i++) {
                IERC721(mintInfo.contractAddress).safeMint(
                    msg.sender,
                    mintInfo.tokenURI
                );
            }
        } else if (mintInfo.contractType == 0x22) {
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

        emit eveMint(id, msg.sender, num, mintInfo.price, amount, gasFee);
    }
}
