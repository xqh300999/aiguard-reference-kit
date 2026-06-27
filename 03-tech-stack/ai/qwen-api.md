# 通义千问 API

通义千问（Qwen）是阿里云推出的大语言模型系列，提供多模态对话、函数调用等能力。

## 快速参考

### 获取 API Key

1. 注册阿里云账号：https://www.aliyun.com/
2. 进入百炼平台：https://bailian.console.aliyun.com/
3. 创建 API Key：控制台 → API-KEY 管理 → 创建新的 API-KEY
4. 开通模型服务：模型广场 → 选择 `qwen-turbo` / `qwen-plus` / `qwen-max` 等开通

**模型选择建议：**

| 模型 | 特点 | 适用场景 |
|------|------|----------|
| `qwen-turbo` | 速度快、成本低 | 日常对话、简单指令识别 |
| `qwen-plus` | 平衡性能与效果 | 通用场景、工具调用 |
| `qwen-max` | 能力最强、成本较高 | 复杂推理、长文本理解 |
| `qwen-long` | 长文本支持 | 文档问答、RAG 场景 |

### API 基础调用

**OpenAI 兼容接口（推荐）：**
```bash
curl https://dashscope.aliyuncs.com/compatible-mode/v1/chat/completions \
  -H "Authorization: Bearer sk-xxxxxxxxxxxxxxxxxxxxxxxx" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "qwen-plus",
    "messages": [
      {"role": "system", "content": "你是AIguard智能家居助手，可以控制家中设备。"},
      {"role": "user", "content": "打开客厅灯"}
    ]
  }'
```

**DashScope 原生接口：**
```bash
curl https://dashscope.aliyuncs.com/api/v1/services/aigc/text-generation/generation \
  -H "Authorization: Bearer sk-xxxxxxxxxxxxxxxxxxxxxxxx" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "qwen-plus",
    "input": {
      "messages": [
        {"role": "system", "content": "你是AIguard智能家居助手。"},
        {"role": "user", "content": "打开客厅灯"}
      ]
    },
    "parameters": {
      "result_format": "message"
    }
  }'
```

**响应示例：**
```json
{
  "choices": [
    {
      "message": {
        "role": "assistant",
        "content": "好的，已为您打开客厅灯。"
      },
      "finish_reason": "stop"
    }
  ],
  "usage": {
    "total_tokens": 56
  }
}
```

### Java SDK 集成

**Maven 依赖：**
```xml
<dependency>
    <groupId>com.alibaba</groupId>
    <artifactId>dashscope-sdk-java</artifactId>
    <version>2.16.0</version>
</dependency>
<!-- 或使用 OpenAI 兼容的 Java 客户端 -->
<dependency>
    <groupId>com.theokanning.openai-gpt3-java</groupId>
    <artifactId>service</artifactId>
    <version>0.18.2</version>
</dependency>
```

**使用 OkHttp 直接调用（轻量方式，推荐）：**
```java
@Service
@Slf4j
public class QwenService {

    @Value("${qwen.api-key}")
    private String apiKey;

    @Value("${qwen.base-url:https://dashscope.aliyuncs.com/compatible-mode/v1}")
    private String baseUrl;

    @Value("${qwen.model:qwen-plus}")
    private String model;

    private final OkHttpClient httpClient = new OkHttpClient.Builder()
        .connectTimeout(30, TimeUnit.SECONDS)
        .readTimeout(60, TimeUnit.SECONDS)
        .build();

    private final ObjectMapper objectMapper = new ObjectMapper();

    public String chat(String userMessage, List<ChatMessage> history) throws IOException {
        List<Map<String, String>> messages = new ArrayList<>();
        messages.add(Map.of(
            "role", "system",
            "content", "你是AIguard智能家居语音助手，回答简洁，语气友好。"
        ));
        for (ChatMessage msg : history) {
            messages.add(Map.of("role", msg.getRole(), "content", msg.getContent()));
        }
        messages.add(Map.of("role", "user", "content", userMessage));

        Map<String, Object> requestBody = new HashMap<>();
        requestBody.put("model", model);
        requestBody.put("messages", messages);
        requestBody.put("temperature", 0.7);
        requestBody.put("max_tokens", 500);

        Request request = new Request.Builder()
            .url(baseUrl + "/chat/completions")
            .addHeader("Authorization", "Bearer " + apiKey)
            .addHeader("Content-Type", "application/json")
            .post(RequestBody.create(
                objectMapper.writeValueAsString(requestBody),
                MediaType.parse("application/json")
            ))
            .build();

        try (Response response = httpClient.newCall(request).execute()) {
            if (!response.isSuccessful()) {
                throw new RuntimeException("API 调用失败: " + response.code());
            }
            JsonNode jsonNode = objectMapper.readTree(response.body().string());
            return jsonNode
                .path("choices").get(0)
                .path("message").path("content").asText();
        }
    }
}
```

### Function Calling（函数调用）

通义千问支持函数调用，可让模型决定是否需要调用工具：

```java
// 定义工具
List<Map<String, Object>> tools = List.of(
    Map.of(
        "type", "function",
        "function", Map.of(
            "name", "control_device",
            "description", "控制智能家居设备开关或调节",
            "parameters", Map.of(
                "type", "object",
                "properties", Map.of(
                    "device_id", Map.of("type", "string", "description", "设备ID，如living_room_light"),
                    "action", Map.of("type", "string", "enum", List.of("turn_on", "turn_off"), "description", "操作")
                ),
                "required", List.of("device_id", "action")
            )
        )
    ),
    Map.of(
        "type", "function",
        "function", Map.of(
            "name", "get_weather",
            "description", "查询城市天气",
            "parameters", Map.of(
                "type", "object",
                "properties", Map.of(
                    "city", Map.of("type", "string", "description", "城市名称")
                ),
                "required", List.of("city")
            )
        )
    )
);
```

**请求示例（带工具）：**
```java
Map<String, Object> requestBody = new HashMap<>();
requestBody.put("model", "qwen-plus");
requestBody.put("messages", messages);
requestBody.put("tools", tools);
requestBody.put("tool_choice", "auto");
```

**处理工具调用响应：**
```java
public String chatWithTools(String userMessage, String deviceId) throws IOException {
    // ... 构建请求 ...

    JsonNode response = callApi(requestBody);
    JsonNode message = response.path("choices").get(0).path("message");

    // 检查是否有工具调用
    if (message.has("tool_calls")) {
        // 执行工具调用
        JsonNode toolCall = message.path("tool_calls").get(0);
        String functionName = toolCall.path("function").path("name").asText();
        String arguments = toolCall.path("function").path("arguments").asText();
        JsonNode args = objectMapper.readTree(arguments);

        String toolResult;
        switch (functionName) {
            case "control_device" -> {
                String targetDevice = args.get("device_id").asText();
                String action = args.get("action").asText();
                deviceService.control(targetDevice, action);
                toolResult = "操作成功：" + action + " " + targetDevice;
            }
            case "get_weather" -> {
                String city = args.get("city").asText();
                toolResult = weatherService.getWeather(city);
            }
            default -> toolResult = "未知工具";
        }

        // 将工具结果添加到上下文，再次请求生成自然语言回复
        List<Map<String, Object>> updatedMessages = new ArrayList<>(messages);
        // 添加 assistant 的 tool_calls 消息
        // 添加 tool 响应消息
        updatedMessages.add(Map.of("role", "assistant", "content", "", "tool_calls", toolCall));
        updatedMessages.add(Map.of("role", "tool", "tool_call_id",
            toolCall.path("id").asText(), "content", toolResult));

        requestBody.put("messages", updatedMessages);
        JsonNode finalResponse = callApi(requestBody);
        return finalResponse.path("choices").get(0).path("message").path("content").asText();
    }

    return message.path("content").asText();
}
```

### 流式响应（SSE）

适合实时对话场景，逐字输出提升体验：

```java
@GetMapping(value = "/chat/stream", produces = MediaType.TEXT_EVENT_STREAM_VALUE)
public SseEmitter chatStream(@RequestParam String message) {
    SseEmitter emitter = new SseEmitter(60000L);

    // 构建流式请求
    Request request = new Request.Builder()
        .url(baseUrl + "/chat/completions")
        .post(RequestBody.create(
            objectMapper.writeValueAsString(Map.of(
                "model", model,
                "messages", List.of(Map.of("role", "user", "content", message)),
                "stream", true
            )),
            MediaType.parse("application/json")
        ))
        .addHeader("Authorization", "Bearer " + apiKey)
        .build();

    httpClient.newCall(request).enqueue(new Callback() {
        @Override
        public void onResponse(Call call, Response response) throws IOException {
            try (ResponseBody body = response.body()) {
                if (body == null) { emitter.complete(); return; }
                BufferedReader reader = new BufferedReader(
                    new InputStreamReader(body.byteStream()));
                String line;
                while ((line = reader.readLine()) != null) {
                    if (line.startsWith("data: ")) {
                        String data = line.substring(6);
                        if ("[DONE]".equals(data)) break;
                        JsonNode chunk = objectMapper.readTree(data);
                        String content = chunk.path("choices").get(0)
                            .path("delta").path("content").asText("");
                        if (!content.isEmpty()) {
                            emitter.send(SseEmitter.event().data(content));
                        }
                    }
                }
            }
            emitter.complete();
        }

        @Override
        public void onFailure(Call call, IOException e) {
            emitter.completeWithError(e);
        }
    });

    return emitter;
}
```

### 多模态（图片理解）

通义千问 VL 系列支持图片理解：

```java
Map<String, Object> requestBody = Map.of(
    "model", "qwen-vl-plus",
    "messages", List.of(Map.of(
        "role", "user",
        "content", List.of(
            Map.of("type", "text", "text", "这张图片里有什么？"),
            Map.of("type", "image_url", "image_url",
                Map.of("url", "https://example.com/photo.jpg"))
        )
    ))
);
```

## 常见坑点

1. **API Key 安全**
   - API Key 不要硬编码在代码中，使用环境变量或配置中心
   - 生产环境不要在前端暴露 API Key，必须通过后端代理调用
   - 定期轮换 API Key，设置调用配额和告警

2. **模型选择**
   - `qwen-turbo` 速度最快成本最低，但工具调用精度可能弱于 `qwen-plus`
   - 智能家居控制场景建议使用 `qwen-plus` 以上模型以保证工具调用准确率
   - 可配置模型 fallback：turbo 失败自动切换到 plus

3. **System Prompt 设计**
   - 明确告知模型角色、能力边界、回复风格
   - 提供设备列表供模型参考，避免 hallucination（幻觉）
   - 示例：
     ```
     你是AIguard智能家居助手，名字叫小智。
     可用设备：客厅灯、卧室灯、空调、窗帘。
     回复要求：简洁自然，不超过50字，不要解释过多。
     控制设备后直接告知结果。
     ```

4. **工具调用参数**
   - 参数 description 必须清晰、准确，模型依赖描述理解参数含义
   - 枚举值要列出所有可选值并解释含义
   - 敏感操作（如开门、关煤气）建议要求二次确认
   - 工具描述中包含约束条件（如"空调温度设置范围16-30度"）

5. **对话历史管理**
   - 历史对话过多会导致 token 消耗大、响应慢
   - 建议只保留最近 5-10 轮对话
   - 长对话需进行摘要压缩
   - 注意单请求 token 上限（qwen-plus 最大 128k，普通场景无需担心）

6. **错误处理与重试**
   - 常见错误：401（Key无效）、429（频率限制）、500（服务器错误）
   - 429 错误应实现指数退避重试
   - 设置合理超时（连接10s，读取60s）
   - 模型调用失败应有降级回复（如"网络有点问题，请稍后再试"）

7. **流式输出注意事项**
   - 流式响应时工具调用信息也是分块的，需拼接完整 tool_calls
   - 实现相对复杂，非实时场景建议用普通请求
   - 注意处理 SSE 连接中断

## 官方链接

详见 [official-links.md](official-links.md)。

- 阿里云百炼平台：https://bailian.console.aliyun.com/
- 通义千问 API 文档：https://help.aliyun.com/zh/dashscope/
- 通义千问模型介绍：https://help.aliyun.com/zh/dashscope/developer-reference/model-list
- Function Calling 文档：https://help.aliyun.com/zh/dashscope/developer-reference/function-calling
- DashScope SDK Java：https://help.aliyun.com/zh/dashscope/developer-reference/install-sdk-for-java
