/**
 * @title MOSSAI_mNFT_Mint
 * @dev Contract for minting mNFTs with HYDT tokens.
 */
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Strings.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import "./utils/StrUtil.sol";
import "./Hyperdust_Roles_Cfg.sol";
import "./MOSSAI_Storage.sol";

abstract contract IWalletAccount {
    function addAmount(uint256 amount) public {}

    function _GasFeeCollectionWallet() public view returns (address) {}
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

contract MOSSAI_mNFT_Mint is OwnableUpgradeable {
    using Strings for *;
    using StrUtil for *;

    address public _MOSSAIRolesCfgAddress;
    address public _HYDTTokenAddress;
    address public _walletAccountAddres;
    address public _HyperdustTransactionCfgAddress;
    address public _MOSSAIStorageAddress;

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

    function initialize(address onlyOwner) public initializer {
        __Ownable_init(onlyOwner);
    }

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

    function setMOSSAIStorageAddress(
        address MOSSAIStorageAddress
    ) public onlyOwner {
        _MOSSAIStorageAddress = MOSSAIStorageAddress;
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
        _MOSSAIStorageAddress = contractaddressArray[4];
    }

    function addMintInfo(
        string memory tokenURI,
        uint256 price,
        address contractAddress,
        uint256 tokenId,
        bytes1 contractType,
        uint256 allowNum,
        uint256 allowBuyNum
    ) public {
        require(
            Hyperdust_Roles_Cfg(_MOSSAIRolesCfgAddress).hasAdminRole(
                msg.sender
            ),
            "not admin role"
        );

        MOSSAI_Storage mossaiStorage = MOSSAI_Storage(_MOSSAIStorageAddress);

        uint256 id = mossaiStorage.getNextId();

        mossaiStorage.setString(mossaiStorage.genKey("tokenURI", id), tokenURI);
        mossaiStorage.setUint(mossaiStorage.genKey("price", id), price);
        mossaiStorage.setAddress(
            mossaiStorage.genKey("contractAddress", id),
            contractAddress
        );

        mossaiStorage.setUint(mossaiStorage.genKey("tokenId", id), tokenId);
        mossaiStorage.setBytes1(
            mossaiStorage.genKey("contractType", id),
            contractType
        );

        mossaiStorage.setUint(mossaiStorage.genKey("allowNum", id), allowNum);
        mossaiStorage.setUint(
            mossaiStorage.genKey("allowBuyNum", id),
            allowBuyNum
        );

        emit eveSave(id);
    }

    function updateNFT(
        uint256 id,
        string memory tokenURI,
        uint256 price,
        address contractAddress,
        uint256 tokenId,
        bytes1 contractType,
        uint256 allowNum,
        uint256 allowBuyNum
    ) public {
        require(
            Hyperdust_Roles_Cfg(_MOSSAIRolesCfgAddress).hasAdminRole(
                msg.sender
            ),
            "not admin role"
        );

        MOSSAI_Storage mossaiStorage = MOSSAI_Storage(_MOSSAIStorageAddress);

        string memory _tokenURI = mossaiStorage.getString(
            mossaiStorage.genKey("tokenURI", id)
        );

        require(bytes(_tokenURI).length > 0, "not found");

        mossaiStorage.setString(mossaiStorage.genKey("tokenURI", id), tokenURI);
        mossaiStorage.setUint(mossaiStorage.genKey("price", id), price);
        mossaiStorage.setAddress(
            mossaiStorage.genKey("contractAddress", id),
            contractAddress
        );

        mossaiStorage.setUint(mossaiStorage.genKey("tokenId", id), tokenId);
        mossaiStorage.setBytes1(
            mossaiStorage.genKey("contractType", id),
            contractType
        );

        mossaiStorage.setUint(mossaiStorage.genKey("allowNum", id), allowNum);

        mossaiStorage.setUint(
            mossaiStorage.genKey("allowBuyNum", id),
            allowNum
        );

        emit eveSave(id);
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
            bytes1,
            uint256,
            uint256,
            uint256
        )
    {
        MOSSAI_Storage mossaiStorage = MOSSAI_Storage(_MOSSAIStorageAddress);

        string memory _tokenURI = mossaiStorage.getString(
            mossaiStorage.genKey("tokenURI", id)
        );

        require(bytes(_tokenURI).length > 0, "not found");

        return (
            id,
            mossaiStorage.getString(mossaiStorage.genKey("tokenURI", id)),
            mossaiStorage.getUint(mossaiStorage.genKey("price", id)),
            mossaiStorage.getAddress(
                mossaiStorage.genKey("contractAddress", id)
            ),
            mossaiStorage.getUint(mossaiStorage.genKey("tokenId", id)),
            mossaiStorage.getBytes1(mossaiStorage.genKey("contractType", id)),
            mossaiStorage.getUint(mossaiStorage.genKey("mintNum", id)),
            mossaiStorage.getUint(mossaiStorage.genKey("allowNum", id)),
            mossaiStorage.getUint(mossaiStorage.genKey("allowBuyNum", id))
        );
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
            Hyperdust_Roles_Cfg(_MOSSAIRolesCfgAddress).hasAdminRole(
                msg.sender
            ),
            "not admin role"
        );

        MOSSAI_Storage mossaiStorage = MOSSAI_Storage(_MOSSAIStorageAddress);

        string memory _tokenURI = mossaiStorage.getString(
            mossaiStorage.genKey("tokenURI", id)
        );

        require(bytes(_tokenURI).length > 0, "not found");

        mossaiStorage.setString(mossaiStorage.genKey("tokenURI", id), "");
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

        address _GasFeeCollectionWallet = walletAccountAddress
            ._GasFeeCollectionWallet();

        require(
            _GasFeeCollectionWallet != address(0),
            "not set GasFeeCollectionWallet"
        );

        MOSSAI_Storage mossaiStorage = MOSSAI_Storage(_MOSSAIStorageAddress);

        string memory _tokenURI = mossaiStorage.getString(
            mossaiStorage.genKey("tokenURI", id)
        );

        require(bytes(_tokenURI).length > 0, "not found");

        uint256 amount = erc20.allowance(msg.sender, address(this));

        uint256 price = mossaiStorage.getUint(
            mossaiStorage.genKey("price", id)
        );

        uint256 gasFee = IHyperdustTransactionCfg(
            _HyperdustTransactionCfgAddress
        ).getGasFee("mint_mNFT");

        uint256 payAmount = price * num + gasFee;

        require(amount >= payAmount, "Insufficient authorized amount");

        uint256 allowNum = mossaiStorage.getUint(
            mossaiStorage.genKey("allowNum", id)
        );

        uint256 mintNum = mossaiStorage.getUint(
            mossaiStorage.genKey("mintNum", id)
        );

        require(allowNum >= mintNum + num, "Insufficient inventory");

        uint256 allowBuyNum = mossaiStorage.getUint(
            mossaiStorage.genKey("allowBuyNum", id)
        );

        if (allowBuyNum > 0) {
            string memory buyNumKey = string(
                abi.encode(id.toString(), msg.sender.toHexString())
            );

            uint256 buyNum = mossaiStorage.getUint(buyNumKey);

            require(buyNum + num <= allowBuyNum, "exceeds the purchase limit");

            mossaiStorage.setUint(buyNumKey, buyNum + num);
        }

        erc20.transferFrom(msg.sender, _GasFeeCollectionWallet, payAmount);

        walletAccountAddress.addAmount(payAmount);

        bytes1 contractType = mossaiStorage.getBytes1(
            mossaiStorage.genKey("contractType", id)
        );

        address contractAddress = mossaiStorage.getAddress(
            mossaiStorage.genKey("contractAddress", id)
        );

        uint256 tokenId = mossaiStorage.getUint(
            mossaiStorage.genKey("tokenId", id)
        );

        string memory tokenURI = mossaiStorage.getString(
            mossaiStorage.genKey("tokenURI", id)
        );

        if (contractType == 0x11) {
            for (uint i = 0; i < num; i++) {
                IERC721(contractAddress).safeMint(msg.sender, tokenURI);
            }
        } else if (contractType == 0x22) {
            IERC1155(contractAddress).mint(
                msg.sender,
                tokenId,
                num,
                tokenURI,
                ""
            );
        } else {
            revert("invalid contract type");
        }

        mossaiStorage.setUint(
            mossaiStorage.genKey("mintNum", id),
            mintNum + num
        );

        emit eveSave(id);

        emit eveMint(id, msg.sender, num, price, amount, gasFee);
    }
}
