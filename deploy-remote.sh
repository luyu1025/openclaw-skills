#!/bin/bash
# 远程部署安全互联网搜索技能

set -e

echo "🚀 安全互联网搜索技能 - 远程部署脚本"
echo "======================================"

# 配置
REPO_URL="https://github.com/luyu1025/openclaw-skills.git"
SKILL_NAME="safe-web-search"
INSTALL_DIR="$HOME/.openclaw/workspace/skills"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# 检查必要工具
check_requirements() {
    echo "检查系统要求..."
    
    local missing_tools=()
    
    for tool in git python3 curl; do
        if ! command -v "$tool" &> /dev/null; then
            missing_tools+=("$tool")
        fi
    done
    
    if [ ${#missing_tools[@]} -gt 0 ]; then
        print_warning "缺少以下工具: ${missing_tools[*]}"
        echo "请先安装这些工具后再运行本脚本。"
        exit 1
    fi
    
    print_success "系统要求检查通过"
}

# 克隆仓库
clone_repository() {
    echo "克隆技能仓库..."
    
    local temp_dir=$(mktemp -d)
    cd "$temp_dir"
    
    if git clone "$REPO_URL" .; then
        print_success "仓库克隆成功"
    else
        print_error "克隆仓库失败"
        exit 1
    fi
}

# 安装技能
install_skill() {
    echo "安装安全互联网搜索技能..."
    
    if [ ! -d "$SKILL_NAME" ]; then
        print_error "技能目录不存在: $SKILL_NAME"
        exit 1
    fi
    
    cd "$SKILL_NAME/skills/safe-web-search"
    
    # 运行安装脚本
    if [ -f "install.sh" ]; then
        chmod +x install.sh
        if ./install.sh; then
            print_success "技能安装成功"
        else
            print_error "安装脚本执行失败"
            exit 1
        fi
    else
        print_warning "未找到安装脚本，进行手动安装"
        manual_install
    fi
}

# 手动安装
manual_install() {
    echo "执行手动安装..."
    
    # 创建配置目录
    local config_dir="$HOME/.config/openclaw/safe-web-search"
    mkdir -p "$config_dir"
    
    # 复制配置文件
    if [ -f "config.example.json" ]; then
        if [ ! -f "$config_dir/config.json" ]; then
            cp config.example.json "$config_dir/config.json"
            print_success "配置文件已创建: $config_dir/config.json"
        else
            print_warning "配置文件已存在，跳过创建"
        fi
    fi
    
    # 设置脚本权限
    if [ -f "safe_search.py" ]; then
        chmod +x safe_search.py
        print_success "主脚本权限设置完成"
    fi
    
    # 创建日志目录
    local log_dir="$HOME/.local/share/openclaw/logs/safe-web-search"
    mkdir -p "$log_dir"
    print_success "日志目录已创建: $log_dir"
}

# 集成到 OpenClaw
integrate_with_openclaw() {
    echo "集成到 OpenClaw..."
    
    # 检查 OpenClaw 目录
    if [ ! -d "$INSTALL_DIR" ]; then
        print_warning "OpenClaw 技能目录不存在: $INSTALL_DIR"
        echo "正在创建目录..."
        mkdir -p "$INSTALL_DIR"
    fi
    
    # 复制技能到 OpenClaw 目录
    local skill_source="$(pwd)/../.."
    local skill_dest="$INSTALL_DIR/safe-web-search"
    
    if [ -d "$skill_dest" ]; then
        print_warning "技能已存在，备份旧版本..."
        mv "$skill_dest" "${skill_dest}.backup.$(date +%Y%m%d_%H%M%S)"
    fi
    
    cp -r "$skill_source" "$skill_dest"
    print_success "技能已复制到: $skill_dest"
}

# 验证安装
verify_installation() {
    echo "验证安装..."
    
    # 检查主脚本
    if [ -f "safe_search.py" ]; then
        if python3 safe_search.py "测试安装" --max-results 1 > /dev/null 2>&1; then
            print_success "技能功能测试通过"
        else
            print_warning "技能功能测试失败，但安装可能仍然成功"
        fi
    fi
    
    # 检查配置文件
    local config_file="$HOME/.config/openclaw/safe-web-search/config.json"
    if [ -f "$config_file" ]; then
        print_success "配置文件存在: $config_file"
    else
        print_warning "配置文件不存在，请手动创建"
    fi
}

# 显示使用说明
show_usage() {
    echo ""
    echo "📖 使用说明"
    echo "=========="
    echo ""
    echo "1. 基本搜索:"
    echo "   ./safe_search.py '搜索关键词'"
    echo ""
    echo "2. 高级搜索:"
    echo "   ./safe_search.py '关键词' --max-results 5"
    echo ""
    echo "3. 配置安全级别:"
    echo "   编辑 ~/.config/openclaw/safe-web-search/config.json"
    echo "   设置 'security_level' 为 low/medium/high"
    echo ""
    echo "4. 查看帮助:"
    echo "   ./safe_search.py --help"
    echo ""
    echo "📁 重要目录:"
    echo "• 技能目录: $INSTALL_DIR/safe-web-search"
    echo "• 配置目录: ~/.config/openclaw/safe-web-search/"
    echo "• 日志目录: ~/.local/share/openclaw/logs/safe-web-search/"
    echo ""
    echo "🔧 故障排除:"
    echo "• 检查网络连接"
    echo "• 验证 Python3 安装"
    echo "• 查看安装日志"
}

# 主函数
main() {
    echo "开始部署安全互联网搜索技能..."
    echo ""
    
    check_requirements
    clone_repository
    install_skill
    integrate_with_openclaw
    verify_installation
    
    echo ""
    print_success "🎉 部署完成！"
    echo ""
    
    show_usage
    
    # 清理临时目录
    cd /
    rm -rf "$(pwd)"
}

# 执行主函数
main "$@"