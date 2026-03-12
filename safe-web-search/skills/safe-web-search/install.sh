#!/bin/bash
# Safe Web Search Skill 安装脚本

set -e

echo "🔒 安装安全互联网搜索技能..."
echo "================================"

# 检查 Python3
if ! command -v python3 &> /dev/null; then
    echo "❌ 需要 Python3，但未找到"
    exit 1
fi

# 检查必要工具
REQUIRED_TOOLS=("curl" "jq")
for tool in "${REQUIRED_TOOLS[@]}"; do
    if ! command -v "$tool" &> /dev/null; then
        echo "⚠️  建议安装工具: $tool"
    fi
done

# 创建配置目录
CONFIG_DIR="$HOME/.config/openclaw/safe-web-search"
mkdir -p "$CONFIG_DIR"

# 复制配置文件
if [ ! -f "$CONFIG_DIR/config.json" ]; then
    echo "📄 创建默认配置文件..."
    cp config.example.json "$CONFIG_DIR/config.json"
    echo "   配置文件位置: $CONFIG_DIR/config.json"
else
    echo "📄 配置文件已存在，跳过创建"
fi

# 设置脚本权限
chmod +x safe_search.py

# 创建日志目录
LOG_DIR="$HOME/.local/share/openclaw/logs/safe-web-search"
mkdir -p "$LOG_DIR"

echo ""
echo "✅ 安装完成！"
echo ""
echo "使用方法："
echo "1. 基本搜索: ./safe_search.py '搜索关键词'"
echo "2. 限制结果: ./safe_search.py '关键词' --max-results 5"
echo ""
echo "安全配置："
echo "- 编辑配置文件: $CONFIG_DIR/config.json"
echo "- 安全级别: low/medium/high"
echo "- 每日限制: daily_search_limit"
echo ""
echo "📊 技能特性："
echo "• 内容安全过滤"
echo "• 恶意网站阻止"
• HTTPS 强制要求"
echo "• 搜索频率限制"
echo "• 隐私保护设计"
echo ""
echo "⚠️  安全提示："
echo "• 定期检查配置文件"
echo "• 监控搜索日志"
echo "• 根据需要调整安全级别"