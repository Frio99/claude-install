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

# ---------- [1/2] 卸载 Claude Code 程序 ----------
echo "[1/2] 卸载 Claude Code 程序..."
if command -v npm >/dev/null 2>&1 && npm ls -g @anthropic-ai/claude-code >/dev/null 2>&1; then
    npm uninstall -g @anthropic-ai/claude-code
    echo "  ✅ 已卸载 @anthropic-ai/claude-code"
else
    echo "  (未检测到通过 npm 安装的 Claude Code,跳过)"
fi

# ---------- [2/2] 是否清除配置 + 登录信息 ----------
echo ""
echo "[2/2] 是否同时删除「配置 + 登录信息」(完全重置,适合重新录教程)?"
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

echo ""
echo "============================================"
echo "  卸载完成"
echo "  注: Node.js / Git 等通用工具未删除(其他程序可能在用)"
echo ""
echo "  想重新安装:"
echo "  curl -fsSL https://raw.githubusercontent.com/Frio99/claude-install/main/install.sh | bash"
echo "============================================"
echo ""
