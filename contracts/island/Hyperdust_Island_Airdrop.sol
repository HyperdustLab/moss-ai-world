pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Strings.sol";

import "@openzeppelin/contracts/access/Ownable.sol";

import "@openzeppelin/contracts/utils/Counters.sol";

import "../utils/StrUtil.sol";
import "../MOSSAI_Roles_Cfg.sol";

abstract contract MOSSAI_Island {
    function getIsland(
        uint256 islandId
    )
        public
        view
        returns (
            uint256,
            string memory,
            string memory,
            string memory,
            string memory,
            address,
            address,
            uint256,
            uint32,
            bytes32
        )
    {}
}

contract Hyperdust_Island_Airdrop is Ownable {
    using Strings for *;
    using StrUtil for *;

    address public _MOSSAIRolesCfgAddress;
    address public _erc20Address;
    address public _MOSSAIIslandAddress;

    using Counters for Counters.Counter;
    Counters.Counter private _id;

    function setMOSSAIRolesCfgAddress(
        address MOSSAIRolesCfgAddress
    ) public onlyOwner {
        _MOSSAIRolesCfgAddress = MOSSAIRolesCfgAddress;
    }

    function setErc20Address(address erc20Address) public onlyOwner {
        _erc20Address = erc20Address;
    }

    function setMOSSAIIslandAddress(
        address MOSSAIIslandAddress
    ) public onlyOwner {
        _MOSSAIIslandAddress = MOSSAIIslandAddress;
    }

    struct IslandAirdrop {
        uint256 id;
        uint256 totalAmount;
        uint256 releaseAmount;
        uint256 randomAmount;
        uint32 startTime;
        uint32 endTime;
        uint256 islandId;
        string airdropConfig;
        bytes1 status;
        address fromAddress;
    }
}
