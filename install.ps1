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

# ---------- [3/4] 安装 Claude Code (官方包) ----------
Write-Host ""
Write-Host "[3/4] 安装 Claude Code (官方包)..."
npm install -g @anthropic-ai/claude-code@latest $mirror

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
