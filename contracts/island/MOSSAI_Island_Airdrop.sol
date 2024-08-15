pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Strings.sol";

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import "../utils/StrUtil.sol";
import "../HyperAGI_Roles_Cfg.sol";
import "../MOSSAI_Storage.sol";
import "./MOSSAI_Island.sol";
import "./MOSSAI_Island_NFG.sol";

contract MOSSAI_Island_Airdrop is OwnableUpgradeable {
    using Strings for *;
    using StrUtil for *;

    uint256 private _rand;

    address public _rolesCfgAddress;
    address public _islandAddress;
    address public _islandNFGAddress;
    address public _storageAddress;

    receive() external payable {}

    function initialize(address onlyOwner) public initializer {
        _rand = 1;
        __Ownable_init(onlyOwner);
    }

    function setRolesCfgAddress(address rolesCfgAddress) public onlyOwner {
        _rolesCfgAddress = rolesCfgAddress;
    }

    function setIslandAddress(address islandAddress) public onlyOwner {
        _islandAddress = islandAddress;
    }

    function setIslandNFGAddress(address islandNFGAddress) public onlyOwner {
        _islandNFGAddress = islandNFGAddress;
    }

    function setStorageAddress(address storageAddress) public onlyOwner {
        _storageAddress = storageAddress;
    }

    function setContractAddress(address[] memory contractaddressArray) public onlyOwner {
        require(contractaddressArray.length >= 4, "Insufficient addresses provided");
        setRolesCfgAddress(contractaddressArray[0]);
        setIslandAddress(contractaddressArray[1]);
        setIslandNFGAddress(contractaddressArray[2]);
        setStorageAddress(contractaddressArray[3]);
    }

    event eveSave(uint256 id);

    event eveDelete(uint256 id);

    event eveReceiveAirdrop(uint256 id, address to, uint256 amount);

    function addIslandAirdrop(bytes32 sid, string memory name, uint256[] memory uint256Array, uint256 startTime, uint256 endTime, string memory airdropConfig, bytes1 status, uint256 intervalTime) public {
        require(IHyperAGI_Roles_Cfg(_rolesCfgAddress).hasAdminRole(msg.sender), "not admin role");

        MOSSAI_Island(_islandAddress).getIsland(sid);

        MOSSAI_Storage storageAddress = MOSSAI_Storage(_storageAddress);

        uint256 id = storageAddress.getNextId();

        storageAddress.setString(storageAddress.genKey("name", id), name);
        storageAddress.setUint(storageAddress.genKey("totalAmount", id), uint256Array[0]);
        storageAddress.setUint(storageAddress.genKey("minRandomAmount", id), uint256Array[1]);

        storageAddress.setUint(storageAddress.genKey("maxRandomAmount", id), uint256Array[2]);

        storageAddress.setUint(storageAddress.genKey("startTime", id), startTime);
        storageAddress.setUint(storageAddress.genKey("endTime", id), endTime);
        storageAddress.setBytes32(storageAddress.genKey("sid", id), sid);

        storageAddress.setString(storageAddress.genKey("airdropConfig", id), airdropConfig);

        storageAddress.setBytes1(storageAddress.genKey("status", id), status);

        storageAddress.setUint(storageAddress.genKey("intervalTime", id), intervalTime);

        emit eveSave(id);
    }

    function updateIslandAirdrop(uint256 id, bytes32 sid, string memory name, uint256 minRandomAmount, uint256 maxRandomAmount, uint256 startTime, uint256 endTime, string memory airdropConfig, uint256 intervalTime, uint256 totalAmount) public {
        require(IHyperAGI_Roles_Cfg(_rolesCfgAddress).hasAdminRole(msg.sender), "not admin role");

        MOSSAI_Storage storageAddress = MOSSAI_Storage(_storageAddress);

        string memory _name = storageAddress.getString(storageAddress.genKey("name", id));

        require(bytes(_name).length > 0, "not found");

        uint256 releaseAmount = storageAddress.getUint(storageAddress.genKey("releaseAmount", id));

        require(releaseAmount == 0, "airdrop has release amount,Update is not allowed");

        storageAddress.setString(storageAddress.genKey("name", id), name);
        storageAddress.setUint(storageAddress.genKey("totalAmount", id), totalAmount);
        storageAddress.setUint(storageAddress.genKey("minRandomAmount", id), minRandomAmount);

        storageAddress.setUint(storageAddress.genKey("maxRandomAmount", id), maxRandomAmount);

        storageAddress.setUint(storageAddress.genKey("startTime", id), startTime);
        storageAddress.setUint(storageAddress.genKey("endTime", id), endTime);
        storageAddress.setBytes32(storageAddress.genKey("sid", id), sid);

        storageAddress.setString(storageAddress.genKey("airdropConfig", id), airdropConfig);

        storageAddress.setUint(storageAddress.genKey("intervalTime", id), intervalTime);

        emit eveSave(id);
    }

    function deleteIslandAirdrop(uint256 id) public {
        require(IHyperAGI_Roles_Cfg(_rolesCfgAddress).hasAdminRole(msg.sender), "not admin role");

        MOSSAI_Storage storageAddress = MOSSAI_Storage(_storageAddress);

        string memory _name = storageAddress.getString(storageAddress.genKey("name", id));

        require(bytes(_name).length > 0, "not found");

        uint256 releaseAmount = storageAddress.getUint(storageAddress.genKey("releaseAmount", id));

        require(releaseAmount == 0, "airdrop has release amount,Update is not allowed");

        storageAddress.setString(storageAddress.genKey("name", id), "");

        emit eveDelete(id);
    }

    function updateStatus(uint256 id, bytes1 status) public {
        require(IHyperAGI_Roles_Cfg(_rolesCfgAddress).hasAdminRole(msg.sender), "not admin role");

        MOSSAI_Storage storageAddress = MOSSAI_Storage(_storageAddress);
        string memory _name = storageAddress.getString(storageAddress.genKey("name", id));

        require(bytes(_name).length > 0, "not found");

        storageAddress.setBytes1(storageAddress.genKey("status", id), status);

        emit eveSave(id);
    }

    function getIslandAirdrop(uint256 id) public view returns (uint256[] memory, string memory, bytes1, string memory, bytes32 sid) {
        MOSSAI_Storage storageAddress = MOSSAI_Storage(_storageAddress);

        string memory _name = storageAddress.getString(storageAddress.genKey("name", id));

        require(bytes(_name).length > 0, "not found");

        uint256[] memory uint256Array = new uint256[](9);
        uint256Array[0] = id;
        uint256Array[1] = storageAddress.getUint(storageAddress.genKey("totalAmount", id));
        uint256Array[2] = storageAddress.getUint(storageAddress.genKey("releaseAmount", id));

        uint256Array[3] = storageAddress.getUint(storageAddress.genKey("minRandomAmount", id));
    
        uint256Array[4] = storageAddress.getUint(storageAddress.genKey("maxRandomAmount", id));

        uint256Array[5] = storageAddress.getUint(storageAddress.genKey("startTime", id));

        uint256Array[6] = storageAddress.getUint(storageAddress.genKey("endTime", id));

        uint256Array[7] = storageAddress.getUint(storageAddress.genKey("intervalTime", id));

        bytes32 sid = storageAddress.getBytes32(storageAddress.genKey("sid", id));

        return (uint256Array, storageAddress.getString(storageAddress.genKey("airdropConfig", id)), storageAddress.getBytes1(storageAddress.genKey("status", id)), _name, sid);
    }

    function receiveAirdrop(uint256 id) public {
        MOSSAI_Storage storageAddress = MOSSAI_Storage(_storageAddress);

        string memory _name = storageAddress.getString(storageAddress.genKey("name", id));

        require(bytes(_name).length > 0, "not found");

        string memory lastReleaseTimeKey = string(abi.encodePacked("lastReleaseTime_", msg.sender.toHexString()));

        uint256 lastTime = storageAddress.getUint(lastReleaseTimeKey);

        bytes1 status = storageAddress.getBytes1(storageAddress.genKey("status", id));

        require(status == 0x01, "island airdrop status is not open");

        uint256 timestamp = block.timestamp;

        uint256 startTime = storageAddress.getUint(storageAddress.genKey("startTime", id));

        uint256 endTime = storageAddress.getUint(storageAddress.genKey("endTime", id));

        require(timestamp >= startTime && timestamp < endTime, "Temporary Closed");

        uint256 intervalTime = storageAddress.getUint(storageAddress.genKey("intervalTime", id));

        require(timestamp - lastTime >= intervalTime, "Waiting for the next round drop.");

        uint256 minRandomAmount = storageAddress.getUint(storageAddress.genKey("minRandomAmount", id));

        uint256 maxRandomAmount = storageAddress.getUint(storageAddress.genKey("maxRandomAmount", id));

        uint256 releaseAmount = storageAddress.getUint(storageAddress.genKey("releaseAmount", id));

        uint256 totalAmount = storageAddress.getUint(storageAddress.genKey("totalAmount", id));

        uint256 randomAmount = _getRandom(minRandomAmount, maxRandomAmount);

        releaseAmount = releaseAmount + randomAmount;

        require(releaseAmount <= totalAmount, "This airdrop zone reached its limit.");

        transferETH(payable(msg.sender), randomAmount);

        storageAddress.setUint(storageAddress.genKey("releaseAmount", id), releaseAmount);

        storageAddress.setUint(lastReleaseTimeKey, timestamp);

        emit eveReceiveAirdrop(id, msg.sender, randomAmount);

        emit eveSave(id);
    }

    function withdraw(uint256 id, uint256 amount) public {
        MOSSAI_Storage storageAddress = MOSSAI_Storage(_storageAddress);
        string memory _name = storageAddress.getString(storageAddress.genKey("name", id));

        require(bytes(_name).length > 0, "not found");

        bytes32 sid = storageAddress.getBytes32(storageAddress.genKey("sid", id));

        (, uint256[] memory uint256Array, ) = MOSSAI_Island(_islandAddress).getIsland(sid);

        address seedOwer = MOSSAI_Island_NFG(_islandNFGAddress).getSeedOwer(uint256Array[0]);

        require(msg.sender == seedOwer, "not island ower");

        uint256 releaseAmount = storageAddress.getUint(storageAddress.genKey("releaseAmount", id));

        uint256 totalAmount = storageAddress.getUint(storageAddress.genKey("totalAmount", id));

        releaseAmount = releaseAmount + amount;

        require(releaseAmount <= totalAmount, "release amount is not enough");

        transferETH(payable(msg.sender), amount);

        storageAddress.setUint(storageAddress.genKey("releaseAmount", id), releaseAmount);

        emit eveReceiveAirdrop(id, msg.sender, amount);

        emit eveSave(id);
    }

    /**
     * @dev Generates a random number between _start and _end (exclusive) using block difficulty, timestamp and a private variable _rand.
     * @param _start The start of the range (inclusive).
     * @param _end The end of the range (exclusive).
     * @return A random number between _start and _end (exclusive).
     */
    function _getRandom(uint256 _start, uint256 _end) private returns (uint256) {
        if (_start == _end) {
            return _start;
        }
        uint256 _length = _end - _start;
        uint256 random = uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp, _rand)));
        random = (random % _length) + _start;
        _rand++;
        return random;
    }

    function transferETH(address payable recipient, uint256 amount) private {
        require(address(this).balance >= amount, "Insufficient balance in contract");
        recipient.transfer(amount);
    }
}
