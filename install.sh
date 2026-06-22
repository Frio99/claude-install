#!/bin/bash
# ============================================================
# Claude Code 一键安装 (macOS / Linux)
# 一次装齐三样运行环境：
#   1. Claude Code   —— 主程序（官方原生安装器，无需 Node）
#   2. Python 3      —— 跑「上品 Skill」需要
#   3. Git           —— 常用工具，部分功能需要
# 检测先行 · 缺什么装什么 · 可重复运行（幂等）
# 需要能科学上网（登录 claude.ai / 连 api.anthropic.com）
# 用法: curl -fsSL https://raw.githubusercontent.com/Frio99/claude-install/main/install.sh | bash
# ============================================================
# 不用 set -e：要在某步失败时走兜底，而不是整个脚本中断。

OS="$(uname -s)"
ARCH="$(uname -m)"

echo ""
echo "============================================"
echo "  Claude Code 一键安装 (Mac / Linux)"
echo "============================================"
echo ""

# ---- 探测包管理器 ----
PKG=""
if   command -v apt-get >/dev/null 2>&1; then PKG=apt
elif command -v dnf     >/dev/null 2>&1; then PKG=dnf
elif command -v pacman  >/dev/null 2>&1; then PKG=pacman
elif command -v brew    >/dev/null 2>&1; then PKG=brew
fi

# 把官方原生安装器可能用到的目录补进 PATH（当前会话即时可用）
add_local_bins() {
    for d in "$HOME/.local/bin" "$HOME/.claude/bin" "$HOME/bin" "/opt/homebrew/bin" "/usr/local/bin"; do
        [ -d "$d" ] || continue
        case ":$PATH:" in *":$d:"*) ;; *) PATH="$d:$PATH" ;; esac
    done
    export PATH
}
add_local_bins

# 把 ~/.local/bin 永久写进用户的 shell 配置（原生安装器有时只提示不自动写）
# 保证粉丝「关掉终端重开」后一定能用 claude
ensure_local_bin_on_path() {
    local rc
    case "$(basename "${SHELL:-bash}")" in
        zsh)  rc="$HOME/.zshrc" ;;
        bash) rc="$HOME/.bashrc" ;;
        *)    rc="$HOME/.profile" ;;
    esac
    touch "$rc" 2>/dev/null || return 0
    grep -qF "$HOME/.local/bin" "$rc" 2>/dev/null \
        || printf '\n# 由 claude-install 添加\nexport PATH="$HOME/.local/bin:$PATH"\n' >> "$rc"
}

# Mac 缺命令行工具（Python3 / Git 都来自它）→ 触发安装并请用户重跑
need_clt_then_exit() {
    echo ""
    echo "  ⚠️  这台 Mac 还没装「命令行工具」(Python3 和 Git 都来自它)。"
    echo "  屏幕上会弹出一个安装窗口 → 点「安装 / Install」→ 等它装完(几分钟)。"
    xcode-select --install >/dev/null 2>&1 || true
    echo ""
    echo "  ⏳ 那个窗口装完后，请【把这条安装命令再粘贴运行一次】，脚本会接着往下走。"
    echo ""
    exit 0
}

# ---------- [1/4] 环境检测 ----------
echo "[1/4] 检测环境..."
echo "  系统: $OS   架构: $ARCH   包管理器: ${PKG:-无}"

# Mac 且没有命令行工具 → 先装它（顺带拿到 python3 + git，无需 Homebrew）
if [ "$OS" = "Darwin" ] && ! xcode-select -p >/dev/null 2>&1; then
    need_clt_then_exit
fi

# ---------- [2/4] Python 3（上品 Skill 的运行时）----------
echo ""
echo "[2/4] 检测 Python 3 (运行上品 Skill 需要)..."
PY_OK=false
if command -v python3 >/dev/null 2>&1; then
    PYV=$(python3 -c 'import sys;print("%d.%d"%sys.version_info[:2])' 2>/dev/null)
    PYMAJ=${PYV%%.*}; PYMIN=${PYV##*.}
    if [ "${PYMAJ:-0}" -ge 3 ] 2>/dev/null && [ "${PYMIN:-0}" -ge 8 ] 2>/dev/null; then
        echo "  ✅ Python $PYV 符合要求"
        PY_OK=true
    else
        echo "  ⚠️  Python $PYV 偏旧 (建议 >= 3.8)，尝试升级"
    fi
else
    echo "  未检测到 Python 3，开始安装"
fi

if [ "$PY_OK" != true ]; then
    case "$PKG" in
        apt)    sudo apt-get update -qq; sudo apt-get install -y python3 python3-venv python3-pip ;;
        dnf)    sudo dnf install -y python3 python3-pip ;;
        pacman) sudo pacman -S --noconfirm python python-pip ;;
        brew)   brew install python ;;
        *)      [ "$OS" = "Darwin" ] && need_clt_then_exit ;;
    esac
    if command -v python3 >/dev/null 2>&1; then
        echo "  ✅ Python 安装完成: $(python3 --version 2>&1)"
    else
        echo "  ❌ Python 3 没装上。请到 https://www.python.org/downloads/ 手动安装后重试。"
    fi
fi

# ---------- [3/4] Git ----------
echo ""
echo "[3/4] 检测 Git..."
if command -v git >/dev/null 2>&1; then
    echo "  ✅ 已安装: $(git --version)"
else
    echo "  未检测到 Git，开始安装"
    case "$PKG" in
        apt)    sudo apt-get install -y git ;;
        dnf)    sudo dnf install -y git ;;
        pacman) sudo pacman -S --noconfirm git ;;
        brew)   brew install git ;;
        *)      [ "$OS" = "Darwin" ] && need_clt_then_exit ;;
    esac
    command -v git >/dev/null 2>&1 \
        && echo "  ✅ Git 安装完成: $(git --version)" \
        || echo "  △ Git 暂未装上（非必需，可日后再装）"
fi

# ---------- [4/4] Claude Code（官方原生安装器优先，npm 兜底）----------
echo ""
echo "[4/4] 安装 Claude Code..."
if command -v claude >/dev/null 2>&1; then
    echo "  ✅ 已安装: $(claude --version 2>/dev/null)"
else
    echo "  用官方原生安装器安装（自包含，无需 Node）..."
    curl -fsSL https://claude.ai/install.sh | bash || true
    add_local_bins
    ensure_local_bin_on_path

    if ! command -v claude >/dev/null 2>&1; then
        echo "  原生安装器未成功，改用备用方式（经 Node / npm）..."
        # 备用路径需要 Node >= 18
        NEED_NODE=true
        if command -v node >/dev/null 2>&1; then
            NMAJ=$(node -v | sed 's/v//' | cut -d. -f1)
            [ "${NMAJ:-0}" -ge 18 ] 2>/dev/null && NEED_NODE=false
        fi
        if [ "$NEED_NODE" = true ]; then
            case "$PKG" in
                apt)    sudo apt-get install -y nodejs npm ;;
                dnf)    sudo dnf install -y nodejs npm ;;
                pacman) sudo pacman -S --noconfirm nodejs npm ;;
                brew)   brew install node ;;
                *)      echo "  ❌ 无法自动装 Node，请到 https://nodejs.org 装 >=18 后重试。" ;;
            esac
        fi
        if command -v npm >/dev/null 2>&1; then
            # 直连官方源慢就临时走国内镜像（仅本次，不改全局）
            MIRROR=""
            curl -fsS --max-time 5 https://registry.npmjs.org/ -o /dev/null 2>/dev/null \
                || MIRROR="--registry=https://registry.npmmirror.com"
            npm install -g @anthropic-ai/claude-code@latest $MIRROR
            add_local_bins
        fi
    fi

    if command -v claude >/dev/null 2>&1; then
        echo "  ✅ 安装成功: $(claude --version 2>/dev/null)"
    else
        echo "  ⚠️  已尝试安装，但当前终端还找不到 claude 命令。"
        echo "      → 关掉终端重新打开，再输入 claude 试试。"
    fi
fi

# ---------- 收尾自检 ----------
echo ""
echo "============================================"
echo "  安装结果"
echo "============================================"
if command -v claude >/dev/null 2>&1; then
    echo "  Claude Code : $(claude --version 2>/dev/null || echo OK)"
else
    echo "  Claude Code : 未就绪（重开终端再看）"
fi
echo "  Python 3    : $(python3 --version 2>/dev/null || echo '未就绪')"
echo "  Git         : $(git --version 2>/dev/null || echo '未安装（可选）')"
echo ""
echo "  下一步："
echo "  1. 关掉终端、重新打开（让命令生效）"
echo "  2. 输入  claude  回车 → 浏览器登录你的官方订阅账号（需科学上网）"
echo "  3. 按作者教程安装「上品 Skill」即可开始上品"
echo ""
echo "  （可选）想用国产 AI 省钱？可自行装 cc-switch 切换供应商："
echo "    https://github.com/farion1231/cc-switch/releases"
echo "============================================"
echo ""
