# WebSocket

WebSocket 是 HTML5 规范定义的全双工通信协议，提供浏览器与服务器之间的持久化连接，适合实时数据推送。

## 快速参考

### WebSocket 协议基础

| 特性 | 说明 |
|------|------|
| 协议 | ws://（明文）/ wss://（TLS加密） |
| 默认端口 | 80 / 443（与 HTTP 兼容，可共享端口） |
| 连接建立 | HTTP Upgrade 握手升级 |
| 通信模式 | 全双工，客户端/服务器均可主动发消息 |
| 消息类型 | 文本帧、二进制帧、Ping/Pong、Close |
| 协议标准 | RFC 6455 |

### 与 HTTP 对比

| 对比项 | HTTP | WebSocket |
|--------|------|-----------|
| 连接方式 | 短连接/长连接（Keep-Alive） | 持久化双向连接 |
| 通信方向 | 请求-响应，客户端主动 | 双向，服务器可主动推送 |
| 开销 | 每次请求带完整 HTTP 头 | 建立连接后帧头很小（2-10字节） |
| 适用场景 | REST API、页面加载 | 实时通知、聊天、数据大屏、设备状态 |

### Spring Boot 集成 WebSocket

**Maven 依赖：**
```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-websocket</artifactId>
</dependency>
```

**方式一：使用 `@ServerEndpoint`（标准 JSR 356）**

```java
@Component
@ServerEndpoint("/ws/device/{deviceId}")
@Slf4j
public class DeviceWebSocketEndpoint {

    private static final ConcurrentHashMap<String, Session> sessions = new ConcurrentHashMap<>();

    @OnOpen
    public void onOpen(Session session, @PathParam("deviceId") String deviceId) {
        sessions.put(deviceId, session);
        log.info("WebSocket 连接建立: deviceId={}", deviceId);
    }

    @OnMessage
    public void onMessage(String message, @PathParam("deviceId") String deviceId) {
        log.info("收到消息: deviceId={}, message={}", deviceId, message);
    }

    @OnClose
    public void onClose(Session session, @PathParam("deviceId") String deviceId) {
        sessions.remove(deviceId);
        log.info("WebSocket 连接关闭: deviceId={}", deviceId);
    }

    @OnError
    public void onError(Session session, Throwable error, @PathParam("deviceId") String deviceId) {
        log.error("WebSocket 错误: deviceId={}, error={}", deviceId, error.getMessage());
    }

    public void sendMessage(String deviceId, String message) {
        Session session = sessions.get(deviceId);
        if (session != null && session.isOpen()) {
            try {
                session.getBasicRemote().sendText(message);
            } catch (IOException e) {
                log.error("发送消息失败", e);
            }
        }
    }
}
```

**方式二：使用 Spring WebSocketHandler（推荐）**

```java
@Component
public class DeviceStatusWebSocketHandler extends TextWebSocketHandler {

    private final Map<String, WebSocketSession> sessions = new ConcurrentHashMap<>();
    private final ObjectMapper objectMapper = new ObjectMapper();

    @Override
    public void afterConnectionEstablished(WebSocketSession session) throws Exception {
        String deviceId = extractDeviceId(session);
        sessions.put(deviceId, session);
        log.info("设备连接: {}", deviceId);
    }

    @Override
    protected void handleTextMessage(WebSocketSession session, TextMessage message) throws Exception {
        // 处理客户端消息
        String payload = message.getPayload();
        log.debug("收到消息: {}", payload);
    }

    @Override
    public void afterConnectionClosed(WebSocketSession session, CloseStatus status) throws Exception {
        String deviceId = extractDeviceId(session);
        sessions.remove(deviceId);
        log.info("设备断开: {}, status={}", deviceId, status);
    }

    public void broadcast(Object message) {
        String json = objectMapper.writeValueAsString(message);
        TextMessage textMessage = new TextMessage(json);
        sessions.values().forEach(session -> {
            try {
                if (session.isOpen()) {
                    session.sendMessage(textMessage);
                }
            } catch (IOException e) {
                log.error("广播消息失败", e);
            }
        });
    }

    public void sendToDevice(String deviceId, Object message) throws IOException {
        WebSocketSession session = sessions.get(deviceId);
        if (session != null && session.isOpen()) {
            session.sendMessage(new TextMessage(objectMapper.writeValueAsString(message)));
        }
    }

    private String extractDeviceId(WebSocketSession session) {
        String path = session.getUri().getPath();
        return path.substring(path.lastIndexOf('/') + 1);
    }
}
```

**配置类注册 Handler：**
```java
@Configuration
@EnableWebSocket
@RequiredArgsConstructor
public class WebSocketConfig implements WebSocketConfigurer {

    private final DeviceStatusWebSocketHandler deviceStatusHandler;

    @Override
    public void registerWebSocketHandlers(WebSocketHandlerRegistry registry) {
        registry.addHandler(deviceStatusHandler, "/ws/device-status")
                .setAllowedOrigins("http://localhost:5173", "http://localhost:8081");
    }
}
```

**配合 STOMP 子协议（适合复杂场景）：**
```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-websocket</artifactId>
</dependency>
<dependency>
    <groupId>org.springframework</groupId>
    <artifactId>spring-messaging</artifactId>
</dependency>
```

### 前端 JavaScript 连接示例

```javascript
// 原生 WebSocket API
const ws = new WebSocket('ws://localhost:8080/ws/device-status');

ws.onopen = () => {
    console.log('WebSocket 连接已建立');
    ws.send(JSON.stringify({ type: 'subscribe', topics: ['sensors', 'alerts'] }));
};

ws.onmessage = (event) => {
    const data = JSON.parse(event.data);
    console.log('收到消息:', data);
};

ws.onclose = (event) => {
    console.log('连接关闭:', event.code, event.reason);
    // 自动重连
    setTimeout(() => reconnect(), 3000);
};

ws.onerror = (error) => {
    console.error('WebSocket 错误:', error);
};

// 发送消息
function sendMessage(data) {
    if (ws.readyState === WebSocket.OPEN) {
        ws.send(JSON.stringify(data));
    }
}
```

### Vue 3 + WebSocket 组合式函数

```typescript
// composables/useWebSocket.ts
import { ref, onUnmounted } from 'vue'

export function useWebSocket(url: string) {
  const ws = ref<WebSocket | null>(null)
  const lastMessage = ref<any>(null)
  const isConnected = ref(false)
  let reconnectTimer: number | null = null

  function connect() {
    ws.value = new WebSocket(url)

    ws.value.onopen = () => {
      isConnected.value = true
      console.log('WebSocket 已连接')
    }

    ws.value.onmessage = (event) => {
      try {
        lastMessage.value = JSON.parse(event.data)
      } catch {
        lastMessage.value = event.data
      }
    }

    ws.value.onclose = () => {
      isConnected.value = false
      reconnectTimer = window.setTimeout(connect, 3000)
    }
  }

  function send(data: any) {
    if (ws.value?.readyState === WebSocket.OPEN) {
      ws.value.send(JSON.stringify(data))
    }
  }

  function disconnect() {
    if (reconnectTimer) clearTimeout(reconnectTimer)
    ws.value?.close()
  }

  connect()
  onUnmounted(disconnect)

  return { lastMessage, isConnected, send, disconnect }
}
```

## 常见坑点

1. **跨域（CORS）问题**
   - WebSocket 握手使用 HTTP，同样受同源策略限制
   - `setAllowedOrigins("*")` 允许所有来源（开发环境可用，生产环境应指定具体域名）
   - Nginx 反向代理时需要配置 `proxy_set_header Upgrade $http_upgrade;` 和 `proxy_set_header Connection "upgrade";`

2. **连接断开检测与重连**
   - 网络切换、息屏、服务器重启都会导致连接断开
   - 前端必须实现心跳（Ping/Pong）和自动重连机制
   - 服务端可配置心跳超时关闭僵死连接

3. **消息序列化**
   - WebSocket 没有规定消息格式，建议统一使用 JSON
   - 消息体建议包含 `type` 字段区分消息类型：
     ```json
     {"type": "device_status", "data": {...}}
     {"type": "alert", "data": {...}}
     {"type": "ping", "timestamp": 1719000000}
     ```

4. **会话存储内存泄漏**
   - 连接断开时必须从 sessions Map 中移除
   - 建议使用 `ConcurrentHashMap` 保证线程安全
   - 定期清理失效连接（建议实现心跳机制）

5. **消息大小限制**
   - Spring WebSocket 默认文本消息大小限制 64KB
   - 大消息需配置：
     ```java
     @Override
     public void configureWebSocketTransport(WebSocketTransportRegistration registration) {
         registration.setMessageSizeLimit(1024 * 1024); // 1MB
         registration.setSendBufferSizeLimit(1024 * 1024);
     }
     ```

6. **Nginx 反向代理配置**
   ```nginx
   location /ws/ {
       proxy_pass http://backend;
       proxy_http_version 1.1;
       proxy_set_header Upgrade $http_upgrade;
       proxy_set_header Connection "upgrade";
       proxy_set_header Host $host;
       proxy_read_timeout 3600s;  # 长连接超时，默认60s会断开
       proxy_send_timeout 3600s;
   }
   ```

7. **STOMP 与原生 WebSocket 选择**
   - 简单场景（设备状态推送、通知）用原生 WebSocket 足够
   - 需要消息路由、用户目的地、订阅模型时用 STOMP
   - 注意：前端需要 stomp.js 库

## 官方链接

详见 [official-links.md](official-links.md)。

- WebSocket 规范 RFC 6455：https://datatracker.ietf.org/doc/html/rfc6455
- Spring WebSocket 文档：https://docs.spring.io/spring-framework/reference/web/websocket.html
- Spring STOMP 文档：https://docs.spring.io/spring-framework/reference/web/websocket/stomp.html
- MDN WebSocket API：https://developer.mozilla.org/zh-CN/docs/Web/API/WebSocket
