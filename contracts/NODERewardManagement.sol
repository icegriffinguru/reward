/**
 *Submitted for verification at snowtrace.io on 2022-01-10
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./IterableMapping.sol";

import "hardhat/console.sol";

contract NODERewardManagement {
    using SafeMath for uint256;
    using IterableMapping for IterableMapping.Map;

    struct NodeEntity {
        //# we won't need name anymore
        // string name;
        uint256 creationTime;
        uint256 lastClaimTime;
        // uint256 rewardAvailable;
    }

    IterableMapping.Map private nodeOwners;
    mapping(address => NodeEntity[]) private _nodesOfUser;

    uint256 public nodePrice;
    uint256 public rewardPerNode;
    uint256 public claimTime;

    address public gateKeeper;
    address public token;

    bool public autoDistri = true;
    bool public distribution = false;

    uint256 public gasForDistribution = 500000;
    uint256 public lastDistributionCount = 0;
    uint256 public lastIndexProcessed = 0;

    uint256 public totalNodesCreated = 0;
    uint256 public totalRewardStaked = 0;

    constructor(
        uint256 _nodePrice,
        uint256 _rewardPerNode,
        uint256 _claimTime
    ) {
        nodePrice = _nodePrice;
        rewardPerNode = _rewardPerNode;
        claimTime = _claimTime;
        gateKeeper = msg.sender;
    }

    modifier onlySentry() {
        require(msg.sender == token || msg.sender == gateKeeper, "Fuck off");
        _;
    }

    function setToken (address token_) external onlySentry {
        token = token_;
    }

    function distributeRewards(uint256 gas, uint256 rewardNode)
    private
    returns (
        uint256,
        uint256,
        uint256
    )
    {
        distribution = true;
        uint256 numberOfnodeOwners = nodeOwners.keys.length;
        require(numberOfnodeOwners > 0, "DISTRI REWARDS: NO NODE OWNERS");
        if (numberOfnodeOwners == 0) {
            return (0, 0, lastIndexProcessed);
        }

        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();
        uint256 newGasLeft;
        uint256 localLastIndex = lastIndexProcessed;
        uint256 iterations = 0;
        uint256 newClaimTime = block.timestamp;
        uint256 nodesCount;
        uint256 claims = 0;
        NodeEntity[] storage nodes;
        NodeEntity storage _node;

        while (gasUsed < gas && iterations < numberOfnodeOwners) {
            localLastIndex++;
            if (localLastIndex >= nodeOwners.keys.length) {
                localLastIndex = 0;
            }
            nodes = _nodesOfUser[nodeOwners.keys[localLastIndex]];
            nodesCount = nodes.length;
            for (uint256 i = 0; i < nodesCount; i++) {
                _node = nodes[i];
                if (claimable(_node)) {
                    // _node.rewardAvailable += rewardNode;
                    _node.lastClaimTime = newClaimTime;
                    totalRewardStaked += rewardNode;
                    claims++;
                }
            }
            iterations++;

            newGasLeft = gasleft();

            if (gasLeft > newGasLeft) {
                gasUsed = gasUsed.add(gasLeft.sub(newGasLeft));
            }

            gasLeft = newGasLeft;
        }
        lastIndexProcessed = localLastIndex;
        distribution = false;
        return (iterations, claims, lastIndexProcessed);
    }

    // function createNode(address account, string memory nodeName) external onlySentry {
        // require(
        //     isNameAvailable(account, nodeName),
        //     "CREATE NODE: Name not available"
        // );
    function createNode(address account, string memory nodeName) public onlySentry {
        _nodesOfUser[account].push(
            NodeEntity({
                // name: nodeName,
                creationTime: block.timestamp,
                lastClaimTime: block.timestamp
                // rewardAvailable: 0
            })
        );
        totalNodesCreated++;
        nodeOwners.set(account, _nodesOfUser[account].length);

        //# Stop auto distritbution of rewards
        // if (autoDistri && !distribution) {
        //     distributeRewards(gasForDistribution, rewardPerNode);
        // }
    }

    // function isNameAvailable(address account, string memory nodeName)
    // private
    // view
    // returns (bool)
    // {
    //     NodeEntity[] memory nodes = _nodesOfUser[account];
    //     for (uint256 i = 0; i < nodes.length; i++) {
    //         if (keccak256(bytes(nodes[i].name)) == keccak256(bytes(nodeName))) {
    //             return false;
    //         }
    //     }
    //     return true;
    // }

    function _burn(uint256 index) internal {
        require(index < nodeOwners.size());
        nodeOwners.remove(nodeOwners.getKeyAtIndex(index));
    }

    function _getNodeWithCreatime(
        NodeEntity[] storage nodes,
        uint256 _creationTime
    ) private view returns (NodeEntity storage) {

        // console.logString('--------_getNodeWithCreatime-------');
        // console.logUint(nodes.length);
        // console.logUint(_creationTime);
        // console.logString('--------_getNodeWithCreatime-------');

        uint256 numberOfNodes = nodes.length;
        require(
            numberOfNodes > 0,
            "CASHOUT ERROR: You don't have nodes to cash-out"
        );
        bool found = false;
        int256 index = binary_search(nodes, 0, numberOfNodes, _creationTime);
        uint256 validIndex;
        if (index >= 0) {
            found = true;
            validIndex = uint256(index);
        }
        require(found, "NODE SEARCH: No NODE Found with this blocktime");
        return nodes[validIndex];
    }

    function binary_search(
        NodeEntity[] memory arr,
        uint256 low,
        uint256 high,
        uint256 x
    ) private view returns (int256) {
        if (high >= low) {
            uint256 mid = (high + low).div(2);
            if (arr[mid].creationTime == x) {
                return int256(mid);
            } else if (arr[mid].creationTime > x) {
                return binary_search(arr, low, mid - 1, x);
            } else {
                return binary_search(arr, mid + 1, high, x);
            }
        } else {
            return -1;
        }
    }

    //# calculate reward of a node according to the given formula
    function calculateRewardOfNode(NodeEntity memory node) private view returns (uint256) {
        uint256 reward = rewardPerNode.mul(block.timestamp.sub(node.lastClaimTime)).div(claimTime);
        // uint256 reward = rewardPerNode.mul(block.timestamp.sub(node.lastClaimTime));
        return reward;
    }

    function _cashoutNodeReward(address account, uint256 _creationTime)
    external onlySentry
    returns (uint256)
    {
        require(_creationTime > 0, "NODE: CREATIME must be higher than zero");
        NodeEntity[] storage nodes = _nodesOfUser[account];
        uint256 numberOfNodes = nodes.length;
        require(
            numberOfNodes > 0,
            "CASHOUT ERROR: You don't have nodes to cash-out"
        );
        NodeEntity storage node = _getNodeWithCreatime(nodes, _creationTime);

        //# change reward value
        uint256 rewardNode = calculateRewardOfNode(node);
        // uint256 rewardNode = node.rewardAvailable;

        // console.logString('--------_cashoutNodeReward-------');
        // console.logString(node.name);
        // console.logUint(rewardNode);
        // console.logString('--------_cashoutNodeReward-------');

        // node.rewardAvailable = 0;
        return rewardNode;
    }

    function _cashoutAllNodesReward(address account)
    external onlySentry
    returns (uint256)
    {
        NodeEntity[] storage nodes = _nodesOfUser[account];
        uint256 nodesCount = nodes.length;
        require(nodesCount > 0, "NODE: CREATIME must be higher than zero");
        NodeEntity storage _node;
        uint256 rewardsTotal = 0;
        for (uint256 i = 0; i < nodesCount; i++) {
            _node = nodes[i];

            //# change reward value
            rewardsTotal += calculateRewardOfNode(_node);
            // rewardsTotal += _node.rewardAvailable;
            // _node.rewardAvailable = 0;
        }
        return rewardsTotal;
    }

    function claimable(NodeEntity memory node) private view returns (bool) {
        //# check if the account can claim a reward after claimTime since the last claim
        return node.lastClaimTime + claimTime >= block.timestamp;
        // return node.lastClaimTime + claimTime <= block.timestamp;
    }

    function _getRewardAmountOf(address account)
    external
    view
    returns (uint256)
    {
        require(isNodeOwner(account), "GET REWARD OF: NO NODE OWNER");
        uint256 nodesCount;
        uint256 rewardCount = 0;

        NodeEntity[] storage nodes = _nodesOfUser[account];
        nodesCount = nodes.length;

        for (uint256 i = 0; i < nodesCount; i++) {
            //# change reward value
            rewardCount += calculateRewardOfNode(nodes[i]);
            // rewardCount += nodes[i].rewardAvailable;
        }

        return rewardCount;
    }

    function _getRewardAmountOf(address account, uint256 _creationTime)
    external
    view
    returns (uint256)
    {
        require(isNodeOwner(account), "GET REWARD OF: NO NODE OWNER");

        require(_creationTime > 0, "NODE: CREATIME must be higher than zero");
        NodeEntity[] storage nodes = _nodesOfUser[account];
        uint256 numberOfNodes = nodes.length;
        require(
            numberOfNodes > 0,
            "CASHOUT ERROR: You don't have nodes to cash-out"
        );
        NodeEntity storage node = _getNodeWithCreatime(nodes, _creationTime);

        //# change reward value
        uint256 rewardNode = calculateRewardOfNode(node);
        // uint256 rewardNode = node.rewardAvailable;

        return rewardNode;
    }

    function _getNodeRewardAmountOf(address account, uint256 creationTime)
    external
    view
    returns (uint256)
    {
        // return
        // _getNodeWithCreatime(_nodesOfUser[account], creationTime)
        // .rewardAvailable;

        //# change reward value
        uint256 rewardOfNode = calculateRewardOfNode(_getNodeWithCreatime(_nodesOfUser[account], creationTime));
        return rewardOfNode;
    }

    function _getNodesNames(address account)
    external
    view
    returns (string memory)
    {
        // require(isNodeOwner(account), "GET NAMES: NO NODE OWNER");
        // NodeEntity[] memory nodes = _nodesOfUser[account];
        // uint256 nodesCount = nodes.length;
        // NodeEntity memory _node;
        // string memory names = nodes[0].name;
        // string memory separator = "#";

        // console.logString('--------_getNodesNames-------');
        // console.logUint(nodesCount);
        // console.logString(names);
        // console.logString('--------_getNodesNames-------');


        // for (uint256 i = 1; i < nodesCount; i++) {
        //     _node = nodes[i];
        //     names = string(abi.encodePacked(names, separator, _node.name));
        // }
        // return names;

        return "NONE";
    }

    function _getNodesCreationTime(address account)
    external
    view
    returns (string memory)
    {
        require(isNodeOwner(account), "GET CREATIME: NO NODE OWNER");
        NodeEntity[] memory nodes = _nodesOfUser[account];
        uint256 nodesCount = nodes.length;
        NodeEntity memory _node;
        string memory _creationTimes = uint2str(nodes[0].creationTime);
        string memory separator = "#";

        for (uint256 i = 1; i < nodesCount; i++) {
            _node = nodes[i];

            _creationTimes = string(
                abi.encodePacked(
                    _creationTimes,
                    separator,
                    uint2str(_node.creationTime)
                )
            );
        }
        return _creationTimes;
    }

    function _getNodesRewardAvailable(address account)
    external
    view
    returns (string memory)
    {
        require(isNodeOwner(account), "GET REWARD: NO NODE OWNER");
        NodeEntity[] memory nodes = _nodesOfUser[account];
        uint256 nodesCount = nodes.length;
        NodeEntity memory _node;

        //#
        string memory _rewardsAvailable = uint2str(calculateRewardOfNode(nodes[0]));
        // string memory _rewardsAvailable = uint2str(nodes[0].rewardAvailable);

        string memory separator = "#";

        for (uint256 i = 1; i < nodesCount; i++) {
            _node = nodes[i];

            _rewardsAvailable = string(
                abi.encodePacked(
                    _rewardsAvailable,
                    separator,

                    //# change reward value
                    calculateRewardOfNode(_node)
                    // uint2str(_node.rewardAvailable)
                )
            );
        }
        return _rewardsAvailable;
    }

    function _getNodesLastClaimTime(address account)
    external
    view
    returns (string memory)
    {
        require(isNodeOwner(account), "LAST CLAIME TIME: NO NODE OWNER");
        NodeEntity[] memory nodes = _nodesOfUser[account];
        uint256 nodesCount = nodes.length;
        NodeEntity memory _node;
        string memory _lastClaimTimes = uint2str(nodes[0].lastClaimTime);
        string memory separator = "#";

        for (uint256 i = 1; i < nodesCount; i++) {
            _node = nodes[i];

            _lastClaimTimes = string(
                abi.encodePacked(
                    _lastClaimTimes,
                    separator,
                    uint2str(_node.lastClaimTime)
                )
            );
        }
        return _lastClaimTimes;
    }

    function uint2str(uint256 _i)
    internal
    pure
    returns (string memory _uintAsString)
    {
        if (_i == 0) {
            return "0";
        }
        uint256 j = _i;
        uint256 len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint256 k = len;
        while (_i != 0) {
            k = k - 1;
            uint8 temp = (48 + uint8(_i - (_i / 10) * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }

    function _changeNodePrice(uint256 newNodePrice) external onlySentry {
        nodePrice = newNodePrice;
    }

    function _changeRewardPerNode(uint256 newPrice) external onlySentry {
        rewardPerNode = newPrice;
    }

    function _changeClaimTime(uint256 newTime) external onlySentry {
        claimTime = newTime;
    }

    function _changeAutoDistri(bool newMode) external onlySentry {
        autoDistri = newMode;
    }

    function _changeGasDistri(uint256 newGasDistri) external onlySentry {
        gasForDistribution = newGasDistri;
    }

    function _getNodeNumberOf(address account) public view returns (uint256) {
        return nodeOwners.get(account);
    }

    function isNodeOwner(address account) private view returns (bool) {
        return nodeOwners.get(account) > 0;
    }

    function _isNodeOwner(address account) external view returns (bool) {
        return isNodeOwner(account);
    }

    function _distributeRewards()
    external  onlySentry
    returns (
        uint256,
        uint256,
        uint256
    )
    {
        return distributeRewards(gasForDistribution, rewardPerNode);
    }

    function moveAccount(address oldNodeRewardManager, address account) public {
        // i've used _getNodesCreationTime rather than _getNodesNames because datetime has the same length and there is less probability to cause an error
        // call _getNodesCreationTime function of old NodeRewardManager
        (bool success, bytes memory times) = oldNodeRewardManager.call(abi.encodeWithSignature("_getNodesCreationTime(address)", account));

        uint256 nodesCount = 0;
        bytes memory btimes = bytes(times);
        uint256 len = btimes.length;

        // if length of times is bigger than one, it means there is one creation time at least
        if (len > 0) {
            nodesCount++;
        }

        // loop btimes and find if there is a '#' character
        for (uint256 i; i < len; i++) {
            if (btimes[i] != bytes('#')[0]) {
                nodesCount++;
            }
        }

        // create new nodes with the same number of the old nodes of the given account
        NodeEntity[] storage nodes = _nodesOfUser[account];
        nodesCount = nodes.length;
        for (uint256 i = 0; i < nodesCount; i++) {
            createNode(account, '');
        }
    }

    // function stringSplitter(string memory text) private pure returns (string[] memory) {
    //     string memory myVal = "my example split";
    //     string[] storage split = text.split("#");
    //     var s = text.toSlice();
    //     var delim = "-".toSlice();
    //     string[] memory parts = new string[](s.count(delim));
    //     for (uint i = 0; i < parts.length; i++) {                  
    //        parts[i] = s.split(delim).toString();
    //     }
    //     return parts;
    // }

    // function moveAccount(address oldNodeRewardManager, address account) public {
    //     (bool success, bytes memory result) = oldNodeRewardManager.call(abi.encodeWithSignature("_getNodesNames(address)", account));

    //     require(
    //         success || result.length > 0,
    //         "GET ACCOUNTS: getting nodes of the account failed. Maybe there is no node for the count."
    //     );

    //     // Decode data
    //     string memory nodeNames = abi.decode(result, (string));
    //     string[] memory names = splitString(nodeNames, "#");
    //     // string[] memory names = stringSplitter(nodeNames);

    //     uint256 nodesCount = names.length;
    //     for (uint256 i = 0; i < nodesCount; i++) {
    //         createNode(account, names[i]);
    //     }
    // }

    // /**
    //  * String Split (Very high gas cost)
    //  *
    //  * Splits a string into an array of strings based off the delimiter value.
    //  * Please note this can be quite a gas expensive function due to the use of
    //  * storage so only use if really required.
    //  *
    //  * @param _base When being used for a data type this is the extended object
    //  *               otherwise this is the string value to be split.
    //  * @param _value The delimiter to split the string on which must be a single
    //  *               character
    //  */
    // function splitString(string memory _base, string memory _value)
    //     internal
    //     pure
    //     returns (string[] memory splitArr) {
    //     bytes memory _baseBytes = bytes(_base);

    //     uint _offset = 0;
    //     uint _splitsCount = 1;
    //     while (_offset < _baseBytes.length - 1) {
    //         int _limit = _indexOf(_base, _value, _offset);
    //         if (_limit == -1)
    //             break;
    //         else {
    //             _splitsCount++;
    //             _offset = uint(_limit) + 1;
    //         }
    //     }

    //     splitArr = new string[](_splitsCount);

    //     _offset = 0;
    //     _splitsCount = 0;
    //     while (_offset < _baseBytes.length - 1) {

    //         int _limit = _indexOf(_base, _value, _offset);
    //         if (_limit == - 1) {
    //             _limit = int(_baseBytes.length);
    //         }

    //         string memory _tmp = new string(uint(_limit) - _offset);
    //         bytes memory _tmpBytes = bytes(_tmp);

    //         uint j = 0;
    //         for (uint i = _offset; i < uint(_limit); i++) {
    //             _tmpBytes[j++] = _baseBytes[i];
    //         }
    //         _offset = uint(_limit) + 1;
    //         splitArr[_splitsCount++] = string(_tmpBytes);
    //     }
    //     return splitArr;
    // }

    // /**
    //  * Index Of
    //  *
    //  * Locates and returns the position of a character within a string starting
    //  * from a defined offset
    //  * 
    //  * @param _base When being used for a data type this is the extended object
    //  *              otherwise this is the string acting as the haystack to be
    //  *              searched
    //  * @param _value The needle to search for, at present this is currently
    //  *               limited to one character
    //  * @param _offset The starting point to start searching from which can start
    //  *                from 0, but must not exceed the length of the string
    //  * @return int The position of the needle starting from 0 and returning -1
    //  *             in the case of no matches found
    //  */
    // function _indexOf(string memory _base, string memory _value, uint _offset)
    //     internal
    //     pure
    //     returns (int) {
    //     bytes memory _baseBytes = bytes(_base);
    //     bytes memory _valueBytes = bytes(_value);

    //     assert(_valueBytes.length == 1);

    //     for (uint i = _offset; i < _baseBytes.length; i++) {
    //         if (_baseBytes[i] == _valueBytes[0]) {
    //             return int(i);
    //         }
    //     }

    //     return -1;
    // }
}