# Web-Automator

A browser automation skill for Claude Code, powered by [browser-use](https://github.com/browser-use/browser-use). Enables natural language driven browser control directly from Claude Code.

> 中文文档请查看 [README_CN.md](README_CN.md)

## Why?

Claude Code only has `WebSearch` and `WebFetch` — no real browser control (clicking, filling forms, logging in, etc.). Web-Automator bridges this gap.

## Features

- **Auto Environment Setup**: One-click check for Python / browser-use / Playwright / API Key
- **Multi LLM Provider**: Anthropic / OpenAI / MiniMax / DeepSeek
- **System Chrome Mode**: Reuse your existing Chrome browser with cookies and login sessions preserved
- **Task Execution & Monitoring**: Natural language input → browser automation → results returned

## Installation

### 1. Clone skill to Claude Code skills directory

```bash
# Place skill files in ~/.claude/skills/web-automator/
# Directory structure:
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

### 2. Setup environment

```bash
bash ~/.claude/skills/web-automator/scripts/setup_env.sh
```

Interactive setup will:
- Install `browser-use` and `playwright`
- Let you choose LLM Provider and enter API Key
- Auto-detect browser-use project path

### 3. Verify installation

```bash
bash ~/.claude/skills/web-automator/scripts/check_env.sh
```

All ✅ means you're ready to go.

## Usage

In Claude Code, type:

```
/web-automator <your task description>
```

### Examples

```
/web-automator Open Baidu and search "browser-use"
/web-automator Login to mywebsite.com with username test and password 123456
/web-automator Open DeepSeek chat, send "hello", wait for reply
/web-automator Scrape the top 10 titles from Hacker News front page
```

## Supported LLM Providers

| Provider | Environment Variables | Default Model |
|----------|----------------------|---------------|
| MiniMax | `ANTHROPIC_API_KEY` + `ANTHROPIC_BASE_URL` | MiniMax-M3 |
| Anthropic | `ANTHROPIC_API_KEY` | claude-3-5-sonnet |
| OpenAI | `OPENAI_API_KEY` | gpt-4o |
| DeepSeek | `DEEPSEEK_API_KEY` | deepseek-chat |

## Configuration

`config/browser-use.json`:

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

| Field | Description | Default |
|-------|-------------|---------|
| `project_path` | browser-use project path | auto-detected |
| `default_llm` | LLM Provider | `anthropic` |
| `default_model` | Model name | `MiniMax-M3` |
| `base_url` | Custom API endpoint | empty |
| `headless` | Headless mode | `false` |
| `max_steps` | Max execution steps | `20` |
| `use_system_chrome` | Use system Chrome | `true` |

## Requirements

- Python 3.11+
- [browser-use](https://github.com/browser-use/browser-use) >= 0.13
- Playwright + Chromium
- At least one LLM Provider API Key

## Troubleshooting

| Error | Solution |
|-------|----------|
| `ModuleNotFoundError: browser_use` | `pip install browser-use` |
| `Playwright not installed` | `python -m playwright install chromium` |
| `API key not found` | Edit `config/.env` with your key |
| `Max steps reached` | Increase `max_steps` or simplify the task |

## License

MIT
