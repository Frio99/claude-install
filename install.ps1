# ============================================================
# Claude Code 官方一键安装脚本 (Windows / PowerShell)
# 全透明 · 只装官方包 · 不动你的全局 npm 配置
# 用法: irm https://raw.githubusercontent.com/Frio99/claude-install/main/install.ps1 | iex
# ============================================================

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  Claude Code 官方一键安装 (Windows)" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# ---------- [0/4] 解开 PowerShell 脚本运行限制 ----------
# Windows 默认禁止运行 .ps1 脚本,而 npm / claude 在 Windows 上都是 .ps1,
# 不处理会报"在此系统上禁止运行脚本"。下面做两件事:
#   1) 本次进程临时放行(只影响当前窗口)
#   2) 把当前用户的策略设为 RemoteSigned(微软推荐的安全标准,以后才能正常输 claude)
try { Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force -ErrorAction Stop } catch {}
$curPolicy = Get-ExecutionPolicy -Scope CurrentUser
if ($curPolicy -eq 'Restricted' -or $curPolicy -eq 'AllSigned' -or $curPolicy -eq 'Undefined') {
    try {
        Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned -Force -ErrorAction Stop
        Write-Host "  [i] 已把脚本运行权限设为 RemoteSigned(安全标准),以后才能正常使用 claude" -ForegroundColor Yellow
    } catch {}
}

# ---------- [1/4] 检测环境 + 外网连通性 ----------
Write-Host "[1/4] 检测环境..."
Write-Host "  系统: Windows  架构: $env:PROCESSOR_ARCHITECTURE"

$mirror = ""   # 默认走官方源
Write-Host "  探测能否直连官方 npm 源..."
try {
    Invoke-WebRequest -Uri "https://registry.npmjs.org/" -UseBasicParsing -TimeoutSec 5 | Out-Null
    Write-Host "  [OK] 可直连官方源,使用官方 registry" -ForegroundColor Green
} catch {
    Write-Host "  [!] 直连失败 -> 本次安装改用国内镜像 (仅本次,不改全局配置)" -ForegroundColor Yellow
    $mirror = "--registry=https://registry.npmmirror.com"
}

# ---------- [2/4] 检测 / 安装 Node.js (>=18) ----------
Write-Host ""
Write-Host "[2/4] 检测 Node.js..."
$needNode = $true
if (Get-Command node -ErrorAction SilentlyContinue) {
    $ver = (node -v).TrimStart('v')
    $major = [int]($ver.Split('.')[0])
    if ($major -ge 18) {
        Write-Host "  [OK] Node.js v$ver 符合要求" -ForegroundColor Green
        $needNode = $false
    } else {
        Write-Host "  [!] Node.js v$ver 版本过低 (需 >=18)" -ForegroundColor Yellow
    }
} else {
    Write-Host "  未检测到 Node.js"
}

if ($needNode) {
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        Write-Host "  用 winget 安装 Node.js LTS..."
        winget install -e --id OpenJS.NodeJS.LTS
        Write-Host ""
        Write-Host "  [!] Node.js 刚装好,当前窗口还认不到它。" -ForegroundColor Yellow
        Write-Host "      请关掉本 PowerShell 窗口,重新打开后再运行一次本命令。" -ForegroundColor Yellow
        exit 0
    } else {
        Write-Host "  [X] 未找到 winget,请手动安装 Node.js >=18: https://nodejs.org" -ForegroundColor Red
        exit 1
    }
}

# ---------- [2.5/4] 检测 Git for Windows (Claude Code 运行依赖) ----------
# Claude Code 在 Windows 上需要 bash 环境,Git for Windows 自带 bash,装上即可。
Write-Host ""
Write-Host "[2.5/4] 检测 Git for Windows (Claude Code 运行需要)..."
if (Get-Command git -ErrorAction SilentlyContinue) {
    Write-Host "  [OK] 已安装 Git ($((git --version)))" -ForegroundColor Green
} else {
    Write-Host "  未检测到 Git for Windows"
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        Write-Host "  用 winget 安装 Git for Windows..."
        winget install -e --id Git.Git
        Write-Host ""
        Write-Host "  [!] Git 刚装好,当前窗口还认不到它。" -ForegroundColor Yellow
        Write-Host "      请关掉本 PowerShell 窗口,重新打开后再运行一次本命令。" -ForegroundColor Yellow
        exit 0
    } else {
        Write-Host "  [X] 未找到 winget,请手动安装 Git for Windows: https://git-scm.com/downloads/win" -ForegroundColor Red
        exit 1
    }
}

# ---------- [3/4] 安装 Claude Code (官方包) ----------
Write-Host ""
Write-Host "[3/4] 安装 Claude Code (官方包)..."
# 用 npm.cmd 而非 npm,避免触发 npm.ps1 的脚本运行限制
npm.cmd install -g @anthropic-ai/claude-code@latest $mirror

# ---------- [4/4] 验证 ----------
Write-Host ""
Write-Host "[4/4] 验证安装..."
if (Get-Command claude -ErrorAction SilentlyContinue) {
    Write-Host "  [OK] 安装成功: $(claude --version)" -ForegroundColor Green
} else {
    Write-Host "  [!] 已装好,但当前窗口找不到 claude 命令 -> 请重开 PowerShell" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  下一步" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  输入 claude 回车 -> 浏览器登录你的官方订阅账号"
Write-Host ""
Write-Host "  -- (可选) 想切第三方模型省钱? --"
Write-Host "  可自行安装 cc-switch (一键切换 API 供应商):"
Write-Host "    下载页: https://github.com/farion1231/cc-switch/releases"
Write-Host "    官网:   https://ccswitch.io"
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
