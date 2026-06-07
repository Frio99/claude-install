# claude-install

一行命令，帮你在电脑上装好 **Claude Code**。支持 Mac、Windows、Linux。

> **Claude Code 是什么？** 它是 Claude 官方的电脑端 AI 助手，能直接帮你读写文件、跑命令、改代码、处理各种活儿。装好后在终端里输入 `claude` 就能用。

---

## 怎么用？（复制一行，粘进去，回车）

不用懂技术，照下面做就行。先看你用的是什么电脑：

### 🍎 苹果电脑（Mac）

1. 打开「**终端**」App（在 应用程序 → 实用工具 里，或按 `Command + 空格` 搜「终端」）
2. 把下面这行**整段复制**，粘进终端，按回车：

```bash
curl -fsSL https://raw.githubusercontent.com/Frio99/claude-install/main/install.sh | bash
```

3. 等它自己跑完（第一次可能要几分钟，在下载东西，正常）。

### 🪟 Windows 电脑

1. 点开始菜单，搜「**PowerShell**」，打开它
2. 把下面这行**整段复制**，粘进去，按回车：

```powershell
irm https://raw.githubusercontent.com/Frio99/claude-install/main/install.ps1 | iex
```

3. 如果它提示「装好了 Node，请重开窗口再跑一次」，就**关掉 PowerShell、重新打开**，再粘一次同样的命令即可。

---

## 不想要了？一键卸载

### 🍎 Mac / Linux
```bash
curl -fsSL https://raw.githubusercontent.com/Frio99/claude-install/main/uninstall.sh | bash
```

### 🪟 Windows (PowerShell)
```powershell
irm https://raw.githubusercontent.com/Frio99/claude-install/main/uninstall.ps1 | iex
```

卸载时会问你一句：
- **直接回车** → 只删除 Claude Code 程序，保留你的配置和登录。
- **输入 `y` 再回车** → 连配置和登录信息一起清空（**完全重置**，适合重新录教程 / 从头演示安装）。

> 卸载**不会**删除 Node.js、Git 等通用工具（别的程序可能在用）。

---

## 装完之后怎么开始用？

1. 在终端 / PowerShell 里输入 `claude`，按回车
2. 它会自动弹出浏览器，让你**登录**
3. 用你的 **Claude 官方账号**（订阅了 Pro / Max 的那个）登录
4. 登录完，回到终端就能开始跟它对话、让它干活了 🎉

---

## 这个脚本到底帮你做了啥？（放心，它很老实）

一句话：**它只帮你把官方的 Claude Code 装上，不偷偷干别的。**

具体四步：
1. 看一眼你的电脑环境（什么系统、有没有装好基础工具）
2. 缺基础工具就帮你补上
3. 从**官方**下载安装 Claude Code
4. 装完告诉你下一步怎么做

**如果你在国内、网络慢**：它会自动判断，下载慢的时候临时换成国内的下载点加速——而且**只在这一次安装时用一下，不会动你电脑里别的设置**。

---

## 常见问题

**Q：要花钱吗？**
A：这个安装脚本免费。但用 Claude Code 需要你有 Claude 官方的订阅账号（登录时用）。

**Q：安全吗？**
A：脚本是公开的、人人能看的（就在这个仓库里），不含任何密码或密钥，也不会上传你的任何信息。只装官方软件。

**Q：提示找不到 `claude` 命令？**
A：把终端 / PowerShell 关掉，重新打开，再输入 `claude` 就好了。

**Q：Windows 输入 `claude` 提示「requires Git for Windows or PowerShell」？**
A：Claude Code 在 Windows 上运行需要一个 bash 环境，装 **Git for Windows** 即可（它自带 bash）。最新版安装脚本已会自动帮你装；旧版本可手动安装：
```powershell
winget install -e --id Git.Git
```
或去 https://git-scm.com/downloads/win 下载安装。装完**关掉 PowerShell 重新打开**，再输入 `claude`。

**Q：Windows 报错「在此系统上禁止运行脚本 / npm.ps1 无法加载」？**
A：这是 Windows 默认的安全锁挡住了脚本。最新版安装脚本已会自动解锁；如果你用的是旧版本或仍报错，手动在 PowerShell 里跑一次下面这行（输入 `Y` 确认），再重新安装即可：
```powershell
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
```
这是微软推荐的安全标准设置，解开后才能正常使用 `claude`。

**Q：我想省钱，能不能不用官方、用便宜点的国产 AI？**
A：可以，但要另外装一个叫 **cc-switch** 的小工具来切换。装完 Claude Code 后，终端里会有提示和链接，按需自取：
- Mac 一键安装：`brew install --cask cc-switch`
- 下载页：https://github.com/farion1231/cc-switch/releases
- 官网：https://ccswitch.io

---

## 给懂技术的人看的说明

- 全部为可读 Shell / PowerShell 脚本，无闭源二进制、无代码混淆。
- 只安装 Anthropic 官方 npm 包 `@anthropic-ai/claude-code`。
- 会探测能否直连官方 npm 源；连不上时**仅本次**通过 `--registry` 参数走 `npmmirror.com` 镜像，**不修改全局 npm 配置**。
- 不收集、不上传任何信息；不处理 API Key（登录走官方浏览器流程）。
- cc-switch 不自动安装，仅在结尾打印提示与链接。
