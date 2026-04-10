# SimpleVoting Vue 前端

一个基于 Vue 3 + Vite + ethers.js 的投票系统前端。

## 功能

- 连接 MetaMask 钱包
- 输入并连接 `SimpleVoting` 合约地址
- 读取提案列表和票数
- 对提案投票（同一地址同一提案只能投一次）
- 管理员账户可创建提案

## 启动

```bash
npm install
npm run dev
```

打开控制台给出的本地地址（通常是 `http://localhost:5173`）。

## 使用步骤

1. 在钱包中切换到你部署合约的网络。
2. 点击“连接钱包”。
3. 输入部署后的 `SimpleVoting` 合约地址，点击“连接合约”。
4. 即可查看提案、投票；若当前账户是管理员，可创建提案。

## 说明

- 合约 ABI 在 `src/App.vue` 内写死为当前教程合约接口。
- 合约地址会保存在浏览器 `localStorage` 中。