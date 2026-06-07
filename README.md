# claude-install

Claude Code 官方一键安装脚本（macOS / Windows / Linux）。

**全透明 · 只装官方包 `@anthropic-ai/claude-code` · 不动你的全局 npm 配置 · 不碰任何第三方中转。**

---

## 一键安装

### macOS / Linux

```bash
curl -fsSL https://raw.githubusercontent.com/Frio99/claude-install/main/install.sh | bash
```

### Windows (PowerShell)

```powershell
irm https://raw.githubusercontent.com/Frio99/claude-install/main/install.ps1 | iex
```

装完后，终端输入 `claude` 回车，浏览器登录你的 **官方订阅账号** 即可使用。

---

## 脚本做了什么

1. **检测环境**：操作系统、CPU 架构、Node.js 版本。
2. **检测外网**：探测能否直连官方 npm 源。
   - 能直连 → 用官方 registry（拿最新版）。
   - 连不上/慢 → **本次安装**改用国内镜像 `npmmirror.com`（用 `--registry` 参数，**只作用于这次安装，不修改你的全局 npm 配置**）。
3. **装 Node.js**（如缺失，>=18）：Mac 用 Homebrew，Linux 用 apt/dnf/pacman，Windows 用 winget。
4. **安装 Claude Code**：官方包 `@anthropic-ai/claude-code@latest`。
5. **验证**并打印下一步指引。

## 关于 cc-switch（可选）

脚本**不会**自动安装 cc-switch。如果你之后想切换到第三方 / 国产模型省钱，安装完成后会有提示和链接，可自行安装：

- Mac 一键：`brew install --cask cc-switch`
- 下载页：https://github.com/farion1231/cc-switch/releases
- 官网：https://ccswitch.io

## 设计原则

- ✅ 全部为可读脚本，无闭源二进制、无混淆。
- ✅ 只安装 Anthropic 官方 npm 包。
- ✅ 不收集、不上传任何信息；不处理 API Key（登录走官方浏览器流程）。
- ✅ 镜像仅在本次安装临时使用，不永久修改全局 npm registry。
