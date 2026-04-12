<script setup>
import { RouterLink } from 'vue-router'
import { projectEntries } from '../projects/registry'
</script>

<template>
  <section class="home">
    <div class="intro-card">
      <h1>项目首页</h1>
      <p>你可以把每个合约前端做成独立页面，然后在注册表里统一管理入口。</p>
      <p class="tip">新增项目只需两步：创建页面文件 + 在 <code>src/projects/registry.js</code> 注册。</p>
    </div>

    <div class="project-grid">
      <article v-for="item in projectEntries" :key="item.id" class="project-card">
        <h2>{{ item.title }}</h2>
        <p>{{ item.description }}</p>
        <RouterLink class="open-link" :to="item.path">打开项目</RouterLink>
      </article>
    </div>
  </section>
</template>

<style scoped>
.home {
  display: grid;
  gap: 16px;
}

.intro-card,
.project-card {
  background: #fff;
  border: 1px solid #e5e7eb;
  border-radius: 14px;
  padding: 18px;
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.05);
}

h1 {
  margin: 0 0 8px;
  font-size: 26px;
}

h2 {
  margin: 0 0 8px;
  font-size: 18px;
}

p {
  margin: 0;
  color: #475569;
}

.tip {
  margin-top: 8px;
}

.project-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 12px;
}

.open-link {
  margin-top: 12px;
  display: inline-block;
  text-decoration: none;
  background: #111827;
  color: #fff;
  padding: 8px 12px;
  border-radius: 10px;
  font-weight: 600;
}
</style>