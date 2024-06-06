pragma solidity ^0.8.0;

interface IHyperAGI_Wallet_Account {
    function initialize(address onlyOwner) external;

    function setRolesCfgAddress(address rolesCfgAddress) external;

    function setGasFeeCollectionWallet(address gasFeeCollectionWallet) external;

    function setContractAddress(address[] memory contractaddressArray) external;

    function addAmount(uint256 amount) external;
}
