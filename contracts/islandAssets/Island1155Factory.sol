pragma solidity ^0.8.0;

import "./Island_1155.sol";

contract Island1155Factory {
    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    bytes32 public constant URI_SETTER_ROLE = keccak256("URI_SETTER_ROLE");

    function deploy(
        address account,
        address islandAssetsCfgAddress
    ) public returns (address) {
        Island_1155 island1155Address = new Island_1155(islandAssetsCfgAddress);

        island1155Address.grantRole(DEFAULT_ADMIN_ROLE, account);
        island1155Address.grantRole(MINTER_ROLE, account);

        island1155Address.grantRole(URI_SETTER_ROLE, account);
        island1155Address.grantRole(PAUSER_ROLE, account);

        address _island1155Address = address(island1155Address);

        return _island1155Address;
    }
}
