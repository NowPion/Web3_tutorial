// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract SimpleVoting {

    // 提案结构体
    struct Proposal {
        string description;
        uint256 voteCount;
    }

    // 合约创建者（管理员）
    address public owner;

    // 提案列表
    mapping(uint256 => Proposal) public proposals;

    // 记录某个地址是否对某个提案投过票
    mapping(address => mapping(uint256 => bool)) public hasVoted;

    // 提案数量
    uint256 public proposalCount;

    // 事件：创建提案
    event ProposalCreated(uint256 proposalId, string description);

    // 事件：投票
    event Voted(address voter, uint256 proposalId);

    // 修饰器：仅管理员
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    // 构造函数
    constructor() {
        owner = msg.sender;
    }

    // 创建提案（仅管理员）
    function createProposal(string memory _description) public onlyOwner {
        proposalCount++;

        proposals[proposalCount] = Proposal({
            description: _description,
            voteCount: 0
        });

        emit ProposalCreated(proposalCount, _description);
    }

    // 投票
    function vote(uint256 _proposalId) public {
        require(_proposalId > 0 && _proposalId <= proposalCount, "Invalid proposal");
        require(!hasVoted[msg.sender][_proposalId], "Already voted");

        proposals[_proposalId].voteCount++;
        hasVoted[msg.sender][_proposalId] = true;

        emit Voted(msg.sender, _proposalId);
    }

    // 查询投票数
    function getVotes(uint256 _proposalId) public view returns (uint256) {
        require(_proposalId > 0 && _proposalId <= proposalCount, "Invalid proposal");
        return proposals[_proposalId].voteCount;
    }
}