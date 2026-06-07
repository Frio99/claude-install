# ============================================================
# Claude Code 一键卸载脚本 (Windows / PowerShell)
# 用法: irm https://raw.githubusercontent.com/Frio99/claude-install/main/uninstall.ps1 | iex
# ============================================================

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  Claude Code 一键卸载 (Windows)" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# 放行脚本运行,避免 npm.ps1 的执行策略限制(仅当前进程)
try { Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force -ErrorAction Stop } catch {}

# ---------- [1/3] 卸载 Claude Code 程序 ----------
Write-Host "[1/3] 卸载 Claude Code 程序..."
try {
    npm.cmd uninstall -g @anthropic-ai/claude-code
    Write-Host "  [OK] 已卸载 @anthropic-ai/claude-code" -ForegroundColor Green
} catch {
    Write-Host "  (卸载时出现问题或未安装,已跳过)" -ForegroundColor Yellow
}

# ---------- [2/3] 是否清除配置 + 登录信息 ----------
Write-Host ""
Write-Host "[2/3] 是否同时删除「配置 + 登录信息」(完全重置,适合重新录教程)?"
Write-Host "      将删除: $env:USERPROFILE\.claude 目录、$env:USERPROFILE\.claude.json"
$ans = Read-Host "      删除请输入 y,保留请直接回车"
if ($ans -eq 'y' -or $ans -eq 'Y') {
    Remove-Item -Recurse -Force "$env:USERPROFILE\.claude" -ErrorAction SilentlyContinue
    Remove-Item -Force "$env:USERPROFILE\.claude.json" -ErrorAction SilentlyContinue
    Write-Host "  [OK] 已清除配置和登录信息" -ForegroundColor Green
} else {
    Write-Host "  已保留配置和登录信息"
}

# ---------- [3/3] 深度清理:连 Node.js / Git 一起卸载 ----------
Write-Host ""
Write-Host "[3/3] 深度清理:是否连 Node.js 和 Git 一起卸载?(适合录教程从零演示安装)" -ForegroundColor Yellow
Write-Host "      警告: Node.js / Git 是通用开发工具,其它依赖它们的程序会受影响!" -ForegroundColor Red
$ans2 = Read-Host "      确认全部卸载请输入 yes(必须完整输入 yes),否则直接回车跳过"
if ($ans2 -eq 'yes') {
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        Write-Host "  卸载 Node.js..."
        winget uninstall -e --id OpenJS.NodeJS.LTS --accept-source-agreements 2>$null
        winget uninstall -e --id OpenJS.NodeJS     --accept-source-agreements 2>$null
        Write-Host "  卸载 Git for Windows..."
        winget uninstall -e --id Git.Git           --accept-source-agreements 2>$null
        Write-Host "  [OK] 已尝试卸载 Node.js 和 Git(若提示未找到,说明本就不是用 winget 装的)" -ForegroundColor Green
    } else {
        Write-Host "  [X] 未找到 winget,无法自动卸载。请到「设置 -> 应用」里手动卸载 Node.js / Git" -ForegroundColor Red
    }
} else {
    Write-Host "  已保留 Node.js 和 Git"
}

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  卸载完成" -ForegroundColor Cyan
Write-Host ""
Write-Host "  想重新安装:"
Write-Host "  irm https://raw.githubusercontent.com/Frio99/claude-install/main/install.ps1 | iex"
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
