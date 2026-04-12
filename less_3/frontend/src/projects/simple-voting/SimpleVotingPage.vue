<script setup>
import { computed, onMounted, onUnmounted, ref, shallowRef } from 'vue'
import { ethers } from 'ethers'

const storageKey = 'simple_voting_contract_address'
const contractAddress = ref(localStorage.getItem(storageKey) || '')
const account = ref('')
const owner = ref('')
const provider = shallowRef(null)
const signer = shallowRef(null)
const contract = shallowRef(null)
const proposals = ref([])
const newProposal = ref('')
const loading = ref(false)
const message = ref('')
const proposalCreatedListener = shallowRef(null)
const votedListener = shallowRef(null)

const abi = [
  'function proposalCount() view returns (uint256)',
  'function proposals(uint256) view returns (string description, uint256 voteCount)',
  'function createProposal(string memory _description)',
  'function vote(uint256 _proposalId)',
  'function hasVoted(address,uint256) view returns (bool)',
  'function owner() view returns (address)',
]

const canInteract = computed(() => !!contract.value && !!account.value)
const isOwner = computed(
  () => account.value && owner.value && account.value.toLowerCase() === owner.value.toLowerCase(),
)

function shortAddress(addr) {
  if (!addr) return ''
  return `${addr.slice(0, 6)}...${addr.slice(-4)}`
}

function saveContractAddress() {
  localStorage.setItem(storageKey, contractAddress.value.trim())
}

async function connectWallet() {
  if (!window.ethereum) {
    message.value = '请先安装 MetaMask。'
    return
  }

  try {
    message.value = '正在连接钱包...'
    provider.value = new ethers.BrowserProvider(window.ethereum)
    await provider.value.send('eth_requestAccounts', [])
    signer.value = await provider.value.getSigner()
    account.value = await signer.value.getAddress()
    message.value = `钱包已连接：${shortAddress(account.value)}`
    await initContract()
  } catch (err) {
    message.value = `连接失败：${err?.shortMessage || err?.message || '未知错误'}`
  }
}

function clearEventSubscriptions() {
  if (!contract.value) return

  if (proposalCreatedListener.value) {
    contract.value.off('ProposalCreated', proposalCreatedListener.value)
    proposalCreatedListener.value = null
  }

  if (votedListener.value) {
    contract.value.off('Voted', votedListener.value)
    votedListener.value = null
  }
}

function subscribeContractEvents() {
  if (!contract.value) return

  clearEventSubscriptions()

  proposalCreatedListener.value = async (proposalId, description) => {
    message.value = `监听到新提案：#${proposalId.toString()} ${description}`
    await loadProposals()
  }

  votedListener.value = async (voter, proposalId) => {
    message.value = `监听到投票：${shortAddress(voter)} 投给 #${proposalId.toString()}`
    await loadProposals()
  }

  contract.value.on('ProposalCreated', proposalCreatedListener.value)
  contract.value.on('Voted', votedListener.value)
}

async function initContract() {
  if (!signer.value || !contractAddress.value.trim()) return

  try {
    saveContractAddress()
    clearEventSubscriptions()
    contract.value = new ethers.Contract(contractAddress.value.trim(), abi, signer.value)
    owner.value = await contract.value.owner()
    subscribeContractEvents()
    await loadProposals()
  } catch (err) {
    clearEventSubscriptions()
    contract.value = null
    proposals.value = []
    message.value = `合约初始化失败：${err?.shortMessage || err?.message || '地址或网络不正确'}`
  }
}

async function loadProposals() {
  if (!contract.value) return

  loading.value = true
  try {
    const count = Number(await contract.value.proposalCount())
    const rows = []

    for (let i = 1; i <= count; i++) {
      const p = await contract.value.proposals(i)
      const voted = account.value ? await contract.value.hasVoted(account.value, i) : false
      rows.push({
        id: i,
        description: p.description,
        voteCount: Number(p.voteCount),
        voted,
      })
    }

    proposals.value = rows
    message.value = `已加载 ${rows.length} 个提案。`
  } catch (err) {
    message.value = `读取提案失败：${err?.shortMessage || err?.message || '未知错误'}`
  } finally {
    loading.value = false
  }
}

async function vote(proposalId) {
  if (!contract.value) return

  try {
    loading.value = true
    message.value = `提交投票交易中（提案 #${proposalId}）...`
    const tx = await contract.value.vote(proposalId)
    await tx.wait()
    message.value = `投票成功，交易哈希：${tx.hash}`
    await loadProposals()
  } catch (err) {
    message.value = `投票失败：${err?.shortMessage || err?.message || '未知错误'}`
  } finally {
    loading.value = false
  }
}

async function createProposal() {
  if (!contract.value || !newProposal.value.trim()) return

  try {
    loading.value = true
    message.value = '创建提案交易提交中...'
    const tx = await contract.value.createProposal(newProposal.value.trim())
    await tx.wait()
    newProposal.value = ''
    message.value = `提案创建成功，交易哈希：${tx.hash}`
    await loadProposals()
  } catch (err) {
    message.value = `创建提案失败：${err?.shortMessage || err?.message || '未知错误'}`
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  if (window.ethereum) {
    window.ethereum.on('accountsChanged', () => window.location.reload())
    window.ethereum.on('chainChanged', () => window.location.reload())
  }
})

onUnmounted(() => {
  clearEventSubscriptions()
})
</script>

<template>
  <div class="page">
    <div class="card">
      <h1>SimpleVoting</h1>
      <p class="hint">先连接 MetaMask，再填入已部署的合约地址。</p>

      <div class="row">
        <button class="btn" @click="connectWallet" :disabled="loading">
          {{ account ? '重新连接钱包' : '连接钱包' }}
        </button>
        <span v-if="account" class="tag">当前账户：{{ shortAddress(account) }}</span>
      </div>

      <div class="row">
        <input
          v-model="contractAddress"
          placeholder="输入合约地址（0x...）"
          class="input"
        />
        <button class="btn ghost" @click="initContract" :disabled="loading || !account">
          连接合约
        </button>
      </div>

      <p v-if="owner" class="hint">合约管理员：{{ shortAddress(owner) }}</p>
      <p class="msg">{{ message }}</p>
    </div>

    <div class="card" v-if="canInteract">
      <div class="section-title">提案列表</div>
      <button class="btn ghost" @click="loadProposals" :disabled="loading">刷新提案</button>

      <div v-if="proposals.length === 0" class="empty">暂无提案</div>

      <ul v-else class="list">
        <li v-for="item in proposals" :key="item.id" class="item">
          <div>
            <strong>#{{ item.id }}</strong>
            <p>{{ item.description }}</p>
          </div>
          <div class="right">
            <span class="votes">票数：{{ item.voteCount }}</span>
            <button
              class="btn"
              @click="vote(item.id)"
              :disabled="loading || item.voted"
            >
              {{ item.voted ? '已投票' : '投票' }}
            </button>
          </div>
        </li>
      </ul>
    </div>

    <div class="card" v-if="canInteract && isOwner">
      <div class="section-title">管理员：创建提案</div>
      <div class="row">
        <input
          v-model="newProposal"
          class="input"
          placeholder="输入提案内容"
        />
        <button class="btn" @click="createProposal" :disabled="loading || !newProposal.trim()">
          创建
        </button>
      </div>
    </div>
  </div>
</template>

<style scoped>
.page {
  display: grid;
  gap: 16px;
}

.card {
  background: #ffffff;
  border-radius: 16px;
  padding: 18px;
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.06);
  border: 1px solid #e5e7eb;
}

h1 {
  margin: 0 0 8px;
  font-size: 24px;
}

.hint {
  color: #6b7280;
  margin: 4px 0 10px;
}

.row {
  display: flex;
  gap: 10px;
  align-items: center;
  margin: 10px 0;
  flex-wrap: wrap;
}

.input {
  flex: 1;
  min-width: 260px;
  border: 1px solid #d1d5db;
  border-radius: 10px;
  padding: 10px 12px;
  font-size: 14px;
}

.btn {
  border: none;
  border-radius: 10px;
  padding: 10px 14px;
  cursor: pointer;
  background: #4f46e5;
  color: white;
  font-weight: 600;
}

.btn:hover {
  filter: brightness(1.05);
}

.btn:disabled {
  opacity: 0.55;
  cursor: not-allowed;
}

.btn.ghost {
  background: #111827;
}

.tag {
  background: #eef2ff;
  color: #3730a3;
  border-radius: 999px;
  padding: 6px 12px;
  font-size: 13px;
}

.msg {
  margin: 8px 0 0;
  font-size: 14px;
  color: #334155;
  word-break: break-all;
}

.section-title {
  font-size: 18px;
  font-weight: 700;
  margin-bottom: 10px;
}

.empty {
  color: #6b7280;
  margin-top: 8px;
}

.list {
  list-style: none;
  margin: 12px 0 0;
  padding: 0;
  display: grid;
  gap: 10px;
}

.item {
  border: 1px solid #e5e7eb;
  border-radius: 12px;
  padding: 12px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 10px;
}

.item p {
  margin: 6px 0 0;
  color: #374151;
}

.right {
  display: flex;
  align-items: center;
  gap: 10px;
}

.votes {
  color: #111827;
  font-weight: 600;
}

@media (max-width: 640px) {
  .item {
    flex-direction: column;
    align-items: flex-start;
  }

  .right {
    width: 100%;
    justify-content: space-between;
  }
}
</style>