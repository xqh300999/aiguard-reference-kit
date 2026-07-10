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
          <el-dropdown trigger="click" @command="handleAlertCommand">
            <button class="alert-notification-btn" type="button" title="告警通知">
              <Bell :size="18" />
              <span v-if="alertStore.unreadCount > 0" class="alert-badge">{{ alertStore.unreadCount }}</span>
            </button>
            <template #dropdown>
              <el-dropdown-menu>
                <AlertList />
              </el-dropdown-menu>
            </template>
          </el-dropdown>
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

    <AlertNotification />
  </div>
</template>

<script setup lang="ts">
import { LayoutDashboard, LogOut, ShieldCheck, Siren, Settings, Bell } from 'lucide-vue-next'
import { computed, onMounted, onUnmounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'

import { useAuthStore } from '@/stores/auth'
import { useAlertStore } from '@/stores/alert'
import AlertNotification from '@/components/AlertNotification.vue'
import AlertList from '@/components/AlertList.vue'

const auth = useAuthStore()
const alertStore = useAlertStore()
const route = useRoute()
const router = useRouter()

const pageTitle = computed(() => {
  if (route.name === 'WorkerAlerts' || route.name === 'AcceptanceAlerts') return '告警列表'
  if (route.name === 'WorkerAlertDetail' || route.name === 'AcceptanceAlertDetail') return '告警详情'
  return '工作台'
})

const nameInitial = computed(() => (auth.user?.realName || '李').slice(0, 1))

function handleCommand(command: string) {
  if (command === 'logout') {
    alertStore.closeWebSocket()
    auth.logout()
    router.push('/login')
  }
}

function handleAlertCommand(command: string) {
  if (command === 'clear') {
    alertStore.clearAll()
  }
}

onMounted(() => {
  alertStore.initWebSocket()
})

onUnmounted(() => {
  alertStore.closeWebSocket()
})
</script>

<style scoped>
.alert-notification-btn {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 36px;
  height: 36px;
  background: #f3f4f6;
  border: none;
  border-radius: 8px;
  color: #374151;
  cursor: pointer;
  position: relative;
  margin-right: 8px;
  transition: all 0.2s;
}

.alert-notification-btn:hover {
  background: #e5e7eb;
}

.alert-badge {
  position: absolute;
  top: -4px;
  right: -4px;
  min-width: 16px;
  height: 16px;
  background: #ef4444;
  color: white;
  font-size: 10px;
  font-weight: 600;
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 0 4px;
}
</style>
