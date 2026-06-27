# AI 技术栈

AIguard 采用通义千问大模型 API 结合 MCP（Model Context Protocol）实现智能对话和工具调用。

## 目录

- [通义千问 API](qwen-api.md) - 阿里云通义千问大模型接口使用
- [MCP](mcp.md) - Model Context Protocol 协议与工具调用
- [官方链接](official-links.md) - 通义千问/MCP官方文档链接

## 技术栈概览

| 技术 | 用途 |
|------|------|
| 通义千问（Qwen）| 自然语言理解、对话生成、指令识别 |
| MCP (Model Context Protocol) | 大模型工具调用标准协议 |
| 工具调用（Function Calling）| 控制智能家居设备、查询信息 |
| TTS/ASR | 语音合成/语音识别（小智内置）|

## 快速参考

```bash
# 通义千问 API 快速测试
curl https://dashscope.aliyuncs.com/api/v1/services/aigc/text-generation/generation \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "qwen-turbo",
    "input": {
      "messages": [
        {"role": "user", "content": "你好，请介绍一下自己"}
      ]
    }
  }'
```

## 常见坑点

1. 通义千问 API Key 需要在阿里云百炼平台申请，注意开通对应模型服务
2. MCP 工具定义需要清晰的参数描述，模型才能正确选择工具和填充参数
3. 工具调用需设置超时和错误处理，避免因工具故障导致对话卡住
4. 注意 API 调用费用和频率限制，建议做缓存和限流
5. 敏感操作（如开门、关闭安防）需二次确认或权限控制

## 官方链接

详见 [official-links.md](official-links.md)。
