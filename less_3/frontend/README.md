# Web3 Frontend Hub（Vue）

这是一个可扩展的 Web3 前端工程：**一个仓库管理多个合约前端页面**。

## 已有页面

- `SimpleVoting`：连接钱包、创建提案、投票、事件订阅
- `MyToken ERC20`：查询总供应量/余额，`transfer`，`approve`，`allowance`，`transferFrom`

## 目录结构

```text
src/
  router/
    index.js                 # 路由入口
  views/
    HomeView.vue             # 首页（项目导航）
  projects/
    registry.js              # 项目注册表（新增项目改这里）
    simple-voting/
      SimpleVotingPage.vue   # SimpleVoting 页面
  App.vue                    # 应用壳层（导航 + RouterView）
  main.js                    # 应用启动入口
```

## 启动

```bash
npm install
npm run dev
```

## 如何新增一个合约前端页面

1. 在 `src/projects/` 下新建目录，例如 `token-bank/`。
2. 新建页面组件，例如 `TokenBankPage.vue`。
3. 在 `src/projects/registry.js` 里注册：
   - `id`
   - `title`
   - `description`
   - `path`
   - `component: () => import('...')`

完成后首页和导航会自动出现入口。

## 当前技术栈

- Vue 3
- Vite
- vue-router 4
- ethers.js
