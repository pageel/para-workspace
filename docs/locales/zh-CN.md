<div align="center">

<img src="../assets/logo.svg" width="120" alt="PARA Workspace Logo">

# PARA Workspace

**人类与 AI Agent 的工作空间框架**

[![License](https://img.shields.io/badge/license-MIT-green.svg)](https://opensource.org/licenses/MIT)
[![Version](https://img.shields.io/badge/version-1.7.6-blue.svg)](../../CHANGELOG.md)
![Type](https://img.shields.io/badge/type-workspace_framework-blueviolet.svg)
[![Antigravity](https://img.shields.io/badge/Antigravity-verified-E37400?logo=google&logoColor=white)](https://antigravity.google/)

<a href="../../README.md"><b>🇺🇸 English</b></a> •
    <a href="./vi-VN.md"><b>🇻🇳 Tiếng Việt</b></a> •
    <a href="./zh-CN.md"><b>🇨🇳 中文</b></a> •
    <a href="./es-ES.md"><b>🇪🇸 Español</b></a> •
    <a href="./fr-FR.md"><b>🇫🇷 Français</b></a>

</div>

---

> 🚧 **翻译进行中** — 本文件目前为占位符。欢迎贡献中文翻译！
>
> 在此期间，请参阅 [English README](../../README.md) 获取完整文档。

## 🌌 概述

**PARA Workspace** 是一个开源工作空间框架，定义了人类和 AI Agent 如何组织知识并协作完成项目。系统以 **代码仓库** 的形式分发，包含内核（宪法）、CLI 工具和模板 — 由此生成您实际工作的 **工作空间**。

### 三大基础原则

1. **Repo ≠ Workspace** — 仓库只包含治理内容（内核、CLI、模板），不包含用户数据。
2. **Workspace = Runtime** — 由 `para init` 生成，每个工作空间是独立的运行实例。
3. **Kernel = 宪法** — 所有工作空间必须遵循的不变规则。

```mermaid
flowchart TD
    R["🏛️ Repo\n(宪法 + 编译器)"]
    W["💻 Workspace\n(操作系统 Runtime)"]
    A["🤖 Agent\n(执行环境)"]
    R -->|para init| W
    W -->|agent attach| A

    style R fill:#4a90d9,stroke:#2c5f8a,color:#fff
    style W fill:#50c878,stroke:#2e8b57,color:#fff
    style A fill:#ff8c42,stroke:#cc6633,color:#fff
```

## 📥 安装

```bash
# 克隆仓库
mkdir -p Resources/references
git clone https://github.com/pageel/para-workspace.git Resources/references/para-workspace

# 设置可执行权限
chmod +x Resources/references/para-workspace/cli/para
chmod +x Resources/references/para-workspace/cli/commands/*.sh

# 初始化工作空间
./Resources/references/para-workspace/cli/para init --profile=dev --lang=en
```

## 🤝 贡献

欢迎贡献完整的中文翻译！请参阅 [CONTRIBUTING.md](../../CONTRIBUTING.md) 了解指南。

---

用 ❤️ 构建，由 **Pageel** 出品。标准化 Agent PKM 的未来。

_版本: 1.7.6_
