pragma solidity ^0.8.0;

interface IHyperAGI_Wallet_Account {
    function addAmount(uint256 amount) external;

    function _GasFeeCollectionWallet() external returns (address);
}
