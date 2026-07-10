import { defineStore } from 'pinia'
import { ref } from 'vue'
import type { WebSocketMessage } from '@/utils/websocket'
import { connectWebSocket, disconnectWebSocket, addMessageHandler, removeMessageHandler } from '@/utils/websocket'

export interface AlertNotification {
  id: number
  alertId: number
  type: string
  elderlyName: string
  communityId: number
  happenedAt: string
  timestamp: number
}

export const useAlertStore = defineStore('alert', () => {
  const notifications = ref<AlertNotification[]>([])
  const unreadCount = ref(0)
  const currentAlert = ref<AlertNotification | null>(null)
  const showNotification = ref(false)

  const handleMessage = (msg: WebSocketMessage) => {
    if (msg.type === 'NEW_ALERT') {
      const newAlert: AlertNotification = {
        id: Date.now(),
        alertId: msg.data.alertId,
        type: msg.data.type,
        elderlyName: msg.data.elderlyName,
        communityId: msg.data.communityId,
        happenedAt: msg.data.happenedAt,
        timestamp: Date.now()
      }

      notifications.value.unshift(newAlert)
      unreadCount.value++

      if (notifications.value.length > 100) {
        notifications.value = notifications.value.slice(0, 100)
      }

      currentAlert.value = newAlert
      showNotification.value = true
    } else if (msg.type === 'ALERT_UPDATE') {
      const index = notifications.value.findIndex(n => n.alertId === msg.data.alertId)
      if (index !== -1) {
        notifications.value[index].happenedAt = msg.data.happenedAt
      }
    }
  }

  const initWebSocket = () => {
    addMessageHandler(handleMessage)
    connectWebSocket()
  }

  const closeWebSocket = () => {
    removeMessageHandler(handleMessage)
    disconnectWebSocket()
  }

  const dismissNotification = () => {
    showNotification.value = false
    currentAlert.value = null
  }

  const markAsRead = (id: number) => {
    const notification = notifications.value.find(n => n.id === id)
    if (notification) {
      unreadCount.value = Math.max(0, unreadCount.value - 1)
    }
  }

  const clearAll = () => {
    notifications.value = []
    unreadCount.value = 0
  }

  return {
    notifications,
    unreadCount,
    currentAlert,
    showNotification,
    initWebSocket,
    closeWebSocket,
    dismissNotification,
    markAsRead,
    clearAll
  }
})