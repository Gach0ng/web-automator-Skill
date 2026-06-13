# Web-Automator

Claude Code 的浏览器自动化 Skill，基于 [browser-use](https://github.com/browser-use/browser-use) 实现自然语言驱动的浏览器操控。

## 为什么需要这个？

Claude Code 原生只有 `WebSearch` 和 `WebFetch`，无法真正操控浏览器（点击、填写表单、登录等）。Web-Automator 补齐了这个短板。

## 功能

- **环境自动检测与修复**：Python / browser-use / Playwright / API Key 一键检查
- **多 LLM Provider 支持**：Anthropic / OpenAI / MiniMax / DeepSeek
- **System Chrome 模式**：复用你的 Chrome 浏览器，保留 cookie 和登录态
- **任务执行与监控**：自然语言输入 → 浏览器自动操作 → 结果返回

## 安装

### 1. 克隆 skill 到 Claude Code skills 目录

```bash
# 将 skill 文件放到 ~/.claude/skills/web-automator/
# 目录结构：
~/.claude/skills/web-automator/
├── SKILL.md
├── scripts/
│   ├── check_env.sh
│   ├── setup_env.sh
│   └── run_task.py
├── templates/
│   └── env_template
└── config/
    └── browser-use.json
```

### 2. 配置环境

```bash
bash ~/.claude/skills/web-automator/scripts/setup_env.sh
```

交互式引导完成：
- 安装 `browser-use` 和 `playwright`
- 选择 LLM Provider 并输入 API Key
- 自动检测 browser-use 项目路径

### 3. 验证安装

```bash
bash ~/.claude/skills/web-automator/scripts/check_env.sh
```

输出全部 ✅ 即可使用。

## 使用方式

在 Claude Code 中输入：

```
/web-automator <你的任务描述>
```

### 示例

```
/web-automator 打开百度搜索"browser-use"
/web-automator 登录 mywebsite.com，用户名 test，密码 123456
/web-automator 打开 deepseek 对话框，发送"你好"，等待回复
/web-automator 抓取 Hacker News 首页前10条标题
```
<img width="1638" height="846" alt="image" src="https://github.com/user-attachments/assets/39630ed0-0807-438f-afc7-b8b1f213e3c2" />
<img width="1734" height="1362" alt="image" src="https://github.com/user-attachments/assets/485bea22-16be-41cc-b51a-85b637dd0c77" />

## 支持的 LLM Provider

| Provider | 环境变量 | 默认模型 |
|----------|----------|----------|
| MiniMax | `ANTHROPIC_API_KEY` + `ANTHROPIC_BASE_URL` | MiniMax-M3 |
| Anthropic | `ANTHROPIC_API_KEY` | claude-3-5-sonnet |
| OpenAI | `OPENAI_API_KEY` | gpt-4o |
| DeepSeek | `DEEPSEEK_API_KEY` | deepseek-chat |

## 配置文件

`config/browser-use.json`：

```json
{
    "project_path": "D:/Learning/AI/browser-use",
    "env_file": "~/.claude/skills/web-automator/config/.env",
    "default_llm": "anthropic",
    "default_model": "MiniMax-M3",
    "base_url": "https://api.minimaxi.com/anthropic",
    "headless": false,
    "max_steps": 20,
    "use_system_chrome": true
}
```

| 字段 | 说明 | 默认值 |
|------|------|--------|
| `project_path` | browser-use 项目路径 | 自动检测 |
| `default_llm` | LLM Provider | `anthropic` |
| `default_model` | 模型名称 | `MiniMax-M3` |
| `base_url` | 自定义 API endpoint | 空 |
| `headless` | 无头模式 | `false` |
| `max_steps` | 最大执行步数 | `20` |
| `use_system_chrome` | 使用系统 Chrome | `true` |

## 依赖

- Python 3.11+
- [browser-use](https://github.com/browser-use/browser-use) >= 0.13
- Playwright + Chromium
- 至少一个 LLM Provider 的 API Key

## 常见问题

| 错误 | 解决方案 |
|------|----------|
| `ModuleNotFoundError: browser_use` | `pip install browser-use` |
| `Playwright not installed` | `python -m playwright install chromium` |
| `API key not found` | 编辑 `config/.env` 填入 Key |
| `Max steps reached` | 增大 `max_steps` 或简化任务 |
| 中文乱码 | Windows 终端编码问题，不影响功能 |

## License

MIT
