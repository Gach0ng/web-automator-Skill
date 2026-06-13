#!/usr/bin/env python3
"""
Web-Automator Task Runner
加载配置 → 创建 LLM → 执行 Agent → 输出结果
"""

import asyncio
import json
import os
import sys
import time
from pathlib import Path

CONFIG_FILE = Path.home() / ".claude" / "skills" / "web-automator" / "config" / "browser-use.json"


def load_config() -> dict:
    """加载配置文件"""
    if CONFIG_FILE.exists():
        with open(CONFIG_FILE, "r", encoding="utf-8") as f:
            return json.load(f)
    return {}


def load_env(env_file: str):
    """加载 .env 文件到环境变量"""
    if not env_file or not os.path.exists(env_file):
        return
    with open(env_file, "r", encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith("#"):
                continue
            if "=" in line:
                key, _, value = line.partition("=")
                os.environ[key.strip()] = value.strip()


def get_llm(config: dict):
    """根据配置创建 LLM 实例"""
    env_file = config.get("env_file", "")
    load_env(env_file)

    base_url = config.get("base_url", "")
    if base_url:
        os.environ["ANTHROPIC_BASE_URL"] = base_url

    default_llm = config.get("default_llm", "anthropic")
    default_model = config.get("default_model", "MiniMax-M3")

    if default_llm == "openai":
        from browser_use.llm import ChatOpenAI
        return ChatOpenAI(model=default_model, temperature=0.0)
    else:
        from browser_use.llm import ChatAnthropic
        kwargs = {"model": default_model, "temperature": 0.0}
        if base_url:
            kwargs["base_url"] = base_url
        return ChatAnthropic(**kwargs)


async def run_task(task: str, config: dict) -> dict:
    """执行浏览器自动化任务"""
    start_time = time.time()

    try:
        from browser_use import Agent, Browser

        llm = get_llm(config)

        if config.get("use_system_chrome", True):
            try:
                browser = Browser.from_system_chrome()
            except Exception as chrome_err:
                print(f"[WARN] System Chrome failed: {chrome_err}")
                print("[WARN] Falling back to new browser instance")
                browser = Browser()
        else:
            browser = Browser()

        max_steps = config.get("max_steps", 20)
        agent = Agent(task=task, llm=llm, browser=browser)

        print(f"[TASK_START] {task}")
        print(f"[CONFIG] max_steps={max_steps}, system_chrome={config.get('use_system_chrome', True)}")

        history = await agent.run(max_steps=max_steps)

        duration = time.time() - start_time
        return {
            "status": "completed",
            "task": task,
            "result": history.final_result(),
            "duration": round(duration, 2),
            "steps": len(history.history) if hasattr(history, "history") else None,
        }

    except Exception as e:
        duration = time.time() - start_time
        return {
            "status": "failed",
            "task": task,
            "error": str(e),
            "duration": round(duration, 2),
        }


def main():
    if len(sys.argv) < 2:
        print("Usage: python run_task.py <task>")
        print("Example: python run_task.py '打开百度搜索 browser-use'")
        sys.exit(1)

    task = sys.argv[1]
    config = load_config()

    if not config:
        print("[ERROR] 配置文件不存在，请先运行环境配置")
        print("  bash ~/.claude/skills/web-automator/scripts/setup_env.sh")
        sys.exit(1)

    # 切换到项目目录（如果有）
    project_path = config.get("project_path", "")
    if project_path and os.path.exists(project_path):
        os.chdir(project_path)

    result = asyncio.run(run_task(task, config))

    print()
    print("=" * 50)
    print(f"[TASK_RESULT]")
    print(f"Status:   {result['status']}")
    print(f"Task:     {result['task']}")
    print(f"Duration: {result['duration']}s")

    if result["status"] == "completed":
        print(f"Steps:    {result.get('steps', 'N/A')}")
        print(f"Result:\n{result['result']}")
    else:
        print(f"Error:    {result['error']}")

    print("=" * 50)
    sys.exit(0 if result["status"] == "completed" else 1)


if __name__ == "__main__":
    main()
