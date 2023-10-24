pragma solidity ^0.8.0;

import "./Island_721.sol";

contract Island721Factory {
    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    bytes32 public constant URI_SETTER_ROLE = keccak256("URI_SETTER_ROLE");

    function deploy(
        address account,
        address islandAssetsCfgAddress
    ) public returns (address) {
        Island_721 island721Address = new Island_721(islandAssetsCfgAddress);

        island721Address.grantRole(DEFAULT_ADMIN_ROLE, account);
        island721Address.grantRole(MINTER_ROLE, account);

        address _island721Address = address(island721Address);

        return _island721Address;
    }
}
