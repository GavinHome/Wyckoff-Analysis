#!/bin/bash
# Wyckoff Analysis 本地开发运行脚本
# 使用方法：bash local-dev.sh

set -e

# 项目目录
PROJECT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
cd "$PROJECT_DIR"

echo "=========================================="
echo " Wyckoff Analysis 本地开发脚本"
echo "=========================================="

# 1. 检查虚拟环境
if [ ! -d ".venv" ]; then
    echo "[1/4] 创建虚拟环境..."
    uv venv
else
    echo "[1/4] 虚拟环境已存在"
fi

# 2. 激活虚拟环境
echo "[2/4] 激活虚拟环境..."
source .venv/bin/activate

# 3. 安装/更新依赖
echo "[3/4] 安装项目依赖..."
uv pip install -e .

# 4. 加载环境变量
echo "[4/4] 加载环境变量..."
if [ -f ".env" ]; then
    # 安全地加载 .env 文件（跳过注释和空行）
    while IFS='=' read -r key value; do
        # 跳过注释和空行
        if [[ ! "$key" =~ ^[[:space:]]*# ]] && [[ -n "$key" ]]; then
            export "$key=$value"
        fi
    done < .env
    echo "      ✓ 已加载 .env 文件"
else
    echo "      ⚠️ 未找到 .env 文件"
fi

echo ""
echo "=========================================="
echo " 环境变量检查"
echo "=========================================="
echo "GEMINI_API_KEY: ${GEMINI_API_KEY:0:10}..."
echo "SUPABASE_URL: ${SUPABASE_URL}"
echo "FEISHU_WEBHOOK_URL: ${FEISHU_WEBHOOK_URL:0:40}..."
echo "DAILY_JOB_SKIP_STEP4: ${DAILY_JOB_SKIP_STEP4}"
echo ""

# 提示用户选择运行模式
echo "=========================================="
echo " 选择运行模式"
echo "=========================================="
echo "1. 启动 CLI 对话（交互式选股）"
echo "2. 运行每日任务（完整漏斗筛选）"
echo "3. 启动 Dashboard"
read -p "请输入选择 (1/2/3): " choice

case $choice in
    1)
        echo ""
        echo "启动 CLI 对话..."
        wyckoff
        ;;
    2)
        echo ""
        echo "运行每日任务..."
        echo "日志路径: logs/daily_job.log"
        mkdir -p logs
        python scripts/daily_job.py --logs logs/daily_job.log
        ;;
    3)
        echo ""
        echo "启动 Dashboard..."
        wyckoff dashboard
        ;;
    *)
        echo "无效选择"
        exit 1
        ;;
esac
