<script setup>
import { computed, ref, shallowRef } from 'vue'
import { ethers } from 'ethers'

const storageKey = 'my_token_contract_address'
const contractAddress = ref(localStorage.getItem(storageKey) || '')

const provider = shallowRef(null)
const signer = shallowRef(null)
const contract = shallowRef(null)

const account = ref('')
const owner = ref('')
const tokenName = ref('')
const tokenSymbol = ref('')
const tokenDecimals = ref(18)
const totalSupply = ref('0')
const myBalance = ref('0')
const message = ref('')
const loading = ref(false)

const balanceQueryAddress = ref('')
const balanceQueryResult = ref('')

const transferTo = ref('')
const transferAmount = ref('')

const approveSpender = ref('')
const approveAmount = ref('')

const allowanceOwner = ref('')
const allowanceSpender = ref('')
const allowanceResult = ref('')

const tfFrom = ref('')
const tfTo = ref('')
const tfAmount = ref('')

const mintTo = ref('')
const mintAmount = ref('')

const statsFrom = ref('')
const statsTo = ref('')
const statsCount = ref(0)
const statsTotal = ref('0')

const abi = [
  'function name() view returns (string)',
  'function symbol() view returns (string)',
  'function decimals() view returns (uint8)',
  'function totalSupply() view returns (uint256)',
  'function balanceOf(address account) view returns (uint256)',
  'function transfer(address to, uint256 amount) returns (bool)',
  'function approve(address spender, uint256 amount) returns (bool)',
  'function allowance(address owner, address spender) view returns (uint256)',
  'function transferFrom(address from, address to, uint256 amount) returns (bool)',
  'function owner() view returns (address)',
  'function mint(address to, uint256 amount)',
  'event Transfer(address indexed from, address indexed to, uint256 value)',
]

const canInteract = computed(() => !!contract.value && !!account.value)
const isOwner = computed(
  () => !!owner.value && !!account.value && owner.value.toLowerCase() === account.value.toLowerCase(),
)

function shortAddress(addr) {
  if (!addr) return ''
  return `${addr.slice(0, 6)}...${addr.slice(-4)}`
}

function saveContractAddress() {
  localStorage.setItem(storageKey, contractAddress.value.trim())
}

function formatToken(raw) {
  return ethers.formatUnits(raw, tokenDecimals.value)
}

function parseToken(human) {
  return ethers.parseUnits(human, tokenDecimals.value)
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

async function initContract() {
  if (!signer.value || !contractAddress.value.trim()) return

  try {
    saveContractAddress()
    contract.value = new ethers.Contract(contractAddress.value.trim(), abi, signer.value)
    await refreshOverview()
    message.value = '合约连接成功。'
  } catch (err) {
    contract.value = null
    message.value = `合约初始化失败：${err?.shortMessage || err?.message || '地址或网络不正确'}`
  }
}

async function refreshOverview() {
  if (!contract.value || !account.value) return

  loading.value = true
  try {
    const [name, symbol, decimals, supply, balance, contractOwner] = await Promise.all([
      contract.value.name(),
      contract.value.symbol(),
      contract.value.decimals(),
      contract.value.totalSupply(),
      contract.value.balanceOf(account.value),
      contract.value.owner(),
    ])

    tokenName.value = name
    tokenSymbol.value = symbol
    tokenDecimals.value = Number(decimals)
    totalSupply.value = formatToken(supply)
    myBalance.value = formatToken(balance)
    owner.value = contractOwner
  } catch (err) {
    message.value = `读取代币信息失败：${err?.shortMessage || err?.message || '未知错误'}`
  } finally {
    loading.value = false
  }
}

async function queryBalance() {
  if (!contract.value || !balanceQueryAddress.value.trim()) return

  try {
    const raw = await contract.value.balanceOf(balanceQueryAddress.value.trim())
    balanceQueryResult.value = formatToken(raw)
  } catch (err) {
    message.value = `查询余额失败：${err?.shortMessage || err?.message || '未知错误'}`
  }
}

async function doTransfer() {
  if (!contract.value || !transferTo.value.trim() || !transferAmount.value.trim()) return

  try {
    loading.value = true
    const tx = await contract.value.transfer(transferTo.value.trim(), parseToken(transferAmount.value.trim()))
    await tx.wait()
    message.value = `转账成功，交易哈希：${tx.hash}`
    await refreshOverview()
  } catch (err) {
    message.value = `转账失败：${err?.shortMessage || err?.message || '未知错误'}`
  } finally {
    loading.value = false
  }
}

async function doApprove() {
  if (!contract.value || !approveSpender.value.trim() || !approveAmount.value.trim()) return

  try {
    loading.value = true
    const tx = await contract.value.approve(
      approveSpender.value.trim(),
      parseToken(approveAmount.value.trim()),
    )
    await tx.wait()
    message.value = `授权成功，交易哈希：${tx.hash}`
  } catch (err) {
    message.value = `授权失败：${err?.shortMessage || err?.message || '未知错误'}`
  } finally {
    loading.value = false
  }
}

async function queryAllowance() {
  if (!contract.value || !allowanceOwner.value.trim() || !allowanceSpender.value.trim()) return

  try {
    const raw = await contract.value.allowance(
      allowanceOwner.value.trim(),
      allowanceSpender.value.trim(),
    )
    allowanceResult.value = formatToken(raw)
    message.value = `allowance 查询完成：${allowanceResult.value} ${tokenSymbol.value || ''}`.trim()
  } catch (err) {
    message.value = `查询授权额度失败：${err?.shortMessage || err?.message || '未知错误'}`
  }
}

async function doTransferFrom() {
  if (!contract.value || !tfFrom.value.trim() || !tfTo.value.trim() || !tfAmount.value.trim()) return

  try {
    loading.value = true
    const tx = await contract.value.transferFrom(
      tfFrom.value.trim(),
      tfTo.value.trim(),
      parseToken(tfAmount.value.trim()),
    )
    await tx.wait()
    message.value = `授权转账成功，交易哈希：${tx.hash}`
    await refreshOverview()
  } catch (err) {
    message.value = `授权转账失败：${err?.shortMessage || err?.message || '未知错误'}`
  } finally {
    loading.value = false
  }
}

async function doMint() {
  if (!contract.value || !isOwner.value || !mintTo.value.trim() || !mintAmount.value.trim()) return

  try {
    loading.value = true
    const tx = await contract.value.mint(mintTo.value.trim(), parseToken(mintAmount.value.trim()))
    await tx.wait()
    message.value = `增发成功，交易哈希：${tx.hash}`
    await refreshOverview()
  } catch (err) {
    message.value = `增发失败：${err?.shortMessage || err?.message || '未知错误'}`
  } finally {
    loading.value = false
  }
}

async function queryTransferStats() {
  if (!contract.value || !statsFrom.value.trim() || !statsTo.value.trim()) return

  try {
    loading.value = true
    const from = statsFrom.value.trim()
    const to = statsTo.value.trim()

    const filter = contract.value.filters.Transfer(from, to)
    const logs = await contract.value.queryFilter(filter, 0, 'latest')

    let total = 0n
    for (const log of logs) {
      total += log.args.value
    }

    statsCount.value = logs.length
    statsTotal.value = formatToken(total)
    message.value = `统计完成：${shortAddress(from)} → ${shortAddress(to)} 共 ${statsCount.value} 笔，累计 ${statsTotal.value} ${tokenSymbol.value || ''}`.trim()
  } catch (err) {
    message.value = `统计失败：${err?.shortMessage || err?.message || '请确认节点支持日志查询'}`
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <div class="page">
    <div class="card">
      <h1>MyToken (ERC20)</h1>
      <p class="hint">先连接钱包，再输入 MyToken 合约地址。</p>

      <div class="row">
        <button class="btn" @click="connectWallet" :disabled="loading">
          {{ account ? '重新连接钱包' : '连接钱包' }}
        </button>
        <span v-if="account" class="tag">{{ shortAddress(account) }}</span>
      </div>

      <div class="row">
        <input v-model="contractAddress" class="input" placeholder="输入 MyToken 合约地址（0x...）" />
        <button class="btn ghost" @click="initContract" :disabled="loading || !account">连接合约</button>
      </div>

      <div class="row" v-if="canInteract">
        <button class="btn ghost" @click="refreshOverview" :disabled="loading">刷新数据</button>
      </div>

      <p v-if="owner" class="hint">合约 owner：{{ shortAddress(owner) }}</p>
      <p class="msg">{{ message }}</p>
    </div>

    <div class="card" v-if="canInteract">
      <div class="section-title">代币概览</div>
      <div class="grid-two">
        <p><strong>名称：</strong>{{ tokenName || '-' }}</p>
        <p><strong>符号：</strong>{{ tokenSymbol || '-' }}</p>
        <p><strong>总供应量：</strong>{{ totalSupply }}</p>
        <p><strong>我的余额：</strong>{{ myBalance }}</p>
      </div>
    </div>

    <div class="card" v-if="canInteract">
      <div class="section-title">A → B 累计转账统计</div>
      <p class="hint">基于链上 Transfer 事件统计（包含 transfer 和 transferFrom）。</p>
      <div class="row">
        <input v-model="statsFrom" class="input" placeholder="from 地址（A）" />
        <input v-model="statsTo" class="input" placeholder="to 地址（B）" />
        <button class="btn" @click="queryTransferStats" :disabled="loading">开始统计</button>
      </div>
      <div class="grid-two">
        <p><strong>转账次数：</strong>{{ statsCount }}</p>
        <p><strong>累计金额：</strong>{{ statsTotal }} {{ tokenSymbol }}</p>
      </div>
    </div>

    <div class="card" v-if="canInteract && isOwner">
      <div class="section-title">管理员增发 mint</div>
      <div class="row">
        <input v-model="mintTo" class="input" placeholder="接收地址（0x...）" />
        <input v-model="mintAmount" class="input" placeholder="增发数量（人类可读）" />
        <button class="btn" @click="doMint" :disabled="loading">执行 mint</button>
      </div>
    </div>

    <div class="card" v-if="canInteract">
      <div class="section-title">查询余额</div>
      <div class="row">
        <input v-model="balanceQueryAddress" class="input" placeholder="地址（0x...）" />
        <button class="btn" @click="queryBalance" :disabled="loading">查询</button>
      </div>
      <p class="msg" v-if="balanceQueryResult !== ''">余额：{{ balanceQueryResult }} {{ tokenSymbol }}</p>
    </div>

    <div class="card" v-if="canInteract">
      <div class="section-title">转账 transfer</div>
      <div class="row">
        <input v-model="transferTo" class="input" placeholder="接收地址（0x...）" />
        <input v-model="transferAmount" class="input" placeholder="数量（人类可读，如 12.5）" />
        <button class="btn" @click="doTransfer" :disabled="loading">转账</button>
      </div>
    </div>

    <div class="card" v-if="canInteract">
      <div class="section-title">授权 approve</div>
      <div class="row">
        <input v-model="approveSpender" class="input" placeholder="被授权地址（spender）" />
        <input v-model="approveAmount" class="input" placeholder="授权数量" />
        <button class="btn" @click="doApprove" :disabled="loading">授权</button>
      </div>
    </div>

    <div class="card" v-if="canInteract">
      <div class="section-title">查询 allowance</div>
      <div class="row">
        <input v-model="allowanceOwner" class="input" placeholder="owner 地址" />
        <input v-model="allowanceSpender" class="input" placeholder="spender 地址" />
        <button class="btn" @click="queryAllowance" :disabled="loading">查询</button>
      </div>
      <p class="msg" v-if="allowanceResult !== ''">allowance：{{ allowanceResult }} {{ tokenSymbol }}</p>
    </div>

    <div class="card" v-if="canInteract">
      <div class="section-title">授权转账 transferFrom</div>
      <div class="row">
        <input v-model="tfFrom" class="input" placeholder="from 地址（被扣款方）" />
        <input v-model="tfTo" class="input" placeholder="to 地址（收款方）" />
        <input v-model="tfAmount" class="input" placeholder="数量" />
        <button class="btn" @click="doTransferFrom" :disabled="loading">执行 transferFrom</button>
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

.grid-two {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
  gap: 8px;
}

.input {
  flex: 1;
  min-width: 220px;
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

.btn.ghost {
  background: #111827;
}

.btn:disabled {
  opacity: 0.55;
  cursor: not-allowed;
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
</style>