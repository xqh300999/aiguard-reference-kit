<template>
  <div class="alert-list">
    <div v-if="alertStore.notifications.length === 0" class="alert-list-empty">
      <Bell :size="48" style="color: #d1d5db" />
      <p>暂无告警通知</p>
    </div>
    <div v-else class="alert-list-items">
      <div
        v-for="item in alertStore.notifications"
        :key="item.id"
        class="alert-list-item"
        :class="{ 'alert-list-item-unread': item.id <= lastReadId }"
        @click="handleClick(item)"
      >
        <div class="alert-list-item-icon" :class="getTypeClass(item.type)">
          <Siren :size="18" />
        </div>
        <div class="alert-list-item-content">
          <div class="alert-list-item-header">
            <span class="alert-list-item-type">{{ getTypeName(item.type) }}</span>
            <span class="alert-list-item-time">{{ formatTime(item.timestamp) }}</span>
          </div>
          <p class="alert-list-item-text">{{ item.elderlyName }} 触发告警</p>
        </div>
        <div class="alert-list-item-arrow">
          <ArrowRight :size="16" />
        </div>
      </div>
    </div>
    <div v-if="alertStore.notifications.length > 0" class="alert-list-footer">
      <button class="alert-list-clear" @click="alertStore.clearAll">清空全部</button>
    </div>
  </div>
</template>

<script setup lang="ts">
import { Bell, Siren, ArrowRight } from 'lucide-vue-next'
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { useAlertStore, type AlertNotification } from '@/stores/alert'

const router = useRouter()
const alertStore = useAlertStore()

const lastReadId = ref(0)

const getTypeClass = (type: string): string => {
  return `alert-type-${type.toLowerCase()}`
}

const getTypeName = (type: string): string => {
  const typeMap: Record<string, string> = {
    SOS: '紧急求助',
    FALL: '跌倒告警',
    INACTIVITY: '长时间未活动',
    LOW_BATTERY: '低电量告警',
    DEVICE_OFFLINE: '设备离线',
    ABNORMAL: '异常告警'
  }
  return typeMap[type] || type
}

const formatTime = (timestamp: number): string => {
  const date = new Date(timestamp)
  const now = new Date()
  const diff = now.getTime() - timestamp

  if (diff < 60000) {
    return '刚刚'
  } else if (diff < 3600000) {
    return `${Math.floor(diff / 60000)}分钟前`
  } else if (diff < 86400000) {
    return `${Math.floor(diff / 3600000)}小时前`
  } else {
    return date.toLocaleDateString('zh-CN')
  }
}

const handleClick = (item: AlertNotification) => {
  alertStore.markAsRead(item.id)
  lastReadId.value = item.id
  router.push(`/worker/alerts/${item.alertId}`)
}
</script>

<style scoped>
.alert-list {
  width: 360px;
  max-height: 500px;
  display: flex;
  flex-direction: column;
}

.alert-list-empty {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 32px;
  color: #9ca3af;
}

.alert-list-empty p {
  margin-top: 12px;
  font-size: 14px;
}

.alert-list-items {
  overflow-y: auto;
  flex: 1;
}

.alert-list-item {
  display: flex;
  align-items: center;
  padding: 16px;
  cursor: pointer;
  transition: background-color 0.2s;
  border-bottom: 1px solid #f3f4f6;
}

.alert-list-item:hover {
  background-color: #f9fafb;
}

.alert-list-item:last-child {
  border-bottom: none;
}

.alert-list-item-unread {
  background-color: #fef2f2;
}

.alert-list-item-icon {
  width: 40px;
  height: 40px;
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-right: 12px;
  flex-shrink: 0;
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

.alert-list-item-content {
  flex: 1;
  min-width: 0;
}

.alert-list-item-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 4px;
}

.alert-list-item-type {
  font-size: 12px;
  font-weight: 500;
  color: #6b7280;
}

.alert-list-item-time {
  font-size: 12px;
  color: #9ca3af;
}

.alert-list-item-text {
  font-size: 14px;
  color: #1f2937;
  margin: 0;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.alert-list-item-arrow {
  color: #d1d5db;
  margin-left: 8px;
}

.alert-list-footer {
  padding: 12px 16px;
  border-top: 1px solid #f3f4f6;
}

.alert-list-clear {
  width: 100%;
  padding: 8px;
  background: none;
  border: 1px solid #e5e7eb;
  border-radius: 8px;
  font-size: 14px;
  color: #6b7280;
  cursor: pointer;
  transition: all 0.2s;
}

.alert-list-clear:hover {
  background: #f3f4f6;
  color: #374151;
}
</style>