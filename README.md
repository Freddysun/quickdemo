# Bedrock GPT curl 演示

通过 Amazon Bedrock 调用 OpenAI GPT 模型的 curl 示例脚本。

## 快速开始

```bash
# 1. 设置 Bedrock API Key
export BEDROCK_API_KEY="your-bedrock-api-key"

# 2. 运行脚本
chmod +x bedrock-gpt-curl-demo.sh
./bedrock-gpt-curl-demo.sh
```

## 关键信息

| 配置项 | 值 |
|--------|----|
| 端点 | `https://bedrock-mantle.us-east-2.api.aws/openai/v1` |
| GPT-5.5 模型 ID | `openai.gpt-5.5` |
| GPT-5.4 模型 ID | `openai.gpt-5.4` |
| API 类型 | Responses API（不支持 Chat Completions） |
| 上下文窗口 | 272K tokens |

## 注意事项

- ⚠️ Bedrock 上的 GPT 模型**只支持 Responses API**，不支持 Chat Completions / Converse / InvokeModel
- GPT-5.5 仅在 `us-east-2` (Ohio) 可用
- GPT-5.4 在 `us-east-2` 和 `us-west-2` 可用
- `base_url` 填到 `/openai/v1`，不要带 `/responses`
- 生产环境建议使用短期 API Key（最长 12 小时）+ `aws-bedrock-token-generator` 自动续期

## 从 Chat Completions 迁移

如果你原来使用 `client.chat.completions.create(...)`，需要改写为 `client.responses.create(...)`：

| Chat Completions（旧） | Responses API（新） |
|---|---|
| `client.chat.completions.create(...)` | `client.responses.create(...)` |
| `messages=[...]` | `input=[...]` |
| `{"role":"system", ...}` | `{"role":"developer", ...}` |
| `response.choices[0].message.content` | `response.output_text` |
| `max_tokens` | `max_output_tokens` |

## 参考

- [Amazon Bedrock 文档](https://docs.aws.amazon.com/bedrock/)
