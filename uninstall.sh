#!/bin/bash
# ============================================================
# Claude Code 一键卸载脚本 (macOS / Linux)
# ⚠️ 第 [3/3] 深度清理会卸 Node/Git/Python 等通用工具，
#    只应在【沙盒 / 虚拟机 / 新建的临时用户账户】里用来录教程，
#    千万别在你的主力机上跑。
# 用法: curl -fsSL https://raw.githubusercontent.com/Frio99/claude-install/main/uninstall.sh | bash
# ============================================================
set -e

echo ""
echo "============================================"
echo "  Claude Code 一键卸载 (Mac / Linux)"
echo "============================================"
echo ""

# ---------- [1/3] 卸载 Claude Code 程序（原生 + npm 两种装法都处理）----------
echo "[1/3] 卸载 Claude Code 程序..."
REMOVED=false

# (a) npm 全局包
if command -v npm >/dev/null 2>&1 && npm ls -g @anthropic-ai/claude-code >/dev/null 2>&1; then
    npm uninstall -g @anthropic-ai/claude-code && REMOVED=true
    echo "  ✅ 已卸载 npm 版 @anthropic-ai/claude-code"
fi

# (b) 官方原生安装器装的二进制（只删位于用户主目录下的，绝不碰系统路径）
CLAUDE_BIN="$(command -v claude 2>/dev/null || true)"
if [ -n "$CLAUDE_BIN" ]; then
    REAL="$(readlink -f "$CLAUDE_BIN" 2>/dev/null || echo "$CLAUDE_BIN")"
    case "$REAL" in
        "$HOME"/*)
            rm -f "$CLAUDE_BIN" "$REAL" 2>/dev/null || true
            rm -rf "$HOME/.local/share/claude" "$HOME/.claude/bin" 2>/dev/null || true
            echo "  ✅ 已删除原生安装的 claude ($REAL)"
            REMOVED=true
            ;;
        *)
            echo "  (claude 位于系统路径 $REAL，未自动删除，避免误伤；如需可手动处理)"
            ;;
    esac
fi

[ "$REMOVED" = false ] && echo "  (未检测到已安装的 Claude Code，跳过)"

# ---------- [2/3] 是否清除配置 + 登录信息 ----------
echo ""
echo "[2/3] 是否同时删除「配置 + 登录信息」(完全重置，适合重新录教程)?"
echo "      将删除: ~/.claude 目录、~/.claude.json"
printf "      删除请输入 y，保留请直接回车: "
REPLY=""
if [ -e /dev/tty ]; then read -r REPLY </dev/tty; fi
if [ "$REPLY" = "y" ] || [ "$REPLY" = "Y" ]; then
    rm -rf "$HOME/.claude" "$HOME/.claude.json" 2>/dev/null || true
    echo "  ✅ 已清除配置和登录信息"
    if [ "$(uname -s)" = "Darwin" ]; then
        echo "  (如登录态仍残留，可在「钥匙串访问」中搜索 Claude 手动删除)"
    fi
else
    echo "  已保留配置和登录信息"
fi

# ---------- [3/3] 深度清理：连 Node.js / Git / Python 一起卸载 ----------
echo ""
echo "[3/3] 深度清理：连 Node.js / Git / Python 一起卸载?(只为在沙盒里从零演示安装)"
echo "      ⚠️  警告: 这些是通用工具，其它依赖它们的程序会一起坏掉！"
echo "      ⚠️  务必只在【沙盒 / 虚拟机 / 临时用户账户】里执行，别在主力机跑！"
printf "      确认全部卸载请完整输入 yes，否则直接回车跳过: "
REPLY2=""
if [ -e /dev/tty ]; then read -r REPLY2 </dev/tty; fi
if [ "$REPLY2" = "yes" ]; then
    if command -v brew >/dev/null 2>&1; then
        echo "  通过 Homebrew 卸载 Node.js / Git / Python..."
        brew uninstall --ignore-dependencies node node@20 node@18 2>/dev/null || true
        brew uninstall git 2>/dev/null || echo "  (系统/Xcode 自带的 git 无法用此方式卸载)"
        brew uninstall --ignore-dependencies python python@3.12 python@3.11 2>/dev/null || true
        echo "  ✅ 已尝试通过 Homebrew 卸载 Node.js / Git / Python"
        echo "  (Mac 上 Xcode 命令行工具自带的 python3/git 不会被卸；如需彻底白板请用全新虚拟机)"
    elif command -v apt-get >/dev/null 2>&1; then
        sudo apt-get remove -y nodejs npm git python3 2>/dev/null || true
        echo "  ✅ 已尝试通过 apt 卸载"
    elif command -v dnf >/dev/null 2>&1; then
        sudo dnf remove -y nodejs git python3 2>/dev/null || true
        echo "  ✅ 已尝试通过 dnf 卸载"
    elif command -v pacman >/dev/null 2>&1; then
        sudo pacman -R --noconfirm nodejs npm git python 2>/dev/null || true
        echo "  ✅ 已尝试通过 pacman 卸载"
    else
        echo "  未检测到包管理器，无法自动卸载。"
    fi
else
    echo "  已保留 Node.js / Git / Python"
fi

echo ""
echo "============================================"
echo "  卸载完成"
echo ""
echo "  想重新安装:"
echo "  curl -fsSL https://raw.githubusercontent.com/Frio99/claude-install/main/install.sh | bash"
echo "============================================"
echo ""
