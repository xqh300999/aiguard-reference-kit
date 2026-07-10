import { useAuthStore } from '@/stores/auth'

export type WebSocketMessageType = 'NEW_ALERT' | 'ALERT_UPDATE' | 'DEVICE_STATUS'

export interface WebSocketAlertData {
  alertId: number
  type: string
  elderlyName: string
  communityId: number
  happenedAt: string
}

export interface WebSocketMessage {
  type: WebSocketMessageType
  data: WebSocketAlertData
}

let ws: WebSocket | null = null
let reconnectTimer: ReturnType<typeof setTimeout> | null = null
const messageHandlers: ((msg: WebSocketMessage) => void)[] = []

function getWebSocketUrl(token: string): string {
  const explicitTarget = import.meta.env.VITE_WS_TARGET || ''
  if (explicitTarget) {
    const protocol = explicitTarget.startsWith('https') ? 'wss' : 'ws'
    const host = explicitTarget.replace(/^https?:\/\//, '')
    return `${protocol}://${host}/ws/alerts?token=${encodeURIComponent(token)}`
  }

  const protocol = window.location.protocol === 'https:' ? 'wss' : 'ws'
  return `${protocol}://${window.location.host}/ws/alerts?token=${encodeURIComponent(token)}`
}

export function connectWebSocket(): void {
  if (ws?.readyState === WebSocket.OPEN) {
    return
  }

  const authStore = useAuthStore()
  if (!authStore.token) {
    return
  }

  const wsUrl = getWebSocketUrl(authStore.token)

  try {
    ws = new WebSocket(wsUrl)

    ws.onopen = () => {
      console.log('[WebSocket] 连接成功')
      if (reconnectTimer) {
        clearTimeout(reconnectTimer)
        reconnectTimer = null
      }
    }

    ws.onmessage = (event) => {
      try {
        const message: WebSocketMessage = JSON.parse(event.data)
        messageHandlers.forEach(handler => handler(message))
      } catch (error) {
        console.error('[WebSocket] 消息解析失败:', error)
      }
    }

    ws.onerror = (error) => {
      console.error('[WebSocket] 连接错误:', error)
    }

    ws.onclose = () => {
      console.log('[WebSocket] 连接关闭')
      scheduleReconnect()
    }
  } catch (error) {
    console.error('[WebSocket] 连接创建失败:', error)
    scheduleReconnect()
  }
}

function scheduleReconnect(): void {
  if (reconnectTimer) {
    clearTimeout(reconnectTimer)
  }
  reconnectTimer = setTimeout(() => {
    const authStore = useAuthStore()
    if (authStore.token) {
      connectWebSocket()
    }
  }, 5000)
}

export function disconnectWebSocket(): void {
  if (reconnectTimer) {
    clearTimeout(reconnectTimer)
    reconnectTimer = null
  }
  if (ws) {
    ws.close()
    ws = null
  }
}

export function addMessageHandler(handler: (msg: WebSocketMessage) => void): void {
  if (!messageHandlers.includes(handler)) {
    messageHandlers.push(handler)
  }
}

export function removeMessageHandler(handler: (msg: WebSocketMessage) => void): void {
  const index = messageHandlers.indexOf(handler)
  if (index > -1) {
    messageHandlers.splice(index, 1)
  }
}
