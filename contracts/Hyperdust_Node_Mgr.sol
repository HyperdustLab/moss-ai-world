pragma solidity ^0.8.0;

contract Hyperdust_Node_Mgr {
    function getStatisticalIndex()
        public
        view
        returns (uint256, uint32, uint32)
    {
        return (1, 100, 60);
    }
}
