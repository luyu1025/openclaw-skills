# 安全互联网搜索技能 - 部署指南

本文档详细说明如何在不同环境中部署安全互联网搜索技能。

## 🎯 部署目标

- **个人电脑**：Windows/macOS/Linux
- **服务器**：云服务器、本地服务器
- **开发环境**：测试和开发用途
- **生产环境**：正式使用环境

## 📋 系统要求

### 最低要求
- **操作系统**：Linux/macOS/Windows (WSL)
- **Python**：3.7 或更高版本
- **Git**：用于从仓库安装
- **网络连接**：访问互联网

### 推荐配置
- **内存**：至少 512MB
- **存储**：至少 100MB 可用空间
- **网络**：稳定的互联网连接

## 🚀 快速部署

### 方法一：单行命令安装（最简单）
```bash
# 复制并执行以下命令
curl -sSL https://raw.githubusercontent.com/luyu1025/openclaw-skills/main/one-line-install.sh | bash
```

### 方法二：手动安装
```bash
# 1. 克隆仓库
git clone https://github.com/luyu1025/openclaw-skills.git
cd openclaw-skills/safe-web-search

# 2. 安装技能
cd skills/safe-web-search
chmod +x install.sh
./install.sh

# 3. 集成到 OpenClaw
cp -r ../.. ~/.openclaw/workspace/skills/safe-web-search
```

## 💻 不同操作系统的部署

### Linux (Ubuntu/Debian)
```bash
# 安装依赖
sudo apt update
sudo apt install -y git python3 python3-pip curl

# 部署技能
./deploy-remote.sh
```

### macOS
```bash
# 安装 Homebrew（如果未安装）
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 安装依赖
brew install git python curl

# 部署技能
./deploy-remote.sh
```

### Windows (使用 WSL)
```bash
# 在 WSL 中执行
# 1. 启用 WSL（如果未启用）
wsl --install

# 2. 进入 Linux 环境后，使用 Linux 部署方法
```

## 🏢 企业/团队部署

### 集中式部署
```bash
# 在中央服务器上部署
./deploy-remote.sh

# 为团队成员创建访问
# 方法1：共享技能目录
# 方法2：提供安装包
# 方法3：配置内部仓库
```

### 批量部署脚本
```bash
#!/bin/bash
# batch-deploy.sh - 批量部署到多台机器

MACHINES=(
    "user1@server1"
    "user2@server2"
    "user3@server3"
)

for machine in "${MACHINES[@]}"; do
    echo "部署到 $machine..."
    ssh "$machine" "bash -s" < ./deploy-remote.sh
    echo "完成 $machine"
done
```

## 🔧 配置管理

### 环境特定配置
```bash
# 开发环境配置
cp config.example.json config-dev.json
# 修改配置为开发环境设置

# 生产环境配置  
cp config.example.json config-prod.json
# 修改配置为生产环境设置
```

### 配置同步
```bash
# 将配置推送到所有实例
rsync -avz ~/.config/openclaw/safe-web-search/ user@remote:~/.config/openclaw/safe-web-search/
```

## 🧪 测试部署

### 功能测试
```bash
# 1. 测试基本搜索
./safe_search.py "测试搜索"

# 2. 测试安全过滤
./safe_search.py "测试恶意内容"

# 3. 测试配置
python3 -c "from safe_search import SafeWebSearch; s = SafeWebSearch(); print(s.get_search_stats())"
```

### 性能测试
```bash
# 测试响应时间
time ./safe_search.py "性能测试"

# 测试并发能力
for i in {1..10}; do
    ./safe_search.py "测试$i" &
done
wait
```

## 🔐 安全部署检查清单

### 部署前检查
- [ ] 验证源代码完整性
- [ ] 检查依赖包安全性
- [ ] 配置防火墙规则
- [ ] 设置访问权限

### 部署后检查
- [ ] 验证技能功能正常
- [ ] 测试安全过滤生效
- [ ] 检查日志记录正常
- [ ] 确认配置正确

### 定期维护
- [ ] 更新技能版本
- [ ] 更新安全规则
- [ ] 清理日志文件
- [ ] 备份配置数据

## 🚨 故障排除

### 常见问题

#### 问题1：安装失败
**症状**：`git clone` 或 `./install.sh` 失败
**解决**：
```bash
# 检查网络连接
ping github.com

# 手动下载
wget https://github.com/luyu1025/openclaw-skills/archive/main.zip
unzip main.zip
```

#### 问题2：Python 错误
**症状**：`ImportError` 或语法错误
**解决**：
```bash
# 检查 Python 版本
python3 --version

# 安装必要模块
pip3 install requests beautifulsoup4
```

#### 问题3：权限问题
**症状**：`Permission denied`
**解决**：
```bash
# 添加执行权限
chmod +x *.sh *.py

# 使用正确用户
sudo -u openclaw ./install.sh
```

### 获取帮助
1. 查看日志：`~/.local/share/openclaw/logs/safe-web-search/`
2. 检查配置：`~/.config/openclaw/safe-web-search/config.json`
3. 查看文档：`README.md` 和 `SKILL.md`

## 🔄 更新部署

### 更新现有部署
```bash
# 1. 备份当前版本
cp -r ~/.openclaw/workspace/skills/safe-web-search ~/safe-web-search-backup

# 2. 获取最新版本
cd ~/.openclaw/workspace/skills
rm -rf safe-web-search
git clone https://github.com/luyu1025/openclaw-skills.git
cd openclaw-skills/safe-web-search

# 3. 重新安装
cd skills/safe-web-search
./install.sh
```

### 版本回滚
```bash
# 如果新版本有问题，回滚到备份
rm -rf ~/.openclaw/workspace/skills/safe-web-search
cp -r ~/safe-web-search-backup ~/.openclaw/workspace/skills/safe-web-search
```

## 📊 监控和维护

### 监控指标
- 搜索成功率
- 安全阻止次数
- 资源使用情况
- 错误率

### 维护任务
```bash
# 每日检查
./safe_search.py "健康检查"

# 每周清理
find ~/.local/share/openclaw/logs/safe-web-search -name "*.log" -mtime +7 -delete

# 每月备份
tar -czf safe-web-search-backup-$(date +%Y%m).tar.gz ~/.config/openclaw/safe-web-search/
```

## 🤝 贡献部署经验

如果你有：
- 新的部署方法
- 特定环境的部署技巧
- 故障排除经验

欢迎提交 Issue 或 Pull Request 到 GitHub 仓库！

---

**提示**：对于生产环境部署，建议先在测试环境验证，然后再部署到生产环境。