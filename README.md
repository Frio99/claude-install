# claude-install

一行命令，帮你在电脑上装好 **Claude Code** 以及运行「上品 Skill」所需的环境。支持 Mac、Windows、Linux。

> **Claude Code 是什么？** 它是 Claude 官方的电脑端 AI 助手，能直接帮你读写文件、跑命令、改代码、处理各种活儿。装好后在终端里输入 `claude` 就能用。

> ⚠️ **需要能科学上网**：登录和使用 Claude Code 要访问 `claude.ai` / `api.anthropic.com`，在中国大陆需先连好梯子，否则登录不上、用不了。

---

## 它会帮你装哪些东西？

一条命令，自动装齐三样（已装的会自动跳过）：

| 工具 | 用途 |
|---|---|
| **Claude Code** | 主程序（用官方原生安装器，不依赖 Node） |
| **Python 3** | 跑「上品 Skill」需要 |
| **Git** | 常用工具；Windows 上 Claude Code 运行也需要它 |

---

## 怎么用？（复制一行，粘进去，回车）

不用懂技术，照下面做就行。先看你用的是什么电脑：

### 🍎 苹果电脑（Mac）

1. 打开「**终端**」App（在 应用程序 → 实用工具 里，或按 `Command + 空格` 搜「终端」）
2. 把下面这行**整段复制**，粘进终端，按回车：

```bash
curl -fsSL https://raw.githubusercontent.com/Frio99/claude-install/main/install.sh | bash
```

3. 全新 Mac 第一次跑，可能会弹出一个「安装命令行工具」的窗口 → 点「**安装**」→ 等它装完，再**把上面这行命令重新粘一次**即可。
4. 等它自己跑完（第一次可能要几分钟，在下载东西，正常）。

### 🪟 Windows 电脑

1. 点开始菜单，搜「**PowerShell**」，打开它
2. 把下面这行**整段复制**，粘进去，按回车：

```powershell
irm https://raw.githubusercontent.com/Frio99/claude-install/main/install.ps1 | iex
```

3. 如果它提示「已安装，请重开窗口再跑一次」，就**关掉 PowerShell、重新打开**，再粘一次同样的命令即可。

---

## 装完之后怎么开始用？

1. **关掉终端 / PowerShell，重新打开**（让新装的命令生效）
2. 输入 `claude`，按回车
3. 它会自动弹出浏览器，让你**登录**（确保此时梯子是连着的）
4. 用你的 **Claude 官方账号**（订阅了 Pro / Max 的那个）登录
5. 登录完，按作者教程安装「**上品 Skill**」，就能开始上品了 🎉

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

卸载分三档，按需选择（每一档都会单独问你）：

1. **卸载 Claude Code 程序**（默认执行，原生版 / npm 版都能卸）。
2. **删除配置 + 登录信息**：输入 `y` → 完全重置登录状态，适合重新录教程。
3. **深度清理（连 Node / Git / Python 一起卸）**：输入 `yes` → 把通用工具也卸掉，回到「白板机器」。

> 🛑 **第 3 档很危险**：会移除 Node / Git / Python 这些通用工具，**其它依赖它们的程序会一起坏掉**。
> **只应在「沙盒 / 虚拟机 / 临时用户账户」里用来录教程，绝对不要在你的主力电脑上跑。**
> 想要真正干净的「全新电脑」效果，推荐用 **Windows 沙盒**（Win 专业版内置，用完即焚）或一台**虚拟机**，而不是卸自己主机。

---

## 这个脚本到底帮你做了啥？（放心，它很老实）

一句话：**它只帮你把官方 Claude Code 和运行环境装上，不偷偷干别的。**

具体几步：
1. 看一眼你的电脑环境（什么系统、有没有装好 Python / Git）
2. 缺什么补什么（Python 3、Git）
3. 用**官方原生安装器**装 Claude Code（自包含，不依赖 Node）
4. 装完做个小自检，告诉你下一步怎么做

---

## 常见问题

**Q：要花钱吗？**
A：这个安装脚本免费。但用 Claude Code 需要你有 Claude 官方的订阅账号（登录时用），并且能科学上网。

**Q：安全吗？**
A：脚本是公开的、人人能看的（就在这个仓库里），不含任何密码或密钥，也不会上传你的任何信息。只装官方软件。

**Q：提示找不到 `claude` 命令？**
A：把终端 / PowerShell 关掉，重新打开，再输入 `claude` 就好了（新装的命令要重开窗口才生效）。

**Q：登录打不开 / 一直转圈 / 报网络错误？**
A：检查梯子是否连着。Claude 登录和运行都要访问 anthropic 的服务，中国大陆没梯子访问不了。

**Q：Windows 输入 `claude` 提示「requires Git for Windows」？**
A：Claude Code 在 Windows 上运行需要一个 bash 环境，装 **Git for Windows** 即可（脚本已会自动帮你装）。装完**关掉 PowerShell 重新打开**再试。

**Q：Windows 报错「在此系统上禁止运行脚本」？**
A：这是 Windows 默认安全锁。脚本已会自动解锁；若仍报错，手动跑一次：
```powershell
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
```

**Q：我想省钱，能不能用便宜点的国产 AI？**
A：可以，但要另外装一个叫 **cc-switch** 的小工具来切换，装完后按需自取：
- 下载页：https://github.com/farion1231/cc-switch/releases
- 官网：https://ccswitch.io

---

## 给懂技术的人看的说明

- 全部为可读 Shell / PowerShell 脚本，无闭源二进制、无代码混淆。
- **Claude Code 优先用官方原生安装器**（`claude.ai/install.sh` / `install.ps1`，自包含，无 Node 依赖）；原生失败时**兜底**走 Node + npm 包 `@anthropic-ai/claude-code`。
- 同时检测并安装 **Python 3**（≥3.8，上品 Skill 运行时）与 **Git**；Mac 全新机经 Xcode 命令行工具获取 python3/git，无需 Homebrew。
- npm 兜底路径会探测官方源连通性，连不上时**仅本次**用 `--registry` 走 `npmmirror.com`，不改全局配置。
- 不收集、不上传任何信息；不处理 API Key（登录走官方浏览器流程）。
- 卸载脚本可移除原生版与 npm 版，原生二进制仅在位于用户主目录时才删除（不碰系统路径）。
