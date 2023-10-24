pragma solidity ^0.8.0;
import "./MOSSAI_Island.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import "@openzeppelin/contracts/access/Ownable.sol";

import "@openzeppelin/contracts/utils/Counters.sol";

contract MOSSAI_Free_Island_Mint is Ownable {
    address public _MOSSAIIslandAddres;

    function setMOSSAIIslandAddres(
        address MOSSAIIslandAddres
    ) public onlyOwner {
        _MOSSAIIslandAddres = MOSSAIIslandAddres;
    }

    function mintIsland(uint32 coordinate) public {
        MOSSAI_Island(_MOSSAIIslandAddres).mint(coordinate, msg.sender);
    }
}
