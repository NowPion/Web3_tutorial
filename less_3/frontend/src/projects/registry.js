export const projectEntries = [
  {
    id: 'simple-voting',
    title: 'SimpleVoting',
    description: '投票合约：连接钱包、创建提案、投票、事件订阅。',
    path: '/projects/simple-voting',
    component: () => import('./simple-voting/SimpleVotingPage.vue'),
  },
  {
    id: 'my-token',
    title: 'MyToken ERC20',
    description: 'ERC20 代币：查询余额总量、transfer、approve、transferFrom。',
    path: '/projects/my-token',
    component: () => import('./my-token/MyTokenPage.vue'),
  },
]

export const projectRoutes = projectEntries.map((item) => ({
  path: item.path,
  name: item.id,
  component: item.component,
  meta: {
    title: item.title,
    description: item.description,
  },
}))