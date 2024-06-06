pragma solidity ^0.8.0;

import "./Island_721.sol";

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract Island721Factory is OwnableUpgradeable {
    function initialize(address onlyOwner) public initializer {
        __Ownable_init(onlyOwner);
    }

    function deploy(address account, string memory name, string memory symbol) public returns (address) {
        require(account != address(0x0), "account is zero address");
        Island_721 island721Address = new Island_721(account, name, symbol);

        address _island721Address = address(island721Address);

        return _island721Address;
    }
}
