#!/usr/bin/env python3
"""
安全互联网搜索工具
为 OpenClaw 提供安全的互联网访问能力
"""

import json
import re
import sys
import os
from typing import List, Dict, Optional, Tuple
import urllib.parse
import hashlib
from datetime import datetime, timedelta

class SafeWebSearch:
    """安全网页搜索类"""
    
    def __init__(self, config_path: str = None):
        """初始化安全搜索器"""
        self.config = self._load_config(config_path)
        self.search_history = []
        self.blocked_patterns = self._load_blocked_patterns()
        
    def _load_config(self, config_path: str = None) -> Dict:
        """加载配置文件"""
        default_config = {
            "security_level": "medium",  # low, medium, high
            "max_results_per_search": 10,
            "daily_search_limit": 50,
            "blocked_domains": [
                # 高风险域名示例
                ".*\\.onion$",  # Tor 隐藏服务
                ".*\\.xyz$",    # 常见垃圾域名
            ],
            "allowed_content_types": [
                "text/html",
                "application/json",
                "text/plain"
            ],
            "require_https": True,
            "user_agent": "SafeWebSearch/1.0 (OpenClaw Security Bot)",
            "timeout_seconds": 30
        }
        
        if config_path and os.path.exists(config_path):
            try:
                with open(config_path, 'r', encoding='utf-8') as f:
                    user_config = json.load(f)
                    default_config.update(user_config)
            except Exception as e:
                print(f"警告：无法加载配置文件 {config_path}: {e}")
        
        return default_config
    
    def _load_blocked_patterns(self) -> List[str]:
        """加载阻止模式"""
        patterns = [
            # 恶意内容模式
            r"malware|virus|trojan|ransomware",
            r"phishing|scam|fraud",
            r"exploit|vulnerability",
            
            # 不适当内容
            r"porn|adult|xxx|nsfw",
            r"gambling|casino|betting",
            
            # 非法活动
            r"hack|crack|warez",
            r"drugs|weapons|illegal",
        ]
        
        # 根据安全级别调整
        if self.config["security_level"] == "high":
            patterns.extend([
                r"violence|hate|extremist",
                r"pirate|torrent",
            ])
        
        return patterns
    
    def is_url_safe(self, url: str) -> Tuple[bool, str]:
        """检查URL是否安全"""
        try:
            parsed = urllib.parse.urlparse(url)
            
            # 检查协议
            if self.config["require_https"] and parsed.scheme != "https":
                return False, "需要HTTPS协议"
            
            # 检查域名
            domain = parsed.netloc.lower()
            
            # 检查阻止的域名模式
            for pattern in self.config["blocked_domains"]:
                if re.match(pattern, domain):
                    return False, f"域名被阻止: {domain}"
            
            # 检查常见的高风险域名
            risky_tlds = ['.onion', '.xyz', '.top', '.win', '.bid', '.loan']
            if any(domain.endswith(tld) for tld in risky_tlds):
                return False, f"高风险顶级域名: {domain}"
            
            return True, "URL安全"
            
        except Exception as e:
            return False, f"URL解析错误: {e}"
    
    def filter_content(self, content: str, url: str = "") -> Tuple[str, List[str]]:
        """过滤内容中的不安全元素"""
        warnings = []
        filtered_content = content
        
        # 检查阻止模式
        for pattern in self.blocked_patterns:
            if re.search(pattern, content, re.IGNORECASE):
                warnings.append(f"检测到可能不安全的内容: {pattern}")
                # 在高安全级别下，完全阻止内容
                if self.config["security_level"] == "high":
                    return "", warnings
        
        # 移除可疑的脚本标签
        filtered_content = re.sub(
            r'<script[^>]*>.*?</script>',
            '<!-- 脚本已移除 -->',
            filtered_content,
            flags=re.DOTALL | re.IGNORECASE
        )
        
        # 移除可疑的事件处理器
        filtered_content = re.sub(
            r'\bon\w+\s*=\s*"[^"]*"',
            '',
            filtered_content,
            flags=re.IGNORECASE
        )
        
        # 限制内容长度（防止过大内容）
        max_length = 100000  # 100KB
        if len(filtered_content) > max_length:
            filtered_content = filtered_content[:max_length] + "... [内容已截断]"
            warnings.append("内容过长，已截断")
        
        return filtered_content, warnings
    
    def can_perform_search(self) -> Tuple[bool, str]:
        """检查是否可以执行搜索（基于限制）"""
        today = datetime.now().date()
        today_searches = [
            s for s in self.search_history
            if s.get("date") == today.isoformat()
        ]
        
        if len(today_searches) >= self.config["daily_search_limit"]:
            return False, f"已达到每日搜索限制 ({self.config['daily_search_limit']}次)"
        
        return True, "可以执行搜索"
    
    def log_search(self, query: str, url: str = "", result_count: int = 0):
        """记录搜索历史"""
        search_record = {
            "date": datetime.now().date().isoformat(),
            "time": datetime.now().time().isoformat(),
            "query": query[:100],  # 限制查询长度
            "url": url[:200] if url else "",
            "result_count": result_count,
            "query_hash": hashlib.sha256(query.encode()).hexdigest()[:16]
        }
        
        self.search_history.append(search_record)
        
        # 保持历史记录大小
        if len(self.search_history) > 100:
            self.search_history = self.search_history[-100:]
    
    def get_search_stats(self) -> Dict:
        """获取搜索统计信息"""
        today = datetime.now().date()
        today_searches = [
            s for s in self.search_history
            if s.get("date") == today.isoformat()
        ]
        
        return {
            "total_searches": len(self.search_history),
            "today_searches": len(today_searches),
            "daily_limit": self.config["daily_search_limit"],
            "security_level": self.config["security_level"]
        }
    
    def safe_search(self, query: str, max_results: int = None) -> Dict:
        """执行安全搜索"""
        # 检查搜索限制
        can_search, reason = self.can_perform_search()
        if not can_search:
            return {
                "success": False,
                "error": reason,
                "results": []
            }
        
        # 验证查询
        if not query or len(query.strip()) < 2:
            return {
                "success": False,
                "error": "搜索查询太短",
                "results": []
            }
        
        if len(query) > 500:
            return {
                "success": False,
                "error": "搜索查询太长",
                "results": []
            }
        
        # 记录搜索
        self.log_search(query)
        
        # 在实际实现中，这里会调用 web_search 工具
        # 为了安全，我们返回一个模拟响应
        return {
            "success": True,
            "query": query,
            "security_check": "通过",
            "note": "这是一个安全搜索示例。实际实现需要集成 web_search 工具。",
            "results": [
                {
                    "title": f"安全搜索结果: {query}",
                    "url": "https://example.com/safe-result",
                    "snippet": f"这是关于 '{query}' 的安全搜索结果。所有内容都经过安全检查。",
                    "safe": True
                }
            ],
            "stats": self.get_search_stats()
        }


def main():
    """命令行入口点"""
    if len(sys.argv) < 2:
        print("用法: safe_search.py <搜索查询> [--max-results N]")
        print("示例: safe_search.py 'Python 编程教程' --max-results 5")
        sys.exit(1)
    
    query = sys.argv[1]
    max_results = 10
    
    # 解析参数
    for i in range(2, len(sys.argv)):
        if sys.argv[i] == "--max-results" and i + 1 < len(sys.argv):
            try:
                max_results = int(sys.argv[i + 1])
            except ValueError:
                print(f"错误: 无效的最大结果数: {sys.argv[i + 1]}")
                sys.exit(1)
    
    # 执行安全搜索
    searcher = SafeWebSearch()
    result = searcher.safe_search(query, max_results)
    
    # 输出结果
    if result["success"]:
        print(f"搜索查询: {result['query']}")
        print(f"安全检查: {result['security_check']}")
        print(f"结果数量: {len(result['results'])}")
        print()
        
        for i, item in enumerate(result["results"], 1):
            print(f"{i}. {item['title']}")
            print(f"   URL: {item['url']}")
            print(f"   摘要: {item['snippet']}")
            print(f"   安全: {'是' if item.get('safe') else '否'}")
            print()
        
        stats = result.get("stats", {})
        print(f"今日搜索: {stats.get('today_searches', 0)}/{stats.get('daily_limit', 50)}")
        print(f"安全级别: {stats.get('security_level', 'medium')}")
    else:
        print(f"搜索失败: {result.get('error', '未知错误')}")


if __name__ == "__main__":
    main()