#!/bin/bash
# ============================================================
# Claude Code 一键卸载脚本 (macOS / Linux)
# 用法: curl -fsSL https://raw.githubusercontent.com/Frio99/claude-install/main/uninstall.sh | bash
# ============================================================
set -e

echo ""
echo "============================================"
echo "  Claude Code 一键卸载 (Mac / Linux)"
echo "============================================"
echo ""

# ---------- [1/3] 卸载 Claude Code 程序 ----------
echo "[1/3] 卸载 Claude Code 程序..."
if command -v npm >/dev/null 2>&1 && npm ls -g @anthropic-ai/claude-code >/dev/null 2>&1; then
    npm uninstall -g @anthropic-ai/claude-code
    echo "  ✅ 已卸载 @anthropic-ai/claude-code"
else
    echo "  (未检测到通过 npm 安装的 Claude Code,跳过)"
fi

# ---------- [2/3] 是否清除配置 + 登录信息 ----------
echo ""
echo "[2/3] 是否同时删除「配置 + 登录信息」(完全重置,适合重新录教程)?"
echo "      将删除: ~/.claude 目录、~/.claude.json"
printf "      删除请输入 y,保留请直接回车: "
REPLY=""
if [ -e /dev/tty ]; then read -r REPLY </dev/tty; fi
if [ "$REPLY" = "y" ] || [ "$REPLY" = "Y" ]; then
    rm -rf "$HOME/.claude" "$HOME/.claude.json" 2>/dev/null || true
    echo "  ✅ 已清除配置和登录信息"
    if [ "$(uname -s)" = "Darwin" ]; then
        echo "  (如登录态仍残留,可在「钥匙串访问」中搜索 Claude 手动删除)"
    fi
else
    echo "  已保留配置和登录信息"
fi

# ---------- [3/3] 深度清理:连 Node.js / Git 一起卸载 ----------
echo ""
echo "[3/3] 深度清理:是否连 Node.js 和 Git 一起卸载?(适合录教程从零演示安装)"
echo "      ⚠️  警告: Node.js / Git 是通用开发工具,其它依赖它们的程序会受影响!"
printf "      确认全部卸载请输入 yes(必须完整输入 yes),否则直接回车跳过: "
REPLY2=""
if [ -e /dev/tty ]; then read -r REPLY2 </dev/tty; fi
if [ "$REPLY2" = "yes" ]; then
    if command -v brew >/dev/null 2>&1; then
        echo "  通过 Homebrew 卸载 Node.js..."
        brew uninstall --ignore-dependencies node node@20 node@18 2>/dev/null || true
        echo "  通过 Homebrew 卸载 Git..."
        brew uninstall git 2>/dev/null || echo "  (系统/Xcode 自带的 git 无法用此方式卸载,通常也无需卸载)"
        echo "  ✅ 已尝试通过 Homebrew 卸载 Node.js / Git"
    else
        echo "  未检测到 Homebrew,无法自动卸载。Linux 用户请用包管理器手动卸载:"
        echo "    apt:    sudo apt remove nodejs npm git"
        echo "    dnf:    sudo dnf remove nodejs git"
        echo "    pacman: sudo pacman -R nodejs npm git"
    fi
else
    echo "  已保留 Node.js 和 Git"
fi

echo ""
echo "============================================"
echo "  卸载完成"
echo ""
echo "  想重新安装:"
echo "  curl -fsSL https://raw.githubusercontent.com/Frio99/claude-install/main/install.sh | bash"
echo "============================================"
echo ""
