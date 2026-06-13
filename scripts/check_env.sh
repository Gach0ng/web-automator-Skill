#!/bin/bash
# Web-Automator Environment Check Script

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

CONFIG_FILE="$HOME/.claude/skills/web-automator/config/browser-use.json"
ENV_FILE="$HOME/.claude/skills/web-automator/config/.env"

echo "=========================================="
echo "  Web-Automator Environment Check"
echo "=========================================="
echo ""

# 检测可用的 Python 命令
PYTHON_CMD=""
if command -v python &> /dev/null; then
    PYTHON_CMD="python"
elif command -v python3 &> /dev/null; then
    PYTHON_CMD="python3"
fi

# 1. 检查 Python
echo -n "[1/5] Python... "
if [ -n "$PYTHON_CMD" ]; then
    PYTHON_VERSION=$($PYTHON_CMD --version 2>&1 | awk '{print $2}')
    PYTHON_MAJOR=$(echo "$PYTHON_VERSION" | cut -d. -f1)
    PYTHON_MINOR=$(echo "$PYTHON_VERSION" | cut -d. -f2)
    if [ "$PYTHON_MAJOR" -ge 3 ] && [ "$PYTHON_MINOR" -ge 11 ]; then
        echo -e "${GREEN}✅ $PYTHON_VERSION${NC}"
        PYTHON_OK=true
    else
        echo -e "${RED}❌ $PYTHON_VERSION (需要 3.11+)${NC}"
        PYTHON_OK=false
    fi
else
    echo -e "${RED}❌ 未安装${NC}"
    PYTHON_OK=false
fi

# 2. 检查 browser-use
echo -n "[2/5] browser-use... "
if [ -n "$PYTHON_CMD" ] && $PYTHON_CMD -c "import browser_use" 2>/dev/null; then
    BU_VERSION=$($PYTHON_CMD -m pip show browser-use 2>/dev/null | grep Version | awk '{print $2}')
    echo -e "${GREEN}✅ $BU_VERSION${NC}"
    BU_OK=true
else
    echo -e "${RED}❌ 未安装${NC}"
    BU_OK=false
fi

# 3. 检查 Playwright
echo -n "[3/5] Playwright... "
if [ -n "$PYTHON_CMD" ] && $PYTHON_CMD -c "from playwright.sync_api import sync_playwright" 2>/dev/null; then
    PW_VERSION=$($PYTHON_CMD -m pip show playwright 2>/dev/null | grep Version | awk '{print $2}')
    echo -e "${GREEN}✅ $PW_VERSION${NC}"
    PW_OK=true
else
    echo -e "${RED}❌ 未安装${NC}"
    PW_OK=false
fi

# 4. 检查 API Key
echo -n "[4/5] API Key... "
if [ -f "$ENV_FILE" ]; then
    if grep -q "ANTHROPIC_API_KEY=." "$ENV_FILE" 2>/dev/null; then
        BASE_URL=$(grep "ANTHROPIC_BASE_URL=" "$ENV_FILE" 2>/dev/null | cut -d= -f2-)
        if [ -n "$BASE_URL" ]; then
            echo -e "${GREEN}✅ Anthropic (自定义 endpoint)${NC}"
        else
            echo -e "${GREEN}✅ Anthropic${NC}"
        fi
        API_OK=true
    elif grep -q "OPENAI_API_KEY=." "$ENV_FILE" 2>/dev/null; then
        echo -e "${GREEN}✅ OpenAI${NC}"
        API_OK=true
    elif grep -q "DEEPSEEK_API_KEY=." "$ENV_FILE" 2>/dev/null; then
        echo -e "${GREEN}✅ DeepSeek${NC}"
        API_OK=true
    else
        echo -e "${RED}❌ 未配置${NC}"
        API_OK=false
    fi
else
    echo -e "${RED}❌ .env 文件不存在${NC}"
    API_OK=false
fi

# 5. 检查项目位置
echo -n "[5/5] 项目路径... "
PROJECT_PATH=""

# 从配置文件读取
if [ -f "$CONFIG_FILE" ] && [ -n "$PYTHON_CMD" ]; then
    PROJECT_PATH=$($PYTHON_CMD -c "import json; print(json.load(open(r'$CONFIG_FILE')).get('project_path',''))" 2>/dev/null || echo "")
fi

# 搜索常见路径
if [ -z "$PROJECT_PATH" ]; then
    for path in "$HOME/browser-use" "$HOME/projects/browser-use" "D:/Learning/AI/browser-use"; do
        if [ -d "$path" ] && [ -f "$path/browser_use/__init__.py" ]; then
            PROJECT_PATH="$path"
            break
        fi
    done
fi

# 通过 import 查找
if [ -z "$PROJECT_PATH" ] && [ -n "$PYTHON_CMD" ]; then
    PROJECT_PATH=$($PYTHON_CMD -c "import os, browser_use; print(os.path.dirname(os.path.dirname(browser_use.__file__)))" 2>/dev/null || echo "")
fi

if [ -n "$PROJECT_PATH" ]; then
    echo -e "${GREEN}✅ $PROJECT_PATH${NC}"
    PATH_OK=true
else
    echo -e "${RED}❌ 未找到${NC}"
    PATH_OK=false
fi

# 总结
echo ""
echo "=========================================="

ALL_OK=true
[ "$PYTHON_OK" != true ] && ALL_OK=false
[ "$BU_OK" != true ] && ALL_OK=false
[ "$PW_OK" != true ] && ALL_OK=false
[ "$API_OK" != true ] && ALL_OK=false
[ "$PATH_OK" != true ] && ALL_OK=false

if [ "$ALL_OK" = true ]; then
    echo -e "${GREEN}✅ 全部通过，可以使用 web-automator${NC}"
    exit 0
else
    echo -e "${RED}❌ 部分检查未通过：${NC}"
    echo ""
    [ "$PYTHON_OK" != true ] && echo "  - 安装 Python 3.11+"
    [ "$BU_OK" != true ] && echo "  - pip install browser-use"
    [ "$PW_OK" != true ] && echo "  - python -m playwright install chromium"
    [ "$API_OK" != true ] && echo "  - 配置 API Key → $ENV_FILE"
    echo ""
    echo "  或运行: bash ~/.claude/skills/web-automator/scripts/setup_env.sh"
    exit 1
fi
