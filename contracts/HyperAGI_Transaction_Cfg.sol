pragma solidity ^0.8.0;

interface IHyperAGI_Transaction_Cfg {
    function add(string memory func, uint256 rate) external;

    function del(string memory func) external;

    function get(string memory func) external view returns (uint256);

    function getGasFee(string memory func) external view returns (uint256);

    function setMinGasFee(string memory key, uint256 minGasFee) external;

    function getMaxGasFee(string memory func) external view returns (uint256);
}
