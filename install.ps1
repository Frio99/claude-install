# ============================================================
# Claude Code 一键安装 (Windows / PowerShell)
# 一次装齐运行环境：
#   1. Claude Code   —— 主程序（官方原生安装器，无需 Node）
#   2. Python 3      —— 跑「上品 Skill」需要
#   3. Git for Windows —— Claude Code 在 Windows 上要 bash
# 检测先行 · 缺什么装什么 · 可重复运行（幂等）
# 需网络能访问 claude.ai / api.anthropic.com（中国大陆需配合网络代理工具并开全局）
# 用法: irm https://raw.githubusercontent.com/Frio99/claude-install/main/install.ps1 | iex
# ============================================================
#
# 整个脚本包在函数里，中途要停就 return，绝不 exit
# —— 避免 irm|iex 模式下 exit 把用户的 PowerShell 窗口直接关掉。

function Invoke-ClaudeInstall {

    Write-Host ""
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host "  Claude Code 一键安装 (Windows)" -ForegroundColor Cyan
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host ""

    # 装完依赖后，从注册表重新加载 PATH，让新装的工具在当前窗口立刻可用
    function Update-PathFromRegistry {
        $machine = [System.Environment]::GetEnvironmentVariable("Path", "Machine")
        $user    = [System.Environment]::GetEnvironmentVariable("Path", "User")
        $env:Path = "$machine;$user"
    }

    # ---------- [0] 解开 PowerShell 脚本运行限制 ----------
    # Windows 默认禁止运行 .ps1，而 npm / claude 都是 .ps1，不处理会报"禁止运行脚本"。
    try { Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force -ErrorAction Stop } catch {}
    $curPolicy = Get-ExecutionPolicy -Scope CurrentUser
    if ($curPolicy -eq 'Restricted' -or $curPolicy -eq 'AllSigned' -or $curPolicy -eq 'Undefined') {
        try {
            Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned -Force -ErrorAction Stop
            Write-Host "  [i] 已把脚本运行权限设为 RemoteSigned(安全标准)，以后才能正常使用 claude" -ForegroundColor Yellow
        } catch {}
    }

    # ---------- 安装前：提醒关防护 + 检测网络连通性 ----------
    Write-Host "────────────────────────────────────────────────────" -ForegroundColor Yellow
    Write-Host "  安装前请先做两件事，否则极易被拦截、装不上：" -ForegroundColor Yellow
    Write-Host "────────────────────────────────────────────────────" -ForegroundColor Yellow
    Write-Host "  1. 关闭杀毒 / 安全软件及其后台防护"
    Write-Host "     (360 安全卫士 / 腾讯电脑管家 / 火绒 等，会拦脚本和装程序)"
    Write-Host "  2. 临时关闭 Windows 防火墙 / Defender 实时保护"
    Write-Host ""
    Write-Host "  正在检测网络连通性..."
    $netOk = $false
    try { Invoke-WebRequest "https://claude.ai/" -UseBasicParsing -TimeoutSec 10 | Out-Null; $netOk = $true } catch {}
    if ($netOk) {
        Write-Host "  [OK] 网络连通(能访问 Claude 服务器)" -ForegroundColor Green
    } else {
        Write-Host ""
        Write-Host "  [X] 连不上 Claude 服务器(claude.ai)！无法继续安装。" -ForegroundColor Red
        Write-Host "      请按下面做，然后【重新运行本命令】：" -ForegroundColor Red
        Write-Host "        1) 开启你的网络代理 / 加速工具"
        Write-Host "        2) 切换到「全局 / Global」模式"
        Write-Host "           (只开规则 / PAC 模式往往不够，需要全局代理)"
        return
    }
    Write-Host ""
    Read-Host "  确认已关好杀毒软件和防火墙了吗？按回车继续(或关掉窗口退出)" | Out-Null
    Write-Host ""

    # ---------- [1/4] 环境检测 ----------
    Write-Host "[1/4] 检测环境..."
    Write-Host "  系统: Windows   架构: $env:PROCESSOR_ARCHITECTURE"
    $hasWinget = [bool](Get-Command winget -ErrorAction SilentlyContinue)
    if (-not $hasWinget) {
        Write-Host "  [!] 没找到 winget（Windows 应用安装器）。" -ForegroundColor Yellow
        Write-Host "      请到 Microsoft Store 搜「应用安装程序 / App Installer」装一下，再重跑本命令。" -ForegroundColor Yellow
    }

    # ---------- [2/4] Python 3（上品 Skill 的运行时）----------
    Write-Host ""
    Write-Host "[2/4] 检测 Python 3 (运行上品 Skill 需要)..."
    $pyOk = $false
    $pyCmd = Get-Command python -ErrorAction SilentlyContinue
    if ($pyCmd) {
        try {
            $pv = (& python -c "import sys;print('%d.%d'%sys.version_info[:2])" 2>$null)
            $parts = $pv.Split('.')
            if ([int]$parts[0] -ge 3 -and [int]$parts[1] -ge 8) {
                Write-Host "  [OK] Python $pv 符合要求" -ForegroundColor Green
                $pyOk = $true
            } else {
                Write-Host "  [!] Python $pv 偏旧 (建议 >= 3.8)" -ForegroundColor Yellow
            }
        } catch {}
    } else {
        Write-Host "  未检测到 Python 3"
    }
    if (-not $pyOk) {
        if ($hasWinget) {
            Write-Host "  用 winget 安装 Python 3..."
            winget install -e --id Python.Python.3.12 --accept-source-agreements --accept-package-agreements
            Update-PathFromRegistry
            if (Get-Command python -ErrorAction SilentlyContinue) {
                Write-Host "  [OK] Python 安装完成: $(python --version)" -ForegroundColor Green
            } else {
                Write-Host "  [!] Python 已安装，但当前窗口暂时认不到。请关掉 PowerShell 重开，再跑一次本命令。" -ForegroundColor Yellow
                return
            }
        } else {
            Write-Host "  [X] 无 winget，请到 https://www.python.org/downloads/ 手动装 Python 3 后重试。" -ForegroundColor Red
            return
        }
    }

    # ---------- [2.5/4] Git for Windows（Claude Code 运行依赖 bash）----------
    Write-Host ""
    Write-Host "[2.5/4] 检测 Git for Windows (Claude Code 运行需要)..."
    if (Get-Command git -ErrorAction SilentlyContinue) {
        Write-Host "  [OK] 已安装 Git ($(git --version))" -ForegroundColor Green
    } else {
        Write-Host "  未检测到 Git for Windows"
        if ($hasWinget) {
            Write-Host "  用 winget 安装 Git for Windows..."
            winget install -e --id Git.Git --accept-source-agreements --accept-package-agreements
            Update-PathFromRegistry
            if (Get-Command git -ErrorAction SilentlyContinue) {
                Write-Host "  [OK] Git 安装完成: $(git --version)" -ForegroundColor Green
            } else {
                Write-Host "  [!] Git 已安装，但当前窗口暂时认不到。请关掉 PowerShell 重开，再跑一次本命令。" -ForegroundColor Yellow
                return
            }
        } else {
            Write-Host "  [X] 无 winget，请到 https://git-scm.com/downloads/win 手动安装 Git for Windows。" -ForegroundColor Red
            return
        }
    }

    # ---------- [3/4] Claude Code（官方原生安装器优先，npm 兜底）----------
    Write-Host ""
    Write-Host "[3/4] 安装 Claude Code..."
    if (Get-Command claude -ErrorAction SilentlyContinue) {
        Write-Host "  [OK] 已安装: $(claude --version)" -ForegroundColor Green
    } else {
        Write-Host "  用官方原生安装器安装（自包含，无需 Node）..."
        try { irm https://claude.ai/install.ps1 | iex } catch {
            Write-Host "  原生安装器未成功：$($_.Exception.Message)" -ForegroundColor Yellow
        }
        Update-PathFromRegistry

        if (-not (Get-Command claude -ErrorAction SilentlyContinue)) {
            Write-Host "  改用备用方式（经 Node / npm）..." -ForegroundColor Yellow
            if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
                if ($hasWinget) {
                    Write-Host "  用 winget 安装 Node.js LTS..."
                    winget install -e --id OpenJS.NodeJS.LTS --accept-source-agreements --accept-package-agreements
                    Update-PathFromRegistry
                } else {
                    Write-Host "  [X] 无 winget 也无 Node，请到 https://nodejs.org 装 >=18 后重试。" -ForegroundColor Red
                }
            }
            if (Get-Command npm -ErrorAction SilentlyContinue) {
                $mirror = ""
                try { Invoke-WebRequest "https://registry.npmjs.org/" -UseBasicParsing -TimeoutSec 5 | Out-Null }
                catch { $mirror = "--registry=https://registry.npmmirror.com" }
                npm.cmd install -g @anthropic-ai/claude-code@latest $mirror
                Update-PathFromRegistry
            }
        }

        if (Get-Command claude -ErrorAction SilentlyContinue) {
            Write-Host "  [OK] 安装成功: $(claude --version)" -ForegroundColor Green
        } else {
            Write-Host "  [!] 已尝试安装，但当前窗口找不到 claude -> 请关掉 PowerShell 重新打开。" -ForegroundColor Yellow
        }
    }

    # ---------- [4/4] 结果 ----------
    Write-Host ""
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host "  安装结果" -ForegroundColor Cyan
    Write-Host "============================================" -ForegroundColor Cyan
    if (Get-Command claude -ErrorAction SilentlyContinue) { Write-Host "  Claude Code : $(claude --version)" }
    else { Write-Host "  Claude Code : 未就绪（重开 PowerShell 再看）" -ForegroundColor Yellow }
    if (Get-Command python -ErrorAction SilentlyContinue) { Write-Host "  Python 3    : $(python --version)" }
    if (Get-Command git -ErrorAction SilentlyContinue) { Write-Host "  Git         : $(git --version)" }
    Write-Host ""
    Write-Host "  下一步：" -ForegroundColor Cyan
    Write-Host "  1. 关掉 PowerShell、重新打开（让命令生效）"
    Write-Host "  2. 输入  claude  回车 -> 浏览器登录你的官方订阅账号（需网络可访问海外服务）"
    Write-Host "  3. 按作者教程安装「上品 Skill」即可开始上品"
    Write-Host ""
    Write-Host "  （可选）想用国产 AI 省钱？可自行装 cc-switch:" -ForegroundColor DarkGray
    Write-Host "    https://github.com/farion1231/cc-switch/releases" -ForegroundColor DarkGray
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host ""
}

# 调用主函数(用 return 收尾，绝不 exit，避免关掉用户的 PowerShell 窗口)
Invoke-ClaudeInstall
