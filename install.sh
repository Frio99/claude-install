#!/bin/bash
# ============================================================
# Claude Code 官方一键安装脚本 (macOS / Linux)
# 全透明 · 只装官方包 · 不动你的全局 npm 配置
# 用法: curl -fsSL https://raw.githubusercontent.com/Frio99/claude-install/main/install.sh | bash
# ============================================================
set -e

echo ""
echo "============================================"
echo "  Claude Code 官方一键安装 (Mac / Linux)"
echo "============================================"
echo ""

# ---------- [1/4] 检测环境 + 外网连通性 ----------
echo "[1/4] 检测环境..."
echo "  系统: $(uname -s)  架构: $(uname -m)"

MIRROR=""   # 默认走官方源
echo "  探测能否直连官方 npm 源..."
if curl -fsS --max-time 5 https://registry.npmjs.org/ -o /dev/null 2>/dev/null; then
    echo "  ✅ 可直连官方源,使用官方 registry"
else
    echo "  ⚠️  直连慢/失败 → 本次安装改用国内镜像 (仅本次,不改全局配置)"
    MIRROR="--registry=https://registry.npmmirror.com"
fi

# ---------- [2/4] 检测 / 安装 Node.js (>=18) ----------
echo ""
echo "[2/4] 检测 Node.js..."
NEED_NODE=true
if command -v node >/dev/null 2>&1; then
    NODE_MAJOR=$(node -v | sed 's/v//' | cut -d. -f1)
    if [ "$NODE_MAJOR" -ge 18 ] 2>/dev/null; then
        echo "  ✅ Node.js $(node -v) 符合要求"
        NEED_NODE=false
    else
        echo "  ⚠️  Node.js $(node -v) 版本过低 (需 >=18)"
    fi
else
    echo "  未检测到 Node.js"
fi

if [ "$NEED_NODE" = true ]; then
    echo "  安装 Node.js..."
    if command -v brew >/dev/null 2>&1; then
        brew install node
    elif command -v apt >/dev/null 2>&1; then
        sudo apt update -qq && sudo apt install -y nodejs npm
    elif command -v dnf >/dev/null 2>&1; then
        sudo dnf install -y nodejs npm
    elif command -v pacman >/dev/null 2>&1; then
        sudo pacman -S --noconfirm nodejs npm
    else
        echo "  ❌ 未找到包管理器,请手动安装 Node.js >=18: https://nodejs.org"
        exit 1
    fi
    if ! command -v node >/dev/null 2>&1; then
        echo "  ❌ Node.js 安装失败,请手动安装后重试。"
        exit 1
    fi
    echo "  ✅ Node.js 安装完成: $(node -v)"
fi

# ---------- [3/4] 安装 Claude Code (官方包,镜像参数只作用于本次) ----------
echo ""
echo "[3/4] 安装 Claude Code (官方包)..."
npm install -g @anthropic-ai/claude-code@latest $MIRROR

# ---------- [4/4] 验证 ----------
echo ""
echo "[4/4] 验证安装..."
if command -v claude >/dev/null 2>&1; then
    echo "  ✅ 安装成功: $(claude --version 2>/dev/null)"
else
    echo "  ⚠️  已装好,但当前终端找不到 claude 命令"
    echo "      → 重开终端,或执行 source ~/.zshrc (zsh) / source ~/.bashrc (bash)"
fi

echo ""
echo "============================================"
echo "  下一步"
echo "============================================"
echo "  终端输入 claude 回车 → 浏览器登录你的官方订阅账号"
echo ""
echo "  ── (可选) 想切第三方模型省钱? ──"
echo "  可自行安装 cc-switch (一键切换 API 供应商):"
echo "    Mac 一键: brew install --cask cc-switch"
echo "    下载页:   https://github.com/farion1231/cc-switch/releases"
echo "    官网:     https://ccswitch.io"
echo "============================================"
echo ""
