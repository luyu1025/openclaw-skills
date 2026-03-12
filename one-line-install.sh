#!/bin/bash
# 单行安装命令 - 安全互联网搜索技能

# 使用方法：
# curl -sSL https://raw.githubusercontent.com/luyu1025/openclaw-skills/main/one-line-install.sh | bash

set -e

echo "🔒 安装安全互联网搜索技能..."
echo "================================"

# 临时目录
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

# 克隆仓库
echo "📥 下载技能文件..."
git clone -q https://github.com/luyu1025/openclaw-skills.git
cd openclaw-skills/safe-web-search/skills/safe-web-search

# 安装
echo "⚙️  安装技能..."
chmod +x install.sh
./install.sh

# 集成到 OpenClaw
echo "🔗 集成到 OpenClaw..."
OPENCLAW_SKILLS_DIR="$HOME/.openclaw/workspace/skills"
mkdir -p "$OPENCLAW_SKILLS_DIR"
cp -r ../.. "$OPENCLAW_SKILLS_DIR/safe-web-search"

# 清理
cd /
rm -rf "$TEMP_DIR"

echo ""
echo "✅ 安装完成！"
echo ""
echo "使用方法："
echo "1. 进入技能目录: cd ~/.openclaw/workspace/skills/safe-web-search/skills/safe-web-search"
echo "2. 执行搜索: ./safe_search.py '搜索关键词'"
echo "3. 查看帮助: ./safe_search.py --help"
echo ""
echo "📁 配置文件: ~/.config/openclaw/safe-web-search/config.json"
echo "📊 安全级别: 编辑配置文件中的 'security_level' (low/medium/high)"