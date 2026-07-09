<template>
  <main class="not-found">
    <section>
      <h1>404</h1>
      <p>页面不存在或没有访问权限</p>
      <el-button type="primary" @click="goHome">返回首页</el-button>
    </section>
  </main>
</template>

<script setup lang="ts">
import { useRouter } from 'vue-router'

import { useAuthStore } from '@/stores/auth'

const router = useRouter()
const authStore = useAuthStore()

function goHome() {
  if (!authStore.token) {
    router.push('/login')
    return
  }
  router.push(authStore.user?.role === 'ADMIN' ? '/admin/dashboard' : '/worker/workbench')
}
</script>
