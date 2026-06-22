# ============================================================
# Claude Code 一键卸载脚本 (Windows / PowerShell)
# ⚠️ 第 [3/3] 深度清理会卸 Node/Git/Python 等通用工具，
#    只应在【Windows 沙盒 / 虚拟机 / 临时账户】里用来录教程，别在主力机跑。
# 用法: irm https://raw.githubusercontent.com/Frio99/claude-install/main/uninstall.ps1 | iex
# ============================================================

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  Claude Code 一键卸载 (Windows)" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# 放行脚本运行，避免 npm.ps1 的执行策略限制(仅当前进程)
try { Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force -ErrorAction Stop } catch {}

# ---------- [1/3] 卸载 Claude Code 程序（原生 + npm 都处理）----------
Write-Host "[1/3] 卸载 Claude Code 程序..."
$removed = $false

# (a) npm 全局包
try {
    npm.cmd uninstall -g @anthropic-ai/claude-code 2>$null
    Write-Host "  [OK] 已尝试卸载 npm 版 @anthropic-ai/claude-code" -ForegroundColor Green
    $removed = $true
} catch {}

# (b) 原生安装器装的二进制（位于用户目录下的）
$claudeCmd = Get-Command claude -ErrorAction SilentlyContinue
if ($claudeCmd) {
    $p = $claudeCmd.Source
    if ($p -and $p.StartsWith($env:USERPROFILE)) {
        try {
            Remove-Item -Force $p -ErrorAction SilentlyContinue
            Remove-Item -Recurse -Force "$env:USERPROFILE\.claude\bin" -ErrorAction SilentlyContinue
            Write-Host "  [OK] 已删除原生安装的 claude ($p)" -ForegroundColor Green
            $removed = $true
        } catch {}
    } else {
        Write-Host "  (claude 位于 $p，未自动删除，避免误伤)" -ForegroundColor Yellow
    }
}
if (-not $removed) { Write-Host "  (未检测到已安装的 Claude Code，跳过)" -ForegroundColor Yellow }

# ---------- [2/3] 是否清除配置 + 登录信息 ----------
Write-Host ""
Write-Host "[2/3] 是否同时删除「配置 + 登录信息」(完全重置，适合重新录教程)?"
Write-Host "      将删除: $env:USERPROFILE\.claude 目录、$env:USERPROFILE\.claude.json"
$ans = Read-Host "      删除请输入 y，保留请直接回车"
if ($ans -eq 'y' -or $ans -eq 'Y') {
    Remove-Item -Recurse -Force "$env:USERPROFILE\.claude" -ErrorAction SilentlyContinue
    Remove-Item -Force "$env:USERPROFILE\.claude.json" -ErrorAction SilentlyContinue
    Write-Host "  [OK] 已清除配置和登录信息" -ForegroundColor Green
} else {
    Write-Host "  已保留配置和登录信息"
}

# ---------- [3/3] 深度清理：连 Node.js / Git / Python 一起卸载 ----------
Write-Host ""
Write-Host "[3/3] 深度清理：连 Node.js / Git / Python 一起卸载?(只为在沙盒里从零演示)" -ForegroundColor Yellow
Write-Host "      警告: 这些是通用工具，其它依赖它们的程序会一起坏掉！" -ForegroundColor Red
Write-Host "      务必只在【Windows 沙盒 / 虚拟机 / 临时账户】里执行，别在主力机跑！" -ForegroundColor Red
$ans2 = Read-Host "      确认全部卸载请完整输入 yes，否则直接回车跳过"
if ($ans2 -eq 'yes') {
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        Write-Host "  卸载 Node.js..."
        winget uninstall -e --id OpenJS.NodeJS.LTS --accept-source-agreements 2>$null
        winget uninstall -e --id OpenJS.NodeJS     --accept-source-agreements 2>$null
        Write-Host "  卸载 Git for Windows..."
        winget uninstall -e --id Git.Git           --accept-source-agreements 2>$null
        Write-Host "  卸载 Python..."
        winget uninstall -e --id Python.Python.3.12 --accept-source-agreements 2>$null
        Write-Host "  [OK] 已尝试卸载 Node.js / Git / Python(提示未找到=本就不是 winget 装的)" -ForegroundColor Green
    } else {
        Write-Host "  [X] 未找到 winget，请到「设置 -> 应用」里手动卸载 Node.js / Git / Python" -ForegroundColor Red
    }
} else {
    Write-Host "  已保留 Node.js / Git / Python"
}

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  卸载完成" -ForegroundColor Cyan
Write-Host ""
Write-Host "  想重新安装:"
Write-Host "  irm https://raw.githubusercontent.com/Frio99/claude-install/main/install.ps1 | iex"
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
