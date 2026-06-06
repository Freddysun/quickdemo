#!/bin/bash
# =============================================================
# bedrock-gpt-curl-demo.sh
# 通过 Amazon Bedrock 调用 GPT 模型的 curl 演示示例
# =============================================================
#
# 前置条件:
#   1. 已在 Bedrock 控制台 (us-east-2) 生成 API Key
#   2. 已安装 curl 和 jq (可选，用于格式化输出)
#
# 使用方法:
#   chmod +x bedrock-gpt-curl-demo.sh
#   export BEDROCK_API_KEY="your-bedrock-api-key"
#   ./bedrock-gpt-curl-demo.sh
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

echo "🚀 正在通过 Amazon Bedrock 调用 GPT 模型..."
echo "   端点: ${BASE_URL}"
echo "   模型: ${MODEL}"
echo "=========================================================="
echo ""

# -------------------- 调用 Responses API --------------------
RESPONSE=$(curl -s -X POST "${BASE_URL}/responses" \
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
        "content": "请用一句话解释什么是 Amazon Bedrock?"
      }
    ],
    "reasoning": {
      "effort": "medium"
    },
    "text": {
      "verbosity": "low"
    }
  }')

# -------------------- 输出结果 --------------------
echo "📥 原始响应:"
echo "${RESPONSE}" | jq . 2>/dev/null || echo "${RESPONSE}"

echo ""
echo "=========================================================="
echo "✅ 模型输出:"
echo "${RESPONSE}" | jq -r '.output_text // .output[0].content[0].text // "无法解析输出"' 2>/dev/null || echo "${RESPONSE}"
echo ""
echo "=========================================================="
echo "💡 提示:"
echo "   - GPT-5.5 仅支持 us-east-2 (Ohio)"
echo "   - GPT-5.4 支持 us-east-2 和 us-west-2"
echo "   - Bedrock 上 GPT 模型只支持 Responses API，不支持 Chat Completions"
echo "   - 生产环境建议使用短期 API Key + aws-bedrock-token-generator 自动续期"
