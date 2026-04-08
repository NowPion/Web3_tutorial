# Web3 智能合约学习项目清单

## 📚 项目概述
这份文档为你提供了 10 个由浅入深的智能合约项目，帮助你系统学习 Solidity 和 Web3 开发。

---

## 🎯 初级项目 (1-3)

### 项目 1: 简单投票系统 (Simple Voting)
**难度**: ⭐  
**学习目标**: 
- 掌握基本的状态变量和函数
- 理解 mapping 的使用
- 学习访问控制

**功能需求**:
- 创建投票提案
- 用户可以投票
- 查询投票结果
- 只有合约创建者可以创建提案

**核心知识点**:
```solidity
- address 类型
- mapping(address => bool)
- modifier (onlyOwner)
- struct 结构体
- event 事件
```

**参考实现思路**:
```solidity
contract SimpleVoting {
    struct Proposal {
        string description;
        uint256 voteCount;
    }
    
    address public owner;
    mapping(uint256 => Proposal) public proposals;
    mapping(address => mapping(uint256 => bool)) public hasVoted;
    uint256 public proposalCount;
    
    // 实现创建提案、投票、查询功能
}
```

---

### 项目 2: ERC20 代币 (My Token)
**难度**: ⭐⭐  
**学习目标**:
- 理解 ERC20 标准
- 掌握代币的铸造和转账
- 学习 OpenZeppelin 库的使用

**功能需求**:
- 发行自己的代币
- 实现转账功能
- 实现授权转账 (approve/transferFrom)
- 查询余额和总供应量

**核心知识点**:
```solidity
- ERC20 接口标准
- totalSupply, balanceOf, transfer
- approve, allowance, transferFrom
- SafeMath (溢出保护)
```

**参考资源**:
- OpenZeppelin ERC20: https://docs.openzeppelin.com/contracts/erc20

---

### 项目 3: 众筹合约 (Crowdfunding)
**难度**: ⭐⭐  
**学习目标**:
- 处理以太币转账
- 时间控制逻辑
- 退款机制

**功能需求**:
- 设置众筹目标和截止时间
- 用户可以捐款
- 达到目标后创建者可以提取资金
- 未达到目标用户可以退款

**核心知识点**:
```solidity
- payable 函数
- msg.value, msg.sender
- block.timestamp
- address.transfer() / address.call{value: }()
- require 条件检查
```

---

## 🚀 中级项目 (4-6)

### 项目 4: NFT 市场 (NFT Marketplace)
**难度**: ⭐⭐⭐  
**学习目标**:
- 理解 ERC721 标准
- 实现 NFT 铸造和交易
- 学习合约间交互

**功能需求**:
- 铸造 NFT (mint)
- 上架 NFT 出售
- 购买 NFT
- 取消上架
- 收取平台手续费

**核心知识点**:
```solidity
- ERC721 标准
- tokenURI 和元数据
- 合约间调用
- 手续费计算
- 安全转账
```

---

### 项目 5: 去中心化交易所 (Simple DEX)
**难度**: ⭐⭐⭐  
**学习目标**:
- 理解 AMM (自动做市商) 机制
- 实现流动性池
- 计算交易价格

**功能需求**:
- 添加流动性
- 移除流动性
- 代币兑换 (swap)
- 计算兑换价格

**核心知识点**:
```solidity
- 恒定乘积公式 (x * y = k)
- 流动性代币 (LP Token)
- 滑点控制
- 重入攻击防护
```

**参考资源**:
- Uniswap V2 原理

---

### 项目 6: 多签钱包 (Multi-Sig Wallet)
**难度**: ⭐⭐⭐  
**学习目标**:
- 实现多重签名机制
- 交易提案和确认流程
- 安全性设计

**功能需求**:
- 添加/移除所有者
- 提交交易提案
- 确认交易
- 执行交易 (达到确认数)
- 撤销确认

**核心知识点**:
```solidity
- 多签逻辑
- 交易队列管理
- 动态数组操作
- call 低级调用
```

---

## 💎 高级项目 (7-10)

### 项目 7: 借贷协议 (Lending Protocol)
**难度**: ⭐⭐⭐⭐  
**学习目标**:
- 实现抵押借贷
- 利息计算
- 清算机制

**功能需求**:
- 存款赚取利息
- 抵押借款
- 还款
- 清算不足抵押的仓位
- 利率模型

**核心知识点**:
```solidity
- 复利计算
- 抵押率 (LTV)
- 预言机价格获取
- 清算激励
```

---

### 项目 8: DAO 治理合约 (DAO Governance)
**难度**: ⭐⭐⭐⭐  
**学习目标**:
- 实现链上治理
- 提案和投票机制
- 时间锁

**功能需求**:
- 创建治理提案
- 投票 (支持/反对/弃权)
- 提案执行
- 委托投票权
- 时间锁保护

**核心知识点**:
```solidity
- 治理代币
- 投票权重计算
- 提案状态机
- Timelock 合约
- 可升级合约模式
```

---

### 项目 9: 链上游戏 (On-Chain Game)
**难度**: ⭐⭐⭐⭐  
**学习目标**:
- 随机数生成
- 游戏逻辑实现
- Gas 优化

**功能需求**:
- 实现一个简单的抽奖/猜数字游戏
- 使用 Chainlink VRF 生成随机数
- 奖池管理
- 防作弊机制

**核心知识点**:
```solidity
- Chainlink VRF (可验证随机函数)
- 状态管理
- Gas 优化技巧
- 防止前置交易攻击
```

---

### 项目 10: 跨链桥 (Cross-Chain Bridge)
**难度**: ⭐⭐⭐⭐⭐  
**学习目标**:
- 理解跨链通信
- 实现资产锁定和铸造
- 验证机制

**功能需求**:
- 锁定源链资产
- 在目标链铸造映射资产
- 验证跨链消息
- 资产赎回

**核心知识点**:
```solidity
- 跨链消息传递
- 锁定-铸造模式
- 多签验证
- Merkle 证明
```

---

## 📖 学习路径建议

### 第一阶段 (1-2 周)
完成项目 1-3，掌握 Solidity 基础语法和常见模式

### 第二阶段 (2-3 周)
完成项目 4-6，理解 DeFi 和 NFT 的核心概念

### 第三阶段 (3-4 周)
完成项目 7-10，深入学习高级特性和安全性

---

## 🛠️ 开发工具推荐

### 开发框架
- **Hardhat**: 最流行的以太坊开发环境
- **Foundry**: 快速的 Rust 实现的开发工具
- **Remix**: 在线 IDE，适合快速测试

### 测试网络
- **Sepolia**: 以太坊测试网
- **Mumbai**: Polygon 测试网
- **BSC Testnet**: 币安智能链测试网

### 工具库
- **OpenZeppelin**: 安全的智能合约库
- **Chainlink**: 预言机和 VRF
- **Ethers.js**: 与区块链交互的 JS 库

---

## 📚 学习资源

### 官方文档
- Solidity 官方文档: https://docs.soliditylang.org/
- OpenZeppelin 文档: https://docs.openzeppelin.com/
- Ethereum 官方文档: https://ethereum.org/developers

### 教程网站
- CryptoZombies: 游戏化学习 Solidity
- Solidity by Example: 代码示例集合
- Alchemy University: 免费的 Web3 课程

### 安全资源
- Smart Contract Security Best Practices
- Consensys Security Tools
- OpenZeppelin Security Audits

---

## ⚠️ 安全注意事项

在开发智能合约时，务必注意：

1. **重入攻击**: 使用 ReentrancyGuard
2. **整数溢出**: 使用 Solidity 0.8+ 或 SafeMath
3. **访问控制**: 正确使用 modifier
4. **随机数**: 不要使用 block.timestamp 或 blockhash
5. **Gas 限制**: 避免无限循环
6. **前置交易**: 考虑 MEV 攻击
7. **审计**: 重要合约上线前进行安全审计

---

## 🎓 下一步行动

1. 选择一个项目开始
2. 搭建开发环境 (Hardhat/Foundry)
3. 编写合约代码
4. 编写测试用例
5. 部署到测试网
6. 构建前端界面 (可选)

祝你学习顺利！有问题随时问我 🚀
