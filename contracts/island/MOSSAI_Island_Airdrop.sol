pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Strings.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import "../utils/StrUtil.sol";
import "../Hyperdust_Roles_Cfg.sol";
import "../MOSSAI_Storage.sol";

abstract contract IMOSSAIIsland {
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

abstract contract IMOSSAIIslandNFG {
    function getSeedOwer(uint32 seed) public view returns (address) {}
}

contract MOSSAI_Island_Airdrop is OwnableUpgradeable {
    using Strings for *;
    using StrUtil for *;

    uint256 private _rand;

    address public _MOSSAIRolesCfgAddress;
    address public _erc20Address;
    address public _MOSSAIIslandAddress;
    address public _MOSSAIIslandNFGAddress;
    address public _MOSSAIStorageAddress;

    function initialize(address onlyOwner) public initializer {
        _rand = 1;
        __Ownable_init(onlyOwner);
    }

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

    function setMOSSAIIslandNFGAddress(
        address MOSSAIIslandNFGAddress
    ) public onlyOwner {
        _MOSSAIIslandNFGAddress = MOSSAIIslandNFGAddress;
    }

    function setMOSSAIStorageAddress(
        address MOSSAIStorageAddress
    ) public onlyOwner {
        _MOSSAIStorageAddress = MOSSAIStorageAddress;
    }

    event eveSave(uint256 id);

    event eveDelete(uint256 id);

    event eveReceiveAirdrop(uint256 id, address to, uint256 amount);

    function addIslandAirdrop(
        string memory name,
        uint256[] memory uint256Array,
        uint256 startTime,
        uint256 endTime,
        string memory airdropConfig,
        bytes1 status,
        address fromAddress,
        uint256 intervalTime
    ) public {
        require(
            Hyperdust_Roles_Cfg(_MOSSAIRolesCfgAddress).hasAdminRole(
                msg.sender
            ),
            "not admin role"
        );

        if (uint256Array[3] != 0) {
            (uint256 _id, , , , , , , , , ) = IMOSSAIIsland(
                _MOSSAIIslandAddress
            ).getIsland(uint256Array[3]);

            require(_id > 0, "island not found");
        }

        MOSSAI_Storage mossaiStorage = MOSSAI_Storage(_MOSSAIStorageAddress);

        uint256 id = mossaiStorage.getNextId();

        mossaiStorage.setString(mossaiStorage.genKey("name", id), name);
        mossaiStorage.setUint(
            mossaiStorage.genKey("totalAmount", id),
            uint256Array[0]
        );
        mossaiStorage.setUint(
            mossaiStorage.genKey("minRandomAmount", id),
            uint256Array[1]
        );

        mossaiStorage.setUint(
            mossaiStorage.genKey("maxRandomAmount", id),
            uint256Array[2]
        );

        mossaiStorage.setUint(mossaiStorage.genKey("startTime", id), startTime);
        mossaiStorage.setUint(mossaiStorage.genKey("endTime", id), endTime);
        mossaiStorage.setUint(
            mossaiStorage.genKey("islandId", id),
            uint256Array[3]
        );

        mossaiStorage.setString(
            mossaiStorage.genKey("airdropConfig", id),
            airdropConfig
        );

        mossaiStorage.setBytes1(mossaiStorage.genKey("status", id), status);

        mossaiStorage.setAddress(
            mossaiStorage.genKey("fromAddress", id),
            fromAddress
        );

        mossaiStorage.setUint(
            mossaiStorage.genKey("intervalTime", id),
            intervalTime
        );

        emit eveSave(id);
    }

    function updateIslandAirdrop(
        uint256 id,
        string memory name,
        uint256 minRandomAmount,
        uint256 maxRandomAmount,
        uint256 startTime,
        uint256 endTime,
        string memory airdropConfig,
        uint256 intervalTime,
        uint256 totalAmount,
        uint256 islandId
    ) public {
        require(
            Hyperdust_Roles_Cfg(_MOSSAIRolesCfgAddress).hasAdminRole(
                msg.sender
            ),
            "not admin role"
        );

        MOSSAI_Storage mossaiStorage = MOSSAI_Storage(_MOSSAIStorageAddress);

        if (islandId != 0) {
            (uint256 _id, , , , , , , , , ) = IMOSSAIIsland(
                _MOSSAIIslandAddress
            ).getIsland(islandId);

            require(_id > 0, "island not found");
        }

        string memory _name = mossaiStorage.getString(
            mossaiStorage.genKey("name", id)
        );

        require(bytes(_name).length > 0, "not found");

        uint256 releaseAmount = mossaiStorage.getUint(
            mossaiStorage.genKey("releaseAmount", id)
        );

        require(
            releaseAmount == 0,
            "airdrop has release amount,Update is not allowed"
        );

        mossaiStorage.setString(mossaiStorage.genKey("name", id), name);
        mossaiStorage.setUint(
            mossaiStorage.genKey("totalAmount", id),
            totalAmount
        );
        mossaiStorage.setUint(
            mossaiStorage.genKey("minRandomAmount", id),
            minRandomAmount
        );

        mossaiStorage.setUint(
            mossaiStorage.genKey("maxRandomAmount", id),
            maxRandomAmount
        );

        mossaiStorage.setUint(mossaiStorage.genKey("startTime", id), startTime);
        mossaiStorage.setUint(mossaiStorage.genKey("endTime", id), endTime);
        mossaiStorage.setUint(mossaiStorage.genKey("islandId", id), islandId);

        mossaiStorage.setString(
            mossaiStorage.genKey("airdropConfig", id),
            airdropConfig
        );

        mossaiStorage.setUint(
            mossaiStorage.genKey("intervalTime", id),
            intervalTime
        );

        emit eveSave(id);
    }

    function deleteIslandAirdrop(uint256 id) public {
        require(
            Hyperdust_Roles_Cfg(_MOSSAIRolesCfgAddress).hasAdminRole(
                msg.sender
            ),
            "not admin role"
        );

        MOSSAI_Storage mossaiStorage = MOSSAI_Storage(_MOSSAIStorageAddress);

        string memory _name = mossaiStorage.getString(
            mossaiStorage.genKey("name", id)
        );

        require(bytes(_name).length > 0, "not found");

        uint256 releaseAmount = mossaiStorage.getUint(
            mossaiStorage.genKey("releaseAmount", id)
        );

        require(
            releaseAmount == 0,
            "airdrop has release amount,Update is not allowed"
        );

        mossaiStorage.setString(mossaiStorage.genKey("name", id), "");

        emit eveDelete(id);
    }

    function updateStatus(uint256 id, bytes1 status) public {
        require(
            Hyperdust_Roles_Cfg(_MOSSAIRolesCfgAddress).hasAdminRole(
                msg.sender
            ),
            "not admin role"
        );

        MOSSAI_Storage mossaiStorage = MOSSAI_Storage(_MOSSAIStorageAddress);

        string memory _name = mossaiStorage.getString(
            mossaiStorage.genKey("name", id)
        );

        require(bytes(_name).length > 0, "not found");

        mossaiStorage.setBytes1(mossaiStorage.genKey("status", id), status);

        emit eveSave(id);
    }

    function getIslandAirdrop(
        uint256 id
    )
        public
        view
        returns (
            uint256[] memory,
            string memory,
            bytes1,
            address,
            string memory
        )
    {
        MOSSAI_Storage mossaiStorage = MOSSAI_Storage(_MOSSAIStorageAddress);

        string memory _name = mossaiStorage.getString(
            mossaiStorage.genKey("name", id)
        );

        require(bytes(_name).length > 0, "not found");

        uint256[] memory uint256Array = new uint256[](9);
        uint256Array[0] = id;
        uint256Array[1] = mossaiStorage.getUint(
            mossaiStorage.genKey("totalAmount", id)
        );
        uint256Array[2] = mossaiStorage.getUint(
            mossaiStorage.genKey("releaseAmount", id)
        );

        uint256Array[3] = mossaiStorage.getUint(
            mossaiStorage.genKey("minRandomAmount", id)
        );

        uint256Array[4] = mossaiStorage.getUint(
            mossaiStorage.genKey("maxRandomAmount", id)
        );

        uint256Array[5] = mossaiStorage.getUint(
            mossaiStorage.genKey("islandId", id)
        );

        uint256Array[6] = mossaiStorage.getUint(
            mossaiStorage.genKey("startTime", id)
        );

        uint256Array[7] = mossaiStorage.getUint(
            mossaiStorage.genKey("endTime", id)
        );

        uint256Array[8] = mossaiStorage.getUint(
            mossaiStorage.genKey("intervalTime", id)
        );

        return (
            uint256Array,
            mossaiStorage.getString(mossaiStorage.genKey("airdropConfig", id)),
            mossaiStorage.getBytes1(mossaiStorage.genKey("status", id)),
            mossaiStorage.getAddress(mossaiStorage.genKey("fromAddress", id)),
            _name
        );
    }

    function receiveAirdrop(uint256 id) public {
        MOSSAI_Storage mossaiStorage = MOSSAI_Storage(_MOSSAIStorageAddress);

        string memory _name = mossaiStorage.getString(
            mossaiStorage.genKey("name", id)
        );

        require(bytes(_name).length > 0, "not found");

        string memory lastReleaseTimeKey = string(
            abi.encodePacked("lastReleaseTime_", msg.sender.toHexString())
        );

        uint256 lastTime = mossaiStorage.getUint(lastReleaseTimeKey);

        bytes1 status = mossaiStorage.getBytes1(
            mossaiStorage.genKey("status", id)
        );

        require(status == 0x01, "island airdrop status is not open");

        uint256 timestamp = block.timestamp;

        uint256 startTime = mossaiStorage.getUint(
            mossaiStorage.genKey("startTime", id)
        );

        uint256 endTime = mossaiStorage.getUint(
            mossaiStorage.genKey("endTime", id)
        );

        require(
            timestamp >= startTime && timestamp < endTime,
            "Temporary Closed"
        );

        uint256 intervalTime = mossaiStorage.getUint(
            mossaiStorage.genKey("intervalTime", id)
        );

        require(
            timestamp - lastTime >= intervalTime,
            "Waiting for the next round drop."
        );

        uint256 minRandomAmount = mossaiStorage.getUint(
            mossaiStorage.genKey("minRandomAmount", id)
        );

        uint256 maxRandomAmount = mossaiStorage.getUint(
            mossaiStorage.genKey("maxRandomAmount", id)
        );

        uint256 releaseAmount = mossaiStorage.getUint(
            mossaiStorage.genKey("releaseAmount", id)
        );

        uint256 totalAmount = mossaiStorage.getUint(
            mossaiStorage.genKey("totalAmount", id)
        );

        uint256 randomAmount = _getRandom(minRandomAmount, maxRandomAmount);

        releaseAmount = releaseAmount + randomAmount;

        require(
            releaseAmount <= totalAmount,
            "This airdrop zone reached its limit."
        );

        address fromAddress = mossaiStorage.getAddress(
            mossaiStorage.genKey("fromAddress", id)
        );

        uint256 allowance = IERC20(_erc20Address).allowance(
            fromAddress,
            address(this)
        );

        require(allowance >= randomAmount, "Insufficient authorized amount");

        IERC20(_erc20Address).transferFrom(
            fromAddress,
            msg.sender,
            randomAmount
        );

        mossaiStorage.setUint(
            mossaiStorage.genKey("releaseAmount", id),
            releaseAmount
        );

        mossaiStorage.setUint(lastReleaseTimeKey, timestamp);

        emit eveReceiveAirdrop(id, msg.sender, randomAmount);

        emit eveSave(id);
    }

    function withdraw(uint256 id, uint256 amount) public {
        MOSSAI_Storage mossaiStorage = MOSSAI_Storage(_MOSSAIStorageAddress);
        string memory _name = mossaiStorage.getString(
            mossaiStorage.genKey("name", id)
        );

        require(bytes(_name).length > 0, "not found");

        uint256 islandId = mossaiStorage.getUint(
            mossaiStorage.genKey("islandId", id)
        );

        (, , , , , , , , uint32 seed, ) = IMOSSAIIsland(_MOSSAIIslandAddress)
            .getIsland(islandId);

        address seedOwer = IMOSSAIIslandNFG(_MOSSAIIslandNFGAddress)
            .getSeedOwer(seed);

        require(msg.sender == seedOwer, "not island ower");

        uint256 releaseAmount = mossaiStorage.getUint(
            mossaiStorage.genKey("releaseAmount", id)
        );

        uint256 totalAmount = mossaiStorage.getUint(
            mossaiStorage.genKey("totalAmount", id)
        );

        releaseAmount = releaseAmount + amount;

        require(releaseAmount <= totalAmount, "release amount is not enough");

        address fromAddress = mossaiStorage.getAddress(
            mossaiStorage.genKey("fromAddress", id)
        );

        uint256 allowance = IERC20(_erc20Address).allowance(
            fromAddress,
            address(this)
        );

        require(allowance >= amount, "Insufficient authorized amount");

        IERC20(_erc20Address).transferFrom(fromAddress, msg.sender, amount);

        mossaiStorage.setUint(
            mossaiStorage.genKey("releaseAmount", id),
            releaseAmount
        );

        emit eveReceiveAirdrop(id, msg.sender, amount);

        emit eveSave(id);
    }

    /**
     * @dev Generates a random number between _start and _end (exclusive) using block difficulty, timestamp and a private variable _rand.
     * @param _start The start of the range (inclusive).
     * @param _end The end of the range (exclusive).
     * @return A random number between _start and _end (exclusive).
     */
    function _getRandom(
        uint256 _start,
        uint256 _end
    ) private returns (uint256) {
        if (_start == _end) {
            return _start;
        }
        uint256 _length = _end - _start;
        uint256 random = uint256(
            keccak256(
                abi.encodePacked(block.difficulty, block.timestamp, _rand)
            )
        );
        random = (random % _length) + _start;
        _rand++;
        return random;
    }

    function setContractAddress(
        address[] memory contractaddressArray
    ) public onlyOwner {
        _MOSSAIRolesCfgAddress = contractaddressArray[0];
        _erc20Address = contractaddressArray[1];
        _MOSSAIIslandAddress = contractaddressArray[2];
        _MOSSAIIslandNFGAddress = contractaddressArray[3];
        _MOSSAIStorageAddress = contractaddressArray[4];
    }
}
