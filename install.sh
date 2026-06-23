#!/bin/bash
# ============================================================
# Claude Code 一键安装 (macOS / Linux)
# 一次装齐三样运行环境：
#   1. Claude Code   —— 主程序（官方原生安装器，无需 Node）
#   2. Python 3      —— 跑「上品 Skill」需要
#   3. Git           —— 常用工具，部分功能需要
# 检测先行 · 每个组件「装→复检→没成可重试」· 可重复运行（幂等）
# 需网络能访问 claude.ai / api.anthropic.com（中国大陆需配合网络代理工具并开全局）
# 用法: curl -fsSL https://raw.githubusercontent.com/Frio99/claude-install/main/install.sh | bash
# ============================================================
# 不用 set -e：要在某步失败时走兜底/重试，而不是整个脚本中断。

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

# 通用：装 → 复检 → 没成停下让用户解决后按回车重试（最多 3 次）
# 专门应对：弹窗点了「取消」、权限没给、被杀毒拦了 等情况
# 用法: retry_install "名字" '检查命令(返回0=已装好)' 安装函数名
retry_install() {
    local name="$1" check="$2" installer="$3" i
    for i in 1 2 3; do
        if eval "$check" >/dev/null 2>&1; then return 0; fi
        echo "  正在安装 $name (第 $i/3 次)..."
        "$installer"
        add_local_bins
        if eval "$check" >/dev/null 2>&1; then echo "  ✅ $name 安装成功"; return 0; fi
        if [ "$i" -lt 3 ]; then
            echo "  ⚠️  $name 还没装上。常见原因：弹窗点了「取消」/ 权限没给 / 被杀毒拦了。"
            printf "      解决后按回车重试，或 Ctrl+C 退出: "
            [ -e /dev/tty ] && read -r _ </dev/tty
        fi
    done
    eval "$check" >/dev/null 2>&1
}

# 各组件的安装动作
install_python() {
    case "$PKG" in
        apt)    sudo apt-get update -qq; sudo apt-get install -y python3 python3-venv python3-pip ;;
        dnf)    sudo dnf install -y python3 python3-pip ;;
        pacman) sudo pacman -S --noconfirm python python-pip ;;
        brew)   brew install python ;;
        *)      [ "$OS" = "Darwin" ] && need_clt_then_exit ;;
    esac
}
install_git() {
    case "$PKG" in
        apt)    sudo apt-get install -y git ;;
        dnf)    sudo dnf install -y git ;;
        pacman) sudo pacman -S --noconfirm git ;;
        brew)   brew install git ;;
        *)      [ "$OS" = "Darwin" ] && need_clt_then_exit ;;
    esac
}
install_claude() {
    echo "  用官方原生安装器安装（自包含，无需 Node）..."
    curl -fsSL https://claude.ai/install.sh | bash || true
    add_local_bins
    ensure_local_bin_on_path
    command -v claude >/dev/null 2>&1 && return 0
    echo "  原生安装器未成功，改用备用方式（经 Node / npm）..."
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
        local MIRROR=""
        curl -fsS --max-time 5 https://registry.npmjs.org/ -o /dev/null 2>/dev/null \
            || MIRROR="--registry=https://registry.npmmirror.com"
        npm install -g @anthropic-ai/claude-code@latest $MIRROR
        add_local_bins
    fi
}

# ---------- 安装前：提醒关防护 + 检测网络连通性 ----------
echo "────────────────────────────────────────────────────"
echo "  ⚠️  安装前请先做两件事，否则极易被拦截、装不上："
echo "────────────────────────────────────────────────────"
echo "  1. 关闭杀毒 / 安全软件及其后台防护"
echo "     （360 安全卫士 / 腾讯电脑管家 / 火绒 等，会拦脚本和装程序）"
echo "  2. 临时关闭系统防火墙"
echo ""
echo "  正在检测网络连通性..."
if curl -fsS --max-time 10 -o /dev/null https://claude.ai/install.sh 2>/dev/null; then
    echo "  ✅ 网络连通（能访问 Claude 安装服务器）"
else
    echo "  ⚠️  没探测到 Claude 安装服务器（可能没开网络代理，也可能是检测误判）。"
    echo "     · 若你确认网络代理已开 / 能访问 claude.ai → 直接继续即可"
    echo "     · 否则请开启代理并切「全局 / Global」模式后再装"
    echo "       （只开规则 / PAC 模式往往不够，需要全局代理）"
fi
echo ""
printf "  确认已关好杀毒/防火墙、网络代理已就绪？按回车继续，或 Ctrl+C 退出: "
if [ -e /dev/tty ]; then read -r _ </dev/tty; fi
echo ""

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
PY_CHECK='python3 -c "import sys;exit(0 if sys.version_info[:2]>=(3,8) else 1)"'
if eval "$PY_CHECK" >/dev/null 2>&1; then
    echo "  ✅ Python $(python3 -c 'import sys;print("%d.%d"%sys.version_info[:2])') 符合要求"
else
    retry_install "Python 3" "$PY_CHECK" install_python
    eval "$PY_CHECK" >/dev/null 2>&1 \
        || echo "  ❌ Python 3 仍未就绪，请到 https://www.python.org/downloads/ 手动安装后重试。"
fi

# ---------- [3/4] Git ----------
echo ""
echo "[3/4] 检测 Git..."
if command -v git >/dev/null 2>&1; then
    echo "  ✅ 已安装: $(git --version)"
else
    retry_install "Git" "command -v git" install_git
    command -v git >/dev/null 2>&1 || echo "  △ Git 暂未装上（非必需，可日后再装）"
fi

# ---------- [4/4] Claude Code（官方原生安装器优先，npm 兜底，可重试）----------
echo ""
echo "[4/4] 安装 Claude Code..."
if command -v claude >/dev/null 2>&1; then
    echo "  ✅ 已安装: $(claude --version 2>/dev/null)"
else
    retry_install "Claude Code" "command -v claude" install_claude
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
echo "  2. 输入  claude  回车 → 浏览器登录你的官方订阅账号（需网络可访问海外服务）"
echo "  3. 按作者教程安装「上品 Skill」即可开始上品"
echo ""
echo "  （可选）想用国产 AI 省钱？可自行装 cc-switch 切换供应商："
echo "    https://github.com/farion1231/cc-switch/releases"
echo "============================================"
echo ""
