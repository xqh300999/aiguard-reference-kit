<template>
  <main class="not-found">
    <section>
      <h1>404</h1>
      <p>页面不存在</p>
      <el-button type="primary" @click="router.push('/worker')">返回工作台</el-button>
    </section>
  </main>
</template>

<script setup lang="ts">
import { useRouter } from 'vue-router'

const router = useRouter()
</script>
