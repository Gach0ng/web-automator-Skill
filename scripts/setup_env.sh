#!/bin/bash
# Web-Automator Environment Setup Script
# 自动修复缺失的环境依赖 + 交互式 API Key 配置

# 检测可用的 Python 命令
PYTHON_CMD="python"
command -v python3 &> /dev/null && python3 --version &> /dev/null && PYTHON_CMD="python3"

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SKILL_DIR="$HOME/.claude/skills/web-automator"
CONFIG_FILE="$SKILL_DIR/config/browser-use.json"
ENV_FILE="$SKILL_DIR/config/.env"

echo "=========================================="
echo "  Web-Automator Environment Setup"
echo "=========================================="
echo ""

# 1. 安装 browser-use
echo -e "${BLUE}[1/4] 检查 browser-use...${NC}"
if $PYTHON_CMD -c "import browser_use" 2>/dev/null; then
    echo -e "${GREEN}✅ browser-use 已安装${NC}"
else
    echo -e "${YELLOW}正在安装 browser-use...${NC}"
    pip install browser-use
    echo -e "${GREEN}✅ browser-use 安装完成${NC}"
fi

# 2. 安装 Playwright 浏览器
echo -e "${BLUE}[2/4] 检查 Playwright...${NC}"
if command -v playwright &> /dev/null; then
    echo -e "${GREEN}✅ Playwright 已安装${NC}"
    echo -e "${YELLOW}正在安装 Chromium 浏览器...${NC}"
    playwright install chromium
    echo -e "${GREEN}✅ Chromium 安装完成${NC}"
else
    echo -e "${YELLOW}正在通过 Python 安装 Playwright...${NC}"
    $PYTHON_CMD -m playwright install chromium
    echo -e "${GREEN}✅ Playwright + Chromium 安装完成${NC}"
fi

# 3. 配置 API Key
echo -e "${BLUE}[3/4] 配置 API Key...${NC}"
mkdir -p "$(dirname "$ENV_FILE")"

if [ -f "$ENV_FILE" ]; then
    echo -e "${GREEN}✅ .env 文件已存在${NC}"
else
    echo -e "${YELLOW}创建 .env 文件...${NC}"
    touch "$ENV_FILE"
fi

# 检查是否已有 Key
HAS_KEY=false
if grep -q "ANTHROPIC_API_KEY=." "$ENV_FILE" 2>/dev/null; then HAS_KEY=true; fi
if grep -q "OPENAI_API_KEY=." "$ENV_FILE" 2>/dev/null; then HAS_KEY=true; fi
if grep -q "DEEPSEEK_API_KEY=." "$ENV_FILE" 2>/dev/null; then HAS_KEY=true; fi

if [ "$HAS_KEY" = true ]; then
    echo -e "${GREEN}✅ API Key 已配置${NC}"
else
    echo ""
    echo "请选择 LLM Provider："
    echo "  1) Anthropic (Claude)"
    echo "  2) OpenAI (GPT)"
    echo "  3) MiniMax (Anthropic 兼容)"
    echo "  4) DeepSeek"
    echo "  5) 手动配置"
    echo ""
    read -p "输入选项 (1-5): " choice

    case $choice in
        1)
            read -p "输入 Anthropic API Key: " api_key
            echo "ANTHROPIC_API_KEY=$api_key" >> "$ENV_FILE"
            echo -e "${GREEN}✅ Anthropic API Key 已保存${NC}"
            ;;
        2)
            read -p "输入 OpenAI API Key: " api_key
            echo "OPENAI_API_KEY=$api_key" >> "$ENV_FILE"
            echo -e "${GREEN}✅ OpenAI API Key 已保存${NC}"
            ;;
        3)
            read -p "输入 MiniMax API Key: " api_key
            read -p "输入 Base URL [https://api.minimaxi.com/anthropic]: " base_url
            base_url=${base_url:-"https://api.minimaxi.com/anthropic"}
            echo "ANTHROPIC_API_KEY=$api_key" >> "$ENV_FILE"
            echo "ANTHROPIC_BASE_URL=$base_url" >> "$ENV_FILE"
            echo -e "${GREEN}✅ MiniMax 配置已保存${NC}"
            ;;
        4)
            read -p "输入 DeepSeek API Key: " api_key
            echo "DEEPSEEK_API_KEY=$api_key" >> "$ENV_FILE"
            echo -e "${GREEN}✅ DeepSeek API Key 已保存${NC}"
            ;;
        5)
            echo "请手动编辑: $ENV_FILE"
            ;;
        *)
            echo -e "${RED}无效选项${NC}"
            ;;
    esac
fi

# 4. 创建/更新配置文件
echo -e "${BLUE}[4/4] 创建配置文件...${NC}"

# 查找项目路径
PROJECT_PATH=""
POSSIBLE_PATHS=(
    "$HOME/browser-use"
    "$HOME/projects/browser-use"
    "$HOME/AI/browser-use"
    "D:/Learning/AI/browser-use"
)

for path in "${POSSIBLE_PATHS[@]}"; do
    if [ -d "$path" ] && [ -f "$path/browser_use/__init__.py" ]; then
        PROJECT_PATH="$path"
        break
    fi
done

if [ -z "$PROJECT_PATH" ]; then
    PROJECT_PATH=$($PYTHON_CMD -c "import os, browser_use; print(os.path.dirname(os.path.dirname(browser_use.__file__)))" 2>/dev/null || echo "")
fi

if [ -z "$PROJECT_PATH" ]; then
    echo -e "${YELLOW}未找到 browser-use 项目目录${NC}"
    read -p "输入项目路径（或按回车使用 pip 安装路径）: " PROJECT_PATH
fi

# 确定默认模型
DEFAULT_MODEL="MiniMax-M3"
DEFAULT_LLM="anthropic"
BASE_URL=""
if [ -f "$ENV_FILE" ]; then
    if grep -q "OPENAI_API_KEY=." "$ENV_FILE" 2>/dev/null; then
        DEFAULT_MODEL="gpt-4o"
        DEFAULT_LLM="openai"
    fi
    BASE_URL=$(grep "ANTHROPIC_BASE_URL=" "$ENV_FILE" 2>/dev/null | cut -d= -f2- || echo "")
fi

mkdir -p "$(dirname "$CONFIG_FILE")"
cat > "$CONFIG_FILE" << EOF
{
    "project_path": "$PROJECT_PATH",
    "env_file": "$ENV_FILE",
    "default_llm": "$DEFAULT_LLM",
    "default_model": "$DEFAULT_MODEL",
    "base_url": "$BASE_URL",
    "headless": false,
    "max_steps": 20,
    "use_system_chrome": true
}
EOF

echo -e "${GREEN}✅ 配置已保存到: $CONFIG_FILE${NC}"

echo ""
echo "=========================================="
echo -e "${GREEN}  Setup 完成！${NC}"
echo "=========================================="
echo ""
echo "使用方式: /web-automator <任务描述>"
echo ""
