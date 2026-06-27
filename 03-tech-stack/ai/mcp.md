# MCP (Model Context Protocol)

MCP（Model Context Protocol，模型上下文协议）是由 Anthropic 提出的开放协议，用于标准化大语言模型与外部工具、数据源之间的交互。

## 快速参考

### MCP 概述

| 特性 | 说明 |
|------|------|
| 发起方 | Anthropic（Claude 开发公司）|
| 定位 | AI 模型与工具/数据源之间的通用连接标准 |
| 类似概念 | USB-C 之于设备，MCP 之于 AI 应用 |
| 通信方式 | JSON-RPC 2.0 over stdio / SSE / Streamable HTTP |
| 核心能力 | Tools（工具调用）、Resources（资源访问）、Prompts（提示模板）|
| 官方仓库 | https://github.com/modelcontextprotocol |

**MCP 解决的问题：**
- 之前每个 AI 应用都要单独对接各种工具/数据源，MCP 提供统一标准
- 工具开发者只需要实现一次 MCP Server，所有支持 MCP 的 AI 应用都能使用
- 支持本地工具（文件系统、数据库）和远程服务

### MCP 架构

```
┌─────────────────┐        ┌─────────────────┐
│  AI Application │◄──────►│   MCP Client    │
│  (Host)         │        └────────┬────────┘
└─────────────────┘                 │
                                    │ JSON-RPC
                                    ▼
        ┌───────────────────────────────────────────┐
        │              MCP Servers                  │
        │  ┌─────────┐ ┌─────────┐ ┌──────────────┐│
        │  │  HA控制 │ │  天气   │ │  文件系统     ││
        │  │ Server  │ │ Server  │ │ Server       ││
        │  └─────────┘ └─────────┘ └──────────────┘│
        └───────────────────────────────────────────┘
```

- **Host**：AI 应用本身（如 Claude Desktop、AIguard 后端）
- **MCP Client**：Host 内置的协议客户端，负责连接 Server
- **MCP Server**：提供具体工具/资源的服务，可由任意语言实现

### MCP 核心概念

**1. Tools（工具）**
- 模型可调用的函数，执行操作或获取信息
- 例如：控制设备、查询天气、搜索网页、操作数据库
- 模型根据用户意图决定是否调用工具，类似 Function Calling

**2. Resources（资源）**
- 模型可读取的数据，类似文件
- 例如：配置文件、设备状态列表、历史记录
- 通过 URI 访问，如 `file:///path/to/config`、`mcp://ha/devices`

**3. Prompts（提示模板）**
- 预定义的提示模板，帮助用户完成特定任务
- 例如：`总结智能家居今天的异常事件`

### MCP 消息格式

基于 JSON-RPC 2.0：

**初始化请求：**
```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "method": "initialize",
  "params": {
    "protocolVersion": "2024-11-05",
    "capabilities": {},
    "clientInfo": {
      "name": "AIguard",
      "version": "1.0.0"
    }
  }
}
```

**列出工具请求：**
```json
{
  "jsonrpc": "2.0",
  "id": 2,
  "method": "tools/list"
}
```

**列出工具响应：**
```json
{
  "jsonrpc": "2.0",
  "id": 2,
  "result": {
    "tools": [
      {
        "name": "control_device",
        "description": "控制智能家居设备",
        "inputSchema": {
          "type": "object",
          "properties": {
            "device_id": {
              "type": "string",
              "description": "设备ID"
            },
            "action": {
              "type": "string",
              "enum": ["turn_on", "turn_off", "set_brightness"],
              "description": "执行的操作"
            },
            "value": {
              "type": "number",
              "description": "参数值，如亮度百分比"
            }
          },
          "required": ["device_id", "action"]
        }
      }
    ]
  }
}
```

**调用工具请求：**
```json
{
  "jsonrpc": "2.0",
  "id": 3,
  "method": "tools/call",
  "params": {
    "name": "control_device",
    "arguments": {
      "device_id": "living_room_light",
      "action": "turn_on"
    }
  }
}
```

**工具调用响应：**
```json
{
  "jsonrpc": "2.0",
  "id": 3,
  "result": {
    "content": [
      {
        "type": "text",
        "text": "已成功打开客厅灯，当前状态：ON"
      }
    ],
    "isError": false
  }
}
```

### AIguard 中 MCP 的使用方式

由于当前通义千问 API 原生支持 Function Calling，MCP 可作为工具管理框架：

**方案一：MCP Server 对接通义千问 Function Calling**
```
用户语音 → ASR → 通义千问（工具选择）→ MCP Client → MCP Server → 设备执行
                                                                     ↓
                           TTS 播放回复 ← 通义千问（结果总结） ← 工具结果
```

**AIguard MCP Server 提供的工具：**

| 工具名 | 功能 |
|--------|------|
| `control_device` | 控制设备开关、亮度、色温等 |
| `query_device_status` | 查询设备当前状态 |
| `get_sensor_history` | 查询传感器历史数据 |
| `create_automation` | 创建自动化规则 |
| `get_weather` | 查询天气 |
| `set_reminder` | 设置提醒 |
| `trigger_alarm` | 触发告警 |
| `get_room_temperature` | 获取房间温度 |

### Java MCP Server 实现（基础示例）

使用 `mcp-sdk-java`（Spring AI 已支持）：

```xml
<dependency>
    <groupId>org.springframework.ai</groupId>
    <artifactId>spring-ai-mcp-server-webflux</artifactId>
    <version>1.0.0</version>
</dependency>
```

**工具定义：**
```java
@Service
public class DeviceControlTool {

    private final HomeAssistantService haService;

    @McpTool(name = "control_device",
             description = "控制智能家居设备开关或调节参数")
    public String controlDevice(
        @McpToolParam(description = "设备ID", required = true) String deviceId,
        @McpToolParam(description = "操作：turn_on/turn_off/set_brightness", required = true) String action,
        @McpToolParam(description = "参数值，如亮度0-100") Double value
    ) {
        try {
            switch (action) {
                case "turn_on" -> {
                    haService.callService("light", "turn_on", Map.of("entity_id", deviceId));
                    return "已打开设备：" + deviceId;
                }
                case "turn_off" -> {
                    haService.callService("light", "turn_off", Map.of("entity_id", deviceId));
                    return "已关闭设备：" + deviceId;
                }
                case "set_brightness" -> {
                    haService.callService("light", "turn_on", Map.of(
                        "entity_id", deviceId,
                        "brightness_pct", value));
                    return "已设置 " + deviceId + " 亮度为 " + value + "%";
                }
                default -> {
                    return "不支持的操作：" + action;
                }
            }
        } catch (Exception e) {
            return "操作失败：" + e.getMessage();
        }
    }

    @McpTool(name = "query_device_status",
             description = "查询智能家居设备当前状态")
    public String queryDeviceStatus(
        @McpToolParam(description = "设备ID，不填返回所有设备") String deviceId
    ) {
        if (deviceId != null) {
            var state = haService.getEntityState(deviceId);
            return deviceId + " 当前状态：" + state.get("state");
        } else {
            // 返回所有设备列表摘要
            return haService.getAllStatesSummary();
        }
    }
}
```

**MCP Server 配置（application.yml）：**
```yaml
spring:
  ai:
    mcp:
      server:
        name: aiguard-mcp
        version: 1.0.0
        sse-message-endpoint: /mcp/messages
server:
  port: 8081
```

### MCP 与通义千问对接流程

```java
@Service
@RequiredArgsConstructor
@Slf4j
public class McpQwenIntegrationService {

    private final QwenService qwenService;
    private final McpClientService mcpClient;

    public String chatWithMcp(String userMessage, String sessionId) {
        // 1. 获取所有可用工具（从MCP Server）
        List<McpTool> tools = mcpClient.listTools();

        // 2. 转换为通义千问 Function Calling 格式
        List<Map<String, Object>> qwenTools = convertToQwenTools(tools);

        // 3. 第一次调用大模型
        ChatResponse response = qwenService.chatWithTools(userMessage, qwenTools);

        // 4. 判断是否需要工具调用
        if (response.hasToolCalls()) {
            List<ToolResult> toolResults = new ArrayList<>();

            // 5. 执行所有工具调用
            for (ToolCall call : response.getToolCalls()) {
                try {
                    McpToolResult result = mcpClient.callTool(
                        call.getName(),
                        call.getArguments()
                    );
                    toolResults.add(new ToolResult(call.getId(), result.getText()));
                } catch (Exception e) {
                    toolResults.add(new ToolResult(call.getId(), "错误: " + e.getMessage()));
                }
            }

            // 6. 将工具结果传入，生成最终回复
            return qwenService.generateFinalResponse(userMessage, response, toolResults);
        }

        return response.getContent();
    }
}
```

### Python MCP Server 快速示例（使用官方 SDK）

```python
# mcp_server.py
import asyncio
from mcp.server import Server
from mcp.server.stdio import stdio_server
from mcp.types import Tool, TextContent
import json
import httpx

app = Server("aiguard-mcp")
HA_URL = "http://localhost:8123/api"
HA_TOKEN = "YOUR_HA_LONG_LIVED_TOKEN"


@app.list_tools()
async def list_tools() -> list[Tool]:
    return [
        Tool(
            name="control_device",
            description="控制智能家居设备开关或调节参数",
            inputSchema={
                "type": "object",
                "properties": {
                    "device_id": {"type": "string", "description": "设备ID (entity_id)"},
                    "action": {"type": "string", "enum": ["turn_on", "turn_off"], "description": "操作"}
                },
                "required": ["device_id", "action"]
            }
        ),
        Tool(
            name="get_weather",
            description="查询城市天气",
            inputSchema={
                "type": "object",
                "properties": {"city": {"type": "string", "description": "城市名称"}},
                "required": ["city"]
            }
        )
    ]


@app.call_tool()
async def call_tool(name: str, arguments: dict) -> list[TextContent]:
    if name == "control_device":
        device_id = arguments["device_id"]
        action = arguments["action"]
        service = "turn_on" if action == "turn_on" else "turn_off"
        domain = device_id.split(".")[0]

        async with httpx.AsyncClient() as client:
            await client.post(
                f"{HA_URL}/services/{domain}/{service}",
                headers={"Authorization": f"Bearer {HA_TOKEN}"},
                json={"entity_id": device_id}
            )
        return [TextContent(type="text", text=f"已{action}设备 {device_id}")]

    elif name == "get_weather":
        # 实际项目中调用天气 API
        city = arguments.get("city", "北京")
        return [TextContent(type="text", text=f"{city}今天晴，25°C，适合外出。")]

    raise ValueError(f"未知工具: {name}")


async def main():
    async with stdio_server() as (read_stream, write_stream):
        await app.run(read_stream, write_stream, app.create_initialization_options())

if __name__ == "__main__":
    asyncio.run(main())
```

## 常见坑点

1. **MCP 生态成熟度**
   - MCP 于 2024 年底发布，仍在快速发展，SDK 可能有 Breaking Changes
   - Java SDK 相对较新，推荐关注 Spring AI 的 MCP 支持
   - Python 和 TypeScript SDK 是官方主要维护的，相对更稳定

2. **通配符/安全问题**
   - MCP Server 具有工具执行能力，必须考虑权限控制
   - 文件系统类工具要限制访问路径，防止读取敏感文件
   - 设备控制类工具需做权限校验（谁可以控制什么设备）
   - 生产环境建议 MCP Server 仅监听本地回环地址

3. **工具描述质量直接影响效果**
   - 工具的 `description` 和参数说明越清晰，模型选择工具和填充参数的准确率越高
   - 提供示例值和使用场景说明有帮助
   - 避免模糊或歧义的描述

4. **多次工具调用处理**
   - 模型可能一次返回多个 `tool_calls`，需并行或顺序执行
   - 某些工具调用依赖前一个工具的结果，需多轮调用
   - 设置最大工具调用轮数（建议 5-10 轮）防止无限循环

5. **超时和错误处理**
   - 工具调用设置合理超时（设备控制 5s，数据查询 10s）
   - 工具失败时返回清晰的错误信息，模型可能会自我修正重试
   - 网络异常、设备离线等情况需优雅降级

6. **传输方式选择**
   - `stdio`：本地进程间通信，安全性高，适合本地工具
   - `SSE`（Server-Sent Events）：基于 HTTP，支持远程部署
   - `Streamable HTTP`：MCP 新规范，双向流式，推荐用于远程服务
   - AIguard 后端与 MCP Server 在同一机器时优先用 stdio

7. **上下文窗口限制**
   - 工具定义（schema）会占用 token，工具数量不要过多
   - 建议根据用户意图动态加载相关工具，而非一次性加载所有工具
   - 资源（Resources）不要一次性全部推给模型，按需读取

8. **与 Function Calling 的关系**
   - MCP 的工具定义最终还是转换成各模型支持的 Function Calling 格式
   - MCP 是更上层的工具管理标准，提供统一的工具发现、调用接口
   - 如果只对接单个模型，直接用模型原生 Function Calling 更简单
   - 需要对接多个模型或复用工具时，MCP 价值更大

## 官方链接

详见 [official-links.md](official-links.md)。

- MCP 官方网站：https://modelcontextprotocol.io/
- MCP 规范文档：https://spec.modelcontextprotocol.io/
- MCP GitHub 组织：https://github.com/modelcontextprotocol
- MCP Python SDK：https://github.com/modelcontextprotocol/python-sdk
- MCP TypeScript SDK：https://github.com/modelcontextprotocol/typescript-sdk
- MCP Java SDK (Spring AI)：https://docs.spring.io/spring-ai/reference/api/mcp/mcp.html
- Awesome MCP Servers：https://github.com/modelcontextprotocol/servers
- MCP 中文介绍（Anthropic 博客）：https://www.anthropic.com/news/model-context-protocol
