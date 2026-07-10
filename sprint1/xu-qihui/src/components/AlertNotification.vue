<template>
  <Teleport to="body">
    <Transition name="alert-notification">
      <div v-if="alertStore.showNotification && alertStore.currentAlert" class="alert-notification-overlay" @click.self="handleClose">
        <div class="alert-notification-card">
          <div class="alert-notification-icon">
            <Bell :size="32" />
          </div>
          <div class="alert-notification-content">
            <div class="alert-notification-header">
              <span class="alert-type" :class="alertTypeClass">{{ alertTypeName }}</span>
              <button class="alert-notification-close" @click="handleClose">
                <X :size="20" />
              </button>
            </div>
            <h3 class="alert-notification-title">{{ alertStore.currentAlert.elderlyName }} 触发告警</h3>
            <p class="alert-notification-desc">社区ID: {{ alertStore.currentAlert.communityId }}</p>
            <p class="alert-notification-time">{{ formatTime(alertStore.currentAlert.happenedAt) }}</p>
            <div class="alert-notification-actions">
              <el-button type="primary" @click="handleViewDetail">
                <Eye :size="16" />
                查看详情
              </el-button>
              <el-button @click="handleClose">忽略</el-button>
            </div>
          </div>
        </div>
      </div>
    </Transition>
  </Teleport>
</template>

<script setup lang="ts">
import { Bell, X, Eye } from 'lucide-vue-next'
import { computed } from 'vue'
import { useRouter } from 'vue-router'
import { useAlertStore } from '@/stores/alert'

const router = useRouter()
const alertStore = useAlertStore()

const alertTypeClass = computed(() => {
  const type = alertStore.currentAlert?.type
  if (!type) return ''
  return `alert-type-${type.toLowerCase()}`
})

const alertTypeName = computed(() => {
  const type = alertStore.currentAlert?.type
  const typeMap: Record<string, string> = {
    SOS: '紧急求助',
    FALL: '跌倒告警',
    INACTIVITY: '长时间未活动',
    LOW_BATTERY: '低电量告警',
    DEVICE_OFFLINE: '设备离线',
    ABNORMAL: '异常告警'
  }
  return typeMap[type || ''] || type || '未知告警'
})

const formatTime = (dateStr: string): string => {
  try {
    const date = new Date(dateStr)
    return date.toLocaleString('zh-CN', {
      year: 'numeric',
      month: '2-digit',
      day: '2-digit',
      hour: '2-digit',
      minute: '2-digit',
      second: '2-digit'
    })
  } catch {
    return dateStr
  }
}

const handleClose = () => {
  alertStore.dismissNotification()
}

const handleViewDetail = () => {
  const alertId = alertStore.currentAlert?.alertId
  if (alertId) {
    alertStore.dismissNotification()
    router.push(`/worker/alerts/${alertId}`)
  }
}
</script>

<style scoped>
.alert-notification-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 9999;
  backdrop-filter: blur(4px);
}

.alert-notification-card {
  background: white;
  border-radius: 16px;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
  display: flex;
  max-width: 480px;
  width: 90%;
  overflow: hidden;
  animation: slideIn 0.3s ease-out;
}

@keyframes slideIn {
  from {
    opacity: 0;
    transform: translateY(-20px) scale(0.95);
  }
  to {
    opacity: 1;
    transform: translateY(0) scale(1);
  }
}

.alert-notification-icon {
  background: linear-gradient(135deg, #ef4444 0%, #dc2626 100%);
  color: white;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 32px;
  flex-shrink: 0;
}

.alert-notification-content {
  padding: 24px;
  flex: 1;
}

.alert-notification-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 12px;
}

.alert-type {
  padding: 4px 12px;
  border-radius: 20px;
  font-size: 12px;
  font-weight: 500;
}

.alert-type-sos {
  background: #fee2e2;
  color: #dc2626;
}

.alert-type-fall {
  background: #fef3c7;
  color: #d97706;
}

.alert-type-inactivity {
  background: #dbeafe;
  color: #2563eb;
}

.alert-type-low_battery {
  background: #fef9c3;
  color: #ca8a04;
}

.alert-type-device_offline {
  background: #e5e7eb;
  color: #4b5563;
}

.alert-type-abnormal {
  background: #fce7f3;
  color: #db2777;
}

.alert-notification-close {
  background: none;
  border: none;
  color: #9ca3af;
  cursor: pointer;
  padding: 4px;
  border-radius: 6px;
  transition: all 0.2s;
}

.alert-notification-close:hover {
  background: #f3f4f6;
  color: #374151;
}

.alert-notification-title {
  font-size: 18px;
  font-weight: 600;
  margin: 0 0 8px;
  color: #1f2937;
}

.alert-notification-desc {
  font-size: 14px;
  color: #6b7280;
  margin: 0 0 4px;
}

.alert-notification-time {
  font-size: 12px;
  color: #9ca3af;
  margin: 0 0 16px;
}

.alert-notification-actions {
  display: flex;
  gap: 12px;
}

.alert-notification-actions button {
  flex: 1;
}

.alert-notification-enter-active,
.alert-notification-leave-active {
  transition: opacity 0.3s ease;
}

.alert-notification-enter-from,
.alert-notification-leave-to {
  opacity: 0;
}
</style>