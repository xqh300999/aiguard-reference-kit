<template>
  <div :class="['app-shell', { 'nav-collapsed': collapsed }]">
    <aside class="side-nav">
      <div class="brand-row">
        <RouterLink class="brand" to="/admin/dashboard">
          <span class="brand-mark">A</span>
          <span>
            <strong>AiGuard</strong>
            <small>管理后台</small>
          </span>
        </RouterLink>
        <button class="collapse-button" type="button" title="折叠菜单" @click="collapsed = !collapsed">
          <Menu :size="18" />
        </button>
      </div>

      <nav class="nav-list">
        <RouterLink class="nav-item" to="/worker/workbench">
          <Home :size="18" />
          <span>社区工作台</span>
        </RouterLink>
        <div class="nav-divider"></div>
        <RouterLink class="nav-item" to="/admin/dashboard">
          <LayoutDashboard :size="18" />
          <span>数据总览</span>
        </RouterLink>
        <RouterLink class="nav-item" to="/admin/communities">
          <Building2 :size="18" />
          <span>社区管理</span>
        </RouterLink>
        <RouterLink class="nav-item" to="/admin/elderly">
          <Users :size="18" />
          <span>老人档案</span>
        </RouterLink>
        <RouterLink class="nav-item" to="/admin/users">
          <UserCircle :size="18" />
          <span>用户管理</span>
        </RouterLink>
        <RouterLink class="nav-item" to="/admin/devices">
          <MonitorSmartphone :size="18" />
          <span>设备管理</span>
        </RouterLink>
        <RouterLink class="nav-item" to="/admin/alerts">
          <AlertTriangle :size="18" />
          <span>告警管理</span>
        </RouterLink>
      </nav>
    </aside>

    <section class="main-shell">
      <header class="top-bar">
        <div>
          <p class="top-eyebrow">{{ '管理后台' }}</p>
          <h1>{{ pageTitle }}</h1>
        </div>
        <div class="top-actions">
          <el-tag type="success" effect="light">
            <ShieldCheck :size="14" />
            {{ authStore.user?.role || 'ADMIN' }}
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
              {{ authStore.user?.realName || '管理员' }}
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
import { LayoutDashboard, Building2, Users, UserCircle, MonitorSmartphone, AlertTriangle, ShieldCheck, LogOut, Home, Menu, Bell } from 'lucide-vue-next'
import { computed, onMounted, onUnmounted, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { useAuthStore } from '@/stores/auth'
import { useAlertStore } from '@/stores/alert'
import AlertNotification from '@/components/AlertNotification.vue'
import AlertList from '@/components/AlertList.vue'

const authStore = useAuthStore()
const alertStore = useAlertStore()
const route = useRoute()
const router = useRouter()
const collapsed = ref(false)

const pageTitle = computed(() => {
  const titles: Record<string, string> = {
    '/admin/dashboard': '数据总览',
    '/admin/communities': '社区管理',
    '/admin/elderly': '老人档案',
    '/admin/users': '用户管理',
    '/admin/devices': '设备管理',
    '/admin/alerts': '告警管理'
  }
  if (route.name === 'AlertDetail') return '告警详情'
  return titles[route.path] || '管理后台'
})

const nameInitial = computed(() => (authStore.user?.realName || '管').slice(0, 1))

const handleCommand = (command: string) => {
  if (command === 'logout') {
    alertStore.closeWebSocket()
    authStore.logout()
    ElMessage.success('退出成功')
    router.push('/login')
  }
}

const handleAlertCommand = (command: string) => {
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
