// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

// 众筹合约
// 1. 创建一个收款函数
// 2. 记录投资人并且查看
// 3. 在规定时间内，达到目标值，发起人可以提款
// 4. 在规定时间内，没有达到目标值，投资人可以退款

contract FundMe {
    AggregatorV3Interface internal dataFeed;

    mapping(address => uint256) public fundToAmount;
    mapping(address => bool) public isFunder;
    address[] public funders;

    uint256 public constant MINIMUM_VALUE = 1 * 10 ** 18;
    uint256 public constant TARGET = 22 * 10 ** 18;
    uint256 public constant FUNDING_DURATION = 3 minutes;

    uint256 public immutable deadline;
    uint256 public totalFunded;
    bool public withdrawn;

    address public owner;

    // ================== 事件 ==================
    event Funded(address indexed funder, uint256 amount);
    event Withdrawn(address indexed owner, uint256 amount);
    event Refunded(address indexed funder, uint256 amount);
    event OwnershipTransferred(address indexed oldOwner, address indexed newOwner);

    constructor() {
        dataFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        owner = msg.sender;
        deadline = block.timestamp + FUNDING_DURATION;
    }

    // ================== 投资 ==================
    function fund() external payable {
        require(block.timestamp < deadline, "Funding ended");
        require(convertEthToUsd(msg.value) >= MINIMUM_VALUE, "Send more ETH");

        fundToAmount[msg.sender] += msg.value;
        totalFunded += msg.value;

        if (!isFunder[msg.sender]) {
            isFunder[msg.sender] = true;
            funders.push(msg.sender);
        }

        emit Funded(msg.sender, msg.value);
    }

    // ================== 获取价格 ==================
    function getChainlinkDataFeedLatestAnswer() public view returns (int256) {
        (, int256 answer, , , ) = dataFeed.latestRoundData();
        require(answer > 0, "Invalid price");
        return answer;
    }

    function convertEthToUsd(uint256 ethAmount) internal view returns (uint256) {
        uint256 ethPrice = uint256(getChainlinkDataFeedLatestAnswer());
        return (ethAmount * ethPrice) / (10 ** 8);
    }

    // ================== 提款 ==================
    function getFund() external {
        require(block.timestamp >= deadline, "Funding not ended");
        require(convertEthToUsd(totalFunded) >= TARGET, "Target not reached");
        require(msg.sender == owner, "Only owner");
        require(!withdrawn, "Already withdrawn");

        withdrawn = true;
        uint256 balance = address(this).balance;

        (bool success, ) = payable(msg.sender).call{value: balance}("");
        require(success, "Withdraw failed");

        emit Withdrawn(msg.sender, balance);
    }

    // ================== 退款 ==================
    function refund() external {
        require(block.timestamp >= deadline, "Funding not ended");
        require(convertEthToUsd(totalFunded) < TARGET, "Target reached");

        uint256 amount = fundToAmount[msg.sender];
        require(amount > 0, "No fund to refund");

        fundToAmount[msg.sender] = 0;
        totalFunded -= amount;

        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, "Refund failed");

        emit Refunded(msg.sender, amount);
    }

    function getFundersLength() external view returns (uint256) {
        return funders.length;
    }

    // ================== 转移所有权 ==================
    function transferOwnership(address newOwner) public {
        require(msg.sender == owner, "Only owner");
        require(newOwner != address(0), "Invalid owner");

        address oldOwner = owner;
        owner = newOwner;

        emit OwnershipTransferred(oldOwner, newOwner);
    }
}
