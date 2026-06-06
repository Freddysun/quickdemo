#!/bin/bash
# =============================================================
# bedrock-gpt-curl-streaming.sh
# 通过 Amazon Bedrock 调用 GPT 模型的 Streaming (流式) curl 演示
# =============================================================
#
# 前置条件:
#   1. 已在 Bedrock 控制台 (us-east-2) 生成 API Key
#   2. 已安装 curl
#
# 使用方法:
#   chmod +x bedrock-gpt-curl-streaming.sh
#   export BEDROCK_API_KEY="your-bedrock-api-key"
#   ./bedrock-gpt-curl-streaming.sh
# =============================================================

set -euo pipefail

# -------------------- 配置 --------------------
BASE_URL="https://bedrock-mantle.us-east-2.api.aws/openai/v1"
MODEL="openai.gpt-5.5"   # 可选: openai.gpt-5.4

# 检查 API Key
if [ -z "${BEDROCK_API_KEY:-}" ]; then
  echo "❌ 错误: 请先设置环境变量 BEDROCK_API_KEY"
  echo "   export BEDROCK_API_KEY=\"your-bedrock-api-key\""
  exit 1
fi

echo "🚀 正在通过 Amazon Bedrock 流式调用 GPT 模型..."
echo "   端点: ${BASE_URL}"
echo "   模型: ${MODEL}"
echo "   模式: Streaming (SSE)"
echo "=========================================================="
echo ""

# -------------------- 流式调用 Responses API --------------------
# 关键: 添加 "stream": true 开启流式输出
# 响应格式为 Server-Sent Events (SSE)

echo "📥 流式输出:"
echo ""

curl -s -N -X POST "${BASE_URL}/responses" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${BEDROCK_API_KEY}" \
  -d '{
    "model": "'"${MODEL}"'",
    "input": [
      {
        "role": "developer",
        "content": "You are a helpful assistant. Please respond in Chinese."
      },
      {
        "role": "user",
        "content": "请详细解释 Amazon Bedrock 的三个核心优势，每个优势用一段话说明。"
      }
    ],
    "stream": true,
    "reasoning": {
      "effort": "medium"
    },
    "text": {
      "verbosity": "medium"
    }
  }' | while IFS= read -r line; do
  # 解析 SSE 事件流
  # 每行格式: data: {json}
  if [[ "$line" == data:* ]]; then
    DATA="${line#data: }"
    
    # 跳过 [DONE] 信号
    if [[ "$DATA" == "[DONE]" ]]; then
      echo ""
      echo ""
      echo "=========================================================="
      echo "✅ 流式输出完成"
      break
    fi
    
    # 提取 delta 文本并实时打印（不换行）
    DELTA=$(echo "$DATA" | jq -r '.delta // empty' 2>/dev/null)
    if [ -n "$DELTA" ]; then
      printf "%s" "$DELTA"
    fi
  fi
done

echo ""
echo "=========================================================="
echo "💡 Streaming 要点:"
echo "   - 请求体中添加 \"stream\": true 即可开启流式"
echo "   - 响应为 Server-Sent Events (SSE) 格式"
echo "   - 每个事件以 'data: ' 开头，后跟 JSON"
echo "   - 流结束时会收到 'data: [DONE]'"
echo "   - curl 使用 -N 参数禁用缓冲，实现实时输出"
