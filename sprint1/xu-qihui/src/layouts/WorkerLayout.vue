<template>
  <div class="app-shell">
    <aside class="side-nav">
      <RouterLink class="brand" to="/worker">
        <span class="brand-mark">A</span>
        <span>
          <strong>AiGuard</strong>
          <small>社区工作台</small>
        </span>
      </RouterLink>

      <nav class="nav-list">
        <RouterLink class="nav-item" to="/worker/workbench">
          <LayoutDashboard :size="18" />
          <span>工作台</span>
        </RouterLink>
        <RouterLink class="nav-item" to="/worker/alerts">
          <Siren :size="18" />
          <span>告警处理</span>
        </RouterLink>
        <div class="nav-divider"></div>
        <RouterLink class="nav-item" to="/admin/dashboard">
          <Settings :size="18" />
          <span>管理后台</span>
        </RouterLink>
      </nav>
    </aside>

    <section class="main-shell">
      <header class="top-bar">
        <div>
          <p class="top-eyebrow">幸福社区</p>
          <h1>{{ pageTitle }}</h1>
        </div>
        <div class="top-actions">
          <el-tag type="success" effect="light">
            <ShieldCheck :size="14" />
            {{ auth.user?.role || 'WORKER' }}
          </el-tag>
          <el-dropdown trigger="click" @command="handleCommand">
            <button class="user-chip" type="button">
              <span>{{ nameInitial }}</span>
              {{ auth.user?.realName || '李凯辉' }}
            </button>
            <template #dropdown>
              <el-dropdown-menu>
                <el-dropdown-item command="logout">
                  <LogOut :size="16" />
                  退出登录
                </el-dropdown-item>
              </el-dropdown-menu>
            </template>
          </el-dropdown>
        </div>
      </header>

      <main class="content-area">
        <RouterView />
      </main>
    </section>
  </div>
</template>

<script setup lang="ts">
import { LayoutDashboard, LogOut, ShieldCheck, Siren, Settings } from 'lucide-vue-next'
import { computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'

import { useAuthStore } from '@/stores/auth'

const auth = useAuthStore()
const route = useRoute()
const router = useRouter()

const pageTitle = computed(() => {
  if (route.name === 'WorkerAlerts') return '告警列表'
  if (route.name === 'WorkerAlertDetail') return '告警详情'
  return '工作台'
})

const nameInitial = computed(() => (auth.user?.realName || '李').slice(0, 1))

function handleCommand(command: string) {
  if (command === 'logout') {
    auth.logout()
    router.push('/login')
  }
}
</script>