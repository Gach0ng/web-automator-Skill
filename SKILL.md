---
name: web-automator
description: >
  Browser automation skill using browser-use library.
  Manages browser-use project, configures environment, and executes browser automation tasks.
  Use when user wants to automate browser actions, scrape websites, fill forms, click buttons, or perform any web task.
version: 1.0.0
user-invocable: true
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
  - Glob
  - Grep
---

# Web Automator Skill

> 补齐 Claude Code 缺乏浏览器操控能力的短板，将自然语言任务转化为浏览器自动化操作

## When to Use This Skill

- 用户要求执行浏览器操作（打开网页、点击、填写表单、发送消息等）
- 用户需要网页数据抓取或自动化 Web 流程
- 用户输入 `/web-automator` 或提及 "browser-use"、"浏览器自动化"

**触发短语：**
- "帮我打开网页..." / "自动完成..." / "抓取网页数据..."
- "/web-automator"
- "用浏览器..." / "browser-use..."

---

## 命令格式

```
/web-automator <task描述>
```

### 示例

```
/web-automator 打开百度搜索"browser-use"，获取前5个结果标题
/web-automator 登录 mywebsite.com，用户名 test，密码 123456
/web-automator 打开 deepseek 对话框，发送"你好"，等待回复后截图
```

---

## Execution Flow

### Step 1: 环境检测

```bash
bash ~/.claude/skills/web-automator/scripts/check_env.sh
```

检测项目：
- Python 3.11+
- browser-use 库 (pip)
- Playwright 浏览器
- AI API Key
- browser-use 项目位置

### Step 2: 环境修复（如有缺失）

```bash
bash ~/.claude/skills/web-automator/scripts/setup_env.sh
```

修复流程：
1. browser-use 未安装 → `pip install browser-use`
2. Playwright 未安装 → `playwright install chromium`
3. API Key 未配置 → 提示用户输入并保存
4. 项目路径未记录 → 搜索或 pip install

### Step 3: 任务执行

```bash
cd <project_path> && python ~/.claude/skills/web-automator/scripts/run_task.py "<task>"
```

### Step 4: 结果输出

格式化输出任务状态、耗时、步骤数和最终结果。

---

## LLM Provider 配置

| Provider | 环境变量 | 默认模型 |
|----------|----------|----------|
| Anthropic | `ANTHROPIC_API_KEY` | claude-3-5-sonnet |
| OpenAI | `OPENAI_API_KEY` | gpt-4o |
| MiniMax | `ANTHROPIC_BASE_URL` + `ANTHROPIC_API_KEY` | MiniMax-M3 |
| DeepSeek | `DEEPSEEK_API_KEY` | deepseek-chat |

---

## 配置文件

位置：`~/.claude/skills/web-automator/config/browser-use.json`

```json
{
    "project_path": "",
    "env_file": "~/.claude/skills/web-automator/config/.env",
    "default_llm": "anthropic",
    "default_model": "MiniMax-M3",
    "base_url": "https://api.minimaxi.com/anthropic",
    "headless": false,
    "max_steps": 20,
    "use_system_chrome": true
}
```

---

## 错误处理

| 错误 | 原因 | 解决方案 |
|------|------|----------|
| `ModuleNotFoundError: browser_use` | 未安装 | `pip install browser-use` |
| `Playwright not installed` | 浏览器未安装 | `playwright install chromium` |
| `API key not found` | 环境变量未设置 | 运行 setup_env.sh 配置 |
| `Connection timeout` | 网络问题 | 检查网络或 proxy |
| `Max steps reached` | 任务过于复杂 | 增加 max_steps 或简化任务 |
