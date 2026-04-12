<script setup>
import { RouterLink, RouterView, useRoute } from 'vue-router'
import { projectEntries } from './projects/registry'

const route = useRoute()
</script>

<template>
  <div class="app-shell">
    <header class="topbar">
      <div class="brand">
        <strong>Web3 Frontend Hub</strong>
        <span>一个仓库管理多个合约前端</span>
      </div>

      <nav class="nav-links">
        <RouterLink to="/" class="nav-link" :class="{ active: route.path === '/' }">首页</RouterLink>
        <RouterLink
          v-for="item in projectEntries"
          :key="item.id"
          :to="item.path"
          class="nav-link"
          :class="{ active: route.path === item.path }"
        >
          {{ item.title }}
        </RouterLink>
      </nav>
    </header>

    <main class="content-wrap">
      <RouterView />
    </main>
  </div>
</template>