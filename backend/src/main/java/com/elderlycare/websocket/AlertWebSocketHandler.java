package com.elderlycare.websocket;

import com.elderlycare.util.JwtUtil;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.CloseStatus;
import org.springframework.web.socket.TextMessage;
import org.springframework.web.socket.WebSocketSession;
import org.springframework.web.socket.handler.TextWebSocketHandler;

import java.net.URI;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;

/**
 * 告警 WebSocket 处理器
 * <p>对应 API 文档 §13 WebSocket
 * <p>连接地址：WS /ws/alerts?token=&lt;JWT_TOKEN&gt;
 * <p>推送消息类型：NEW_ALERT / ALERT_UPDATE / DEVICE_STATUS
 */
@Component
@RequiredArgsConstructor
public class AlertWebSocketHandler extends TextWebSocketHandler {

    private static final Logger log = LoggerFactory.getLogger(AlertWebSocketHandler.class);

    private final JwtUtil jwtUtil;
    private final Set<WebSocketSession> sessions = ConcurrentHashMap.newKeySet();

    @Override
    public void afterConnectionEstablished(WebSocketSession session) throws Exception {
        // 从查询参数校验 token
        String token = extractToken(session);
        if (token == null || !jwtUtil.validateToken(token)) {
            log.warn("[WS] 连接鉴权失败，关闭 session：{}", session.getId());
            session.close(CloseStatus.POLICY_VIOLATION);
            return;
        }
        sessions.add(session);
        log.info("[WS] 客户端已连接 | sessionId={} | 当前在线={}", session.getId(), sessions.size());
    }

    @Override
    public void afterConnectionClosed(WebSocketSession session, CloseStatus status) throws Exception {
        sessions.remove(session);
        log.info("[WS] 客户端已断开 | sessionId={} | status={} | 当前在线={}", session.getId(), status, sessions.size());
    }

    /**
     * 向所有已连接客户端广播消息
     */
    public void broadcast(String message) {
        if (sessions.isEmpty()) {
            return;
        }
        TextMessage textMessage = new TextMessage(message);
        for (WebSocketSession session : sessions) {
            if (session.isOpen()) {
                try {
                    session.sendMessage(textMessage);
                } catch (Exception e) {
                    log.warn("[WS] 推送失败 | sessionId={}", session.getId(), e);
                }
            }
        }
    }

    private String extractToken(WebSocketSession session) {
        URI uri = session.getUri();
        if (uri == null || uri.getQuery() == null) {
            return null;
        }
        for (String param : uri.getQuery().split("&")) {
            String[] kv = param.split("=", 2);
            if ("token".equals(kv[0]) && kv.length == 2) {
                return kv[1];
            }
        }
        return null;
    }
}
