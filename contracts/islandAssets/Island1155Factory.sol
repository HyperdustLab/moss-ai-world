pragma solidity ^0.8.0;

import "./Island_1155.sol";

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract Island1155Factory is OwnableUpgradeable {
    function initialize(address onlyOwner) public initializer {
        __Ownable_init(onlyOwner);
    }

    function deploy(address account, string memory name, string memory symbol) public returns (address) {
        require(account != address(0x0), "account is zero address");
        Island_1155 island1155Address = new Island_1155(account, name, symbol);

        address _island1155Address = address(island1155Address);

        return _island1155Address;
    }
}
