pragma solidity ^0.8.1;

interface IHyperAGI_GYM_Space {
    function add(string memory name, string memory coverImage, string memory image, string memory remark) external returns (bytes32);

    function get(bytes32 sid) external view returns (bytes32, address, string memory, string memory, string memory, string memory);

    function edit(bytes32 sid, string memory name, string memory coverImage, string memory image, string memory remark) external;

    function del(bytes32 sid) external;
}
