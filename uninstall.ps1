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

# ---------- [1/2] 卸载 Claude Code 程序 ----------
Write-Host "[1/2] 卸载 Claude Code 程序..."
try {
    npm.cmd uninstall -g @anthropic-ai/claude-code
    Write-Host "  [OK] 已卸载 @anthropic-ai/claude-code" -ForegroundColor Green
} catch {
    Write-Host "  (卸载时出现问题或未安装,已跳过)" -ForegroundColor Yellow
}

# ---------- [2/2] 是否清除配置 + 登录信息 ----------
Write-Host ""
Write-Host "[2/2] 是否同时删除「配置 + 登录信息」(完全重置,适合重新录教程)?"
Write-Host "      将删除: $env:USERPROFILE\.claude 目录、$env:USERPROFILE\.claude.json"
$ans = Read-Host "      删除请输入 y,保留请直接回车"
if ($ans -eq 'y' -or $ans -eq 'Y') {
    Remove-Item -Recurse -Force "$env:USERPROFILE\.claude" -ErrorAction SilentlyContinue
    Remove-Item -Force "$env:USERPROFILE\.claude.json" -ErrorAction SilentlyContinue
    Write-Host "  [OK] 已清除配置和登录信息" -ForegroundColor Green
} else {
    Write-Host "  已保留配置和登录信息"
}

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  卸载完成" -ForegroundColor Cyan
Write-Host "  注: Node.js / Git 等通用工具未删除(其他程序可能在用)"
Write-Host ""
Write-Host "  想重新安装:"
Write-Host "  irm https://raw.githubusercontent.com/Frio99/claude-install/main/install.ps1 | iex"
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
