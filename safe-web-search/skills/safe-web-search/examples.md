# 安全互联网搜索技能 - 使用示例

## 示例 1：基本搜索

### 命令行使用
```bash
# 搜索 Python 编程教程
./safe_search.py "Python 编程教程"

# 限制返回结果数量
./safe_search.py "机器学习算法" --max-results 5
```

### OpenClaw 集成使用
```yaml
# 在技能配置中调用
tool_call:
  name: exec
  params:
    command: ./safe_search.py "{{query}}"
    workdir: /path/to/skill
```

## 示例 2：安全搜索配置

### 高安全级别搜索
```bash
# 首先配置高安全级别
echo '{"security_level": "high"}' > ~/.config/openclaw/safe-web-search/config.json

# 执行高安全搜索
./safe_search.py "网络安全新闻"
```

### 自定义白名单
```json
{
  "security_level": "medium",
  "trusted_sources": [
    "wikipedia.org",
    "github.com",
    "stackoverflow.com",
    "docs.python.org",
    "learn.microsoft.com",
    "developer.mozilla.org"
  ]
}
```

## 示例 3：监控和统计

### 查看搜索统计
```python
from safe_search import SafeWebSearch

searcher = SafeWebSearch()
stats = searcher.get_search_stats()

print(f"今日搜索次数: {stats['today_searches']}/{stats['daily_limit']}")
print(f"总搜索次数: {stats['total_searches']}")
print(f"当前安全级别: {stats['security_level']}")
```

### 检查URL安全性
```python
from safe_search import SafeWebSearch

searcher = SafeWebSearch()

urls_to_check = [
    "https://github.com/openclaw/openclaw",
    "http://example.com",  # 非HTTPS
    "https://malicious-site.xyz",
]

for url in urls_to_check:
    is_safe, reason = searcher.is_url_safe(url)
    status = "✅ 安全" if is_safe else "❌ 不安全"
    print(f"{status}: {url}")
    if not is_safe:
        print(f"  原因: {reason}")
```

## 示例 4：内容过滤

### 过滤网页内容
```python
from safe_search import SafeWebSearch

searcher = SafeWebSearch()

# 模拟的网页内容（包含可疑元素）
sample_content = """
<html>
<head><title>测试页面</title></head>
<body>
    <h1>正常内容</h1>
    <p>这是一段正常的文本内容。</p>
    
    <!-- 可疑脚本 -->
    <script>alert('恶意代码')</script>
    
    <!-- 可疑事件 -->
    <button onclick="maliciousFunction()">点击我</button>
    
    <p>更多正常内容...</p>
</body>
</html>
"""

filtered_content, warnings = searcher.filter_content(sample_content)

print("过滤后的内容:")
print(filtered_content)
print("\n安全警告:")
for warning in warnings:
    print(f"• {warning}")
```

## 示例 5：集成到 OpenClaw 工作流

### 作为独立技能
```markdown
# 在 OpenClaw 中调用安全搜索

用户: "搜索最新的 Python 3.12 特性"

AI 助手响应:
1. 验证搜索请求的安全性
2. 调用安全搜索技能
3. 获取过滤后的结果
4. 整理并返回给用户

命令:
```bash
./safe_search.py "Python 3.12 新特性" --max-results 3
```

### 作为工具链的一部分
```yaml
# 自动化工作流
workflow:
  - name: 研究主题
    action: safe_search
    params:
      query: "{{topic}}"
      max_results: 5
  
  - name: 分析结果
    action: analyze_content
    params:
      content: "{{search_results}}"
  
  - name: 生成报告
    action: generate_report
    params:
      analysis: "{{analysis_result}}"
```

## 示例 6：安全审计

### 检查技能安全性
```bash
# 1. 验证配置文件
python3 -m json.tool ~/.config/openclaw/safe-web-search/config.json

# 2. 测试安全过滤
./safe_search.py "测试恶意内容" --max-results 1

# 3. 检查日志
ls -la ~/.local/share/openclaw/logs/safe-web-search/

# 4. 验证依赖安全性
pip-audit  # 如果使用Python包
```

### 生成安全报告
```python
from safe_search import SafeWebSearch
import json
from datetime import datetime

def generate_security_report():
    searcher = SafeWebSearch()
    stats = searcher.get_search_stats()
    
    report = {
        "generated_at": datetime.now().isoformat(),
        "security_level": searcher.config["security_level"],
        "search_limits": {
            "daily": searcher.config["daily_search_limit"],
            "used_today": stats["today_searches"],
            "remaining": searcher.config["daily_search_limit"] - stats["today_searches"]
        },
        "blocked_domains_count": len(searcher.config["blocked_domains"]),
        "trusted_sources_count": len(searcher.config.get("trusted_sources", [])),
        "content_filters": searcher.config.get("content_filters", {})
    }
    
    return json.dumps(report, indent=2, ensure_ascii=False)

print(generate_security_report())
```

## 最佳实践

### 1. 定期更新
- 定期检查并更新阻止的域名列表
- 关注安全公告，及时调整安全策略
- 更新依赖库到安全版本

### 2. 监控使用
- 定期查看搜索日志
- 设置异常访问警报
- 监控资源使用情况

### 3. 用户教育
- 教育用户安全搜索的重要性
- 提供安全使用指南
- 建立安全反馈机制

### 4. 应急响应
- 建立安全事件响应流程
- 准备紧急停止机制
- 保持备份和恢复能力