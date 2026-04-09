// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

// 众筹合约
// 1. 创建一个收款函数
// 2. 记录投资人并且查看
// 3. 在规定时间内容，达到目标值，生产商可以提款
// 4. 在规定时间内容，没有达到目标值，投资人可以退款

contract FundMe {

    AggregatorV3Interface internal dataFeed;

    mapping(address => uint256) public fundToAmout;

    uint256 MINIMNM_VALUE = 1 * 10 ** 18;

    //目标22刀
    uint256 constant TARGET = 22 * 10 ** 18;

    address public  owner;

    constructor() {
        dataFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        //合约部署人的地址
        owner = msg.sender;
    }

    function fund() external payable {
        require(converEthToUsd(msg.value) >= MINIMNM_VALUE,"Send more ETH");
        fundToAmout[msg.sender] = msg.value;
    }

    function getChainlinkDataFeedLatestAnswer() public view returns (int256) {
    // prettier-ignore
    (
      /* uint80 roundId */
      ,
      int256 answer,
      /*uint256 startedAt*/
      ,
      /*uint256 updatedAt*/
      ,
      /*uint80 answeredInRound*/
    ) = dataFeed.latestRoundData();
    return answer;
  }
    function converEthToUsd(uint256 ethAmount) internal view  returns(uint256) {
        uint256 ethPrice = uint256(getChainlinkDataFeedLatestAnswer());
        return ethAmount * ethPrice / (10 ** 8);
    }

    function getFund() external {
        require(converEthToUsd(address(this).balance)  >= TARGET,"target is not reached");
        require(msg.sender == owner,"this function can only be called by owenr");
        payable(msg.sender).transfer(address(this).balance);
    }

    function transferOWnership(address newOwner) public {
        require(msg.sender == owner,"this function can only be called by owenr");
        owner = newOwner;
    }
}