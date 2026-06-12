<div align="center">

<img src="../assets/logo.svg" width="120" alt="PARA Workspace Logo">

# PARA Workspace

**人类与 AI Agent 的工作空间框架**

[![License](https://img.shields.io/badge/license-MIT-green.svg)](https://opensource.org/licenses/MIT)
[![Version](https://img.shields.io/badge/version-1.9.2-blue.svg)](../../CHANGELOG.md)
![Type](https://img.shields.io/badge/type-workspace_framework-blueviolet.svg)
[![Antigravity](https://img.shields.io/badge/Antigravity-verified-E37400?logo=google&logoColor=white)](https://antigravity.google/)

<a href="../../README.md"><b>🇺🇸 English</b></a> •
    <a href="./vi-VN.md"><b>🇻🇳 Tiếng Việt</b></a> •
    <a href="./zh-CN.md"><b>🇨🇳 中文</b></a> •
    <a href="./es-ES.md"><b>🇪🇸 Español</b></a> •
    <a href="./fr-FR.md"><b>🇫🇷 Français</b></a>

</div>

---

| 章节 | 说明 |
| :-- | :-- |
| [🌌 概述](#-概述) | 什么是 PARA Workspace，三大基础原则 |
| [📂 架构](#-架构) | 仓库结构 + 生成的工作空间结构 |
| [📥 安装](#-安装) | 先决条件、设置、配置文件、故障排除 |
| [🧠 内核](#-内核) | 不变原则、启发式规则、契约 |
| [🛠️ CLI 参考](#-cli-参考) | 所有 CLI 命令 |
| [📑 工作流目录](#-工作流目录) | 32 个受治理的工作流 |
| [🛡️ 规则目录](#-规则目录) | 14 条治理规则 |
| [🧩 技能目录](#-技能目录) | 21 个可复用技能 |
| [🔌 工具系统](#-工具系统-v180) | 安装外部 Agentic 插件 |
| [🧩 任务管理](#-任务管理混合-3-文件模型) | 混合 3-文件模型 |
| [🔄 升级](#-升级版本) | 自动更新 + 全新安装 |
| [🗺️ 路线图](#-路线图) | 版本历史 + 计划中的功能 |

## 🌌 概述

**PARA Workspace** 是一个开源工作空间框架，定义了人类和 AI Agent 如何组织知识并协作完成项目。它以 **代码仓库(repo)** 的形式分发，包含内核（宪法）、CLI 工具和模板 —— 并据此生成您实际进行工作的 **工作空间(workspace)**。内核强制执行各项不变原则和启发式规则，使每个工作空间都具有可预测性、可审计性且对 AI Agent 友好。

### 三大基础原则

1. **Repo ≠ Workspace（仓库 ≠ 工作空间）** — 仓库仅包含治理内容（内核、CLI、模板），不包含任何用户数据。
2. **Workspace = Runtime（工作空间 = 运行时）** — 由 `para init` 生成，每个工作空间是一个独立的实例，您与您的 Agent 在其中协同工作。
3. **Kernel = Constitution（内核 = 宪法）** — 所有工作空间必须遵循的不可变规则。对规则的更改需要通过 RFC 提案 + 升级版本号。

```mermaid
flowchart TD
    R["🏛️ Repo\n(宪法 + 编译器)"]
    W["💻 Workspace\n(操作系统 Runtime)"]
    A["🤖 Agent\n(环境执行)"]
    R -->|para init| W
    W -->|agent attach| A

    style R fill:#4a90d9,stroke:#2c5f8a,color:#fff
    style W fill:#50c878,stroke:#2e8b57,color:#fff
    style A fill:#ff8c42,stroke:#cc6633,color:#fff
```

---

## 📂 架构

### 仓库结构 (本仓库)

```
para-workspace/
├── .github/             # 🤖 CI/CD — validate-pr.yml, CODEOWNERS
├── rfcs/                # 📝 RFC 提案流程 — TEMPLATE.md
├── kernel/              # 🧠 宪法 (Constitution)
│   ├── KERNEL.md
│   ├── invariants.md    # 11条硬性规则 (修改需升 MAJOR 版)
│   ├── heuristics.md    # 10条软性约定
│   ├── schema/          # workspace, project, backlog 等的 JSON Schema
│   └── examples/        # 有效/无效的合规模板示例
├── cli/                 # 🔧 编译器 (Compiler)
│   ├── para             # 入口脚本 (兼容 Bash 3.2+)
│   ├── lib/             # 核心库 logger, validator, rollback 等
│   └── commands/        # init, scaffold, status, migrate, install 等命令
├── templates/           # 📦 脚手架与受治理库
│   ├── common/agents/   # 工作流, 规则, 技能 及 catalog.yml
│   │   └── projects/    # .project.yml 模板
│   └── profiles/        # dev, general 预设配置
├── tests/               # 🧪 kernel/ 与 cli/ 的集成测试
├── docs/                # 📖 文档
├── CONTRIBUTING.md
├── VERSIONING.md
├── CHANGELOG.md
└── VERSION
```

### 工作空间结构 (由 `para init` 生成)

```
<your-workspace>/
├── Projects/                          # 以目标为导向的任务
│   ├── my-app/                        # 标准项目 (type: standard)
│   │   ├── repo/                      #   源代码 (git 仓库)
│   │   ├── artifacts/                 #   计划, 任务, 决策记录
│   │   ├── sessions/                  #   会话日志
│   │   ├── docs/                      #   项目文档
│   │   └── project.md                 #   项目契约
│   └── my-ecosystem/                  # 生态系统项目 (type: ecosystem)
│       ├── artifacts/                 #   跨项目计划与待办事项
│       └── project.md                 #   satellites: [app, api, ...], 无 repo/
├── Areas/                             # 持续的责任领域 (如: 健康, 财务)
│   ├── Workspace/                     # 主会话日志、审计、SYNC 队列
│   └── Learning/                      # 共享知识库 (通过 /learn)
├── Resources/                         # 参考资料与工具
│   ├── ai-agents/                     # 内核快照与受治理库快照
│   └── references/                    # 原始 PARA 仓库 (只读)
├── Archive/                           # 已完成项目的冷存储
├── _inbox/                            # 外部下载的临时停靠区
├── .agents/                           # 受治理库的副本 (自动同步)
│   ├── rules.md                       # 规则触发索引表
│   ├── skills.md                      # 技能触发索引表
│   ├── rules/                         # 活跃的 agent 规则
│   ├── skills/                        # 活跃的 agent 技能
│   └── workflows/                     # 活跃的 agent 工作流
├── .para/                             # 系统状态 (请勿编辑)
│   ├── archive/                       # 智能归档库
│   ├── backups/                       # 日期标记的备份
│   └── audit.log                      # 操作历史审计
├── para                               # CLI 脚本程序
└── .para-workspace.yml                # 工作空间根元数据配置
```

---

## 📥 安装

### 先决条件

- **AI Agent 平台** (见下表)
- **Git** (克隆和更新所必需)
- **Bash** 3.2+ (Linux/macOS 原生支持, Windows 使用 Git Bash 或 WSL)

### 步骤 1: 克隆与安装

```bash
# 将仓库克隆到正确位置
mkdir -p Resources/references
git clone https://github.com/pageel/para-workspace.git Resources/references/para-workspace

# 赋予执行权限
chmod +x Resources/references/para-workspace/cli/para
chmod +x Resources/references/para-workspace/cli/commands/*.sh

# 使用预设配置初始化工作空间
./Resources/references/para-workspace/cli/para init --profile=dev --lang=en
```

### 步骤 2: 验证

```bash
./para status
# ✅ 如果看到健康报告，则说明安装成功
```

### 更新机制

```bash
# 从 GitHub 拉取最新代码并重新同步工作空间
./para update

# 在应用之前预览变更
./para update --dry-run
```

---

## 🧠 内核

内核是 PARA Workspace 的 **宪法** —— 所有工作空间必须遵守的规则。

### 不变原则 (Invariants)

11条硬性规则（修改需要 MAJOR 重大版本升级），例如 `I1` (强制目录结构), `I2` (混合 3 文件任务模型), `I10` (库与工作空间分离) 等。

### 启发式规则 (Heuristics)

10条软性约定（修改需要 MINOR/PATCH 升级），涵盖命名规范、上下文加载优先级、知识项（KI）管理等。

---

## 🛠️ CLI 参考

```bash
# 核心命令
para init [--profile] [--lang]  # 创建工作空间
para status [--json]            # 系统健康检查
para update                     # 自动更新与迁移
para scaffold <type> <name>     # 创建结构化路径
para install [--force]          # 同步受治理库
para archive <type> <name>      # 毕业审查与归档
para migrate [--from] [--to]    # 工作空间迁移

# Agent 管理
@[/para-workflow] list          # 管理工作流
@[/para-rule] list              # 管理规则

# 工具管理 (v1.8.0)
para install-tool <name>        # 从注册表安装插件
para remove-tool <name>         # 移除已安装的插件
para list-tools                 # 列出已安装的插件
```

---

## 📑 工作流目录

内置 32 个受治理核心工作流（例如 `/plan`, `/spec`, `/backlog`, `/open`, `/end`, `/para-knowledge`, `/para-skill`, `/write`, `/logs`, `/qa`, 以及新增的 `/staging`, `/vibecode`, `/scan-sec`, `/resource`）用于规范化 AI Agent 在项目内的操作流。

## 🛡️ 规则目录

包含 14 条治理规则，通过双层触发索引进行按需加载以节省 Token。包括 `governance` (核心), `vcs` (Git 安全), `knowledge` (KI 操作安全), `graph-first-policy` (图谱优先), `tool-routing` (工具路由) 及 `hybrid-3-file-integrity` 等。

## 🧩 技能目录

目前包含 21 个复用技能，按需加载并提供模板、模式和参考资料。

| 技能 | 说明 |
| :--- | :--- |
| **[PARA Kit](../skills/para-kit.md)** | PARA 工作空间结构参考 — 模式、布局、内核治理、智能路由 |
| **[Formatting](../skills/formatting.md)** | 表格、图表、树形列表、ASCII 字符艺术 |
| **[Page Map](../skills/page-map.md)** | 使用 PAGE_MAP.md 和 BLUEPRINT.md 管理网站视觉结构 |
| **[PARA Skill](../skills/para-skill.md)** | 通过 Co-Author 引擎创建、验证和测试 PARA 技能的治理技能 |
| **[Plan Templates](../skills/plan.md)** | 详细计划与路线图模板 (Sidecar, v1.7.8) |
| **[Docs Templates](../skills/docs.md)** | 架构、CLI、战略模板 (Sidecar, v1.7.8) |
| **[Brainstorm Templates](../skills/brainstorm.md)** | 决策与研究模板 (Sidecar, v1.7.12) |
| **[Write Templates](../skills/write.md)** | 内容格式和写作规则模板 (Sidecar, v1.7.14) |
| **[Harness Guards](../skills/harness.md)** | Guard 目录和自动扫描协议，用于生成上下文感知的安全警告 (Sidecar, v1.7.16) |
| **[Spec Templates](../skills/spec.md)** | 规范编写模板、假设梳理与边界定义 (Sidecar, v1.7.16) |
| **[QA Review Templates](../skills/qa.md)** | 红队角色、审计维度清单与 QA 报告模板 (Sidecar, v1.8.6) |
| **[TDD Guidelines](../skills/tdd.md)** | 严格测试驱动开发规范与 Red-Green-Refactor 周期 (v1.8.7) |
| **[Logs Audit Extensions](../skills/logs.md)** | TDD/Spec 规范审计的会话日志合规分析模板 (Sidecar, v1.8.7) |
| **[HTML Renderer](../skills/html-renderer.md)** | 静态文档和图表可视化的模块化 HTML 渲染引擎 (v1.8.9) |
| **[New Project](../skills/new-project.md)** | 用于新建项目 /new-project 的架构设计模式与本地规则配置组件 (Sidecar, v1.8.10) |
| **[para-graph](../skills/para-graph.md)** | 智能代码图谱路由与语义内存管理 (Sidecar, v1.8.10) |
| **[Staging Templates](../skills/staging.md)** | 用于 /staging 模板发布的自定义路径映射模板 (Sidecar, v1.8.11) |
| **[Vibecode Execution Templates](../skills/vibecode.md)** | 用于 /vibecode 编写的验证清单与执行模式预设 (Sidecar, v1.8.11) |
| **[Vulnerability Scanner Templates](../skills/scan-sec.md)** | 安全漏洞扫描规则、OWASP Top 10 映射与报告模板 (Sidecar, v1.8.11) |
| **[Resource Study Templates](../skills/resource.md)** | 用于 /resource 学习与设计模式提取的研究模板 (Sidecar, v1.8.11) |
| **[Sidecar Skill Governance](../skills/sidecar-skill.md)** | 辅助工作流的 Sidecar Skill 编写规范与架构标准 (v1.8.11) |

---

## 🏗️ 规则架构 — 双层加载与深度防御

PARA Workspace 采用 **渐进式披露 (Progressive Disclosure)** 架构，仅通过查阅 `rules.md` 和 `skills.md` 索引表（~200 token）来按需加载大型规则，能够为您节省约 90% 的 Context 代价。

系统具备 **4 层防御 (Defense-in-Depth)** 系统：
1. 规则索引表
2. 会话检查点
3. Step 0 请求前重新加载
4. 内联文件拦截 Guard `<!-- ⚠️ APPEND-ONLY -->`

---

## 🧩 任务管理 (混合 3-文件模型)

解决 AI "记忆衰退 (Amnesia)" 问题，将庞大的系统分摊至 3 个文件：
- `backlog.md` (战略总任务池)
- `sprint-current.md` (当前冲刺热通道，Agent 高频读写)
- `done.md` (只追加模式下的完成记录)

通过 `/end` 指令在每天（或每次会话）结束时进行状态压缩与同步清理。

---

## 📚 知识系统 (v1.7.0)

引入 Knowledge Items (KIs)，将经验通过 `/para-knowledge` 打包为不受制于 Session 生命周期和项目边界的跨空间共享知识块。与 Antigravity AI 平台原生集成以实现自动注入加载。

---

## 🔌 工具系统 (v1.8.0)

PARA Workspace 支持可扩展的 **动态工具系统**，允许您将与语言无关的外部插件（如 `para-graph`）直接安装到您的工作空间中。

工具通过中央注册表（`registry/tools.yml`）进行管理，并作为独立的压缩包进行安装。

### 工作原理
1. **零全局依赖**：工具本地安装到 `.para/tools/` 以实现隔离。
2. **多运行时支持**：CLI 自动生成包装脚本（例如 `repo/cli/commands/graph.sh`），它们知道如何调用 Node、Python 或二进制可执行文件。
3. **Dev/Prod 降级机制**：如果工作空间中存在工具的源代码（Dev 模式），包装器会将执行路由到那里。否则，它会降级到提取的压缩包（Prod 模式）。

### 可用工具

| 工具 | 版本 | 描述 |
| :--- | :--- | :--- |
| **[`para-graph`](https://github.com/pageel/para-graph)** | PARA Workspace 的混合代码知识图谱 |

### 用法

```bash
# 安装 para-graph 插件（结构化代码分析和 MCP 服务器）
./para install-tool para-graph

# 列出已安装的工具
./para list-tools

# 运行已安装的工具
./para graph --help

# 移除工具
./para remove-tool para-graph
```

### 工具智能安装器 (Tool Intelligence Installer, v1.8.1)

工具可以直接在其 `tool.manifest.yml` 中打包 AI 智能（工作流、技能、规则）：

```yaml
agents:
  workflows:
    - source: templates/agents/workflows/para-graph.md
      target: para-graph.md
      version: "1.8.0"
  skills:
    - source: templates/agents/skills/graph-enrichment/
      target: graph-enrichment/
      version: "1.0.0"
```

当您运行 `./para install-tool <name>` 时，CLI 会自动解析此清单并提示您安装捆绑的智能组件。
您可以使用 `--agents` 仅安装 Agent，或使用 `--no-agents` 跳过提示。
`remove-tool` 也将主动提示以清理它安装的任何捆绑 Agent 组件。

---

## 🔄 升级版本

支持 `./para update` 实现从上游源库提取最新架构，并在保留用户自定义（备份为 `.bak`）的前提下实施热更新。

---

## 🗺️ 路线图

当前版本为 **1.9.2** (支持 Vibecode DSP 动态会话计划 with templates standardization)。
未来规划包含 **v1.9.0** (Department 系统) 及 **v1.10.0** (社区与信任边界)。

---

## 🤝 贡献

请参阅 [CONTRIBUTING.md](../../CONTRIBUTING.md) 了解详细指南。所有针对内核原则的更改都需要通过 RFC 审核流程。

---

## 📄 许可证与参考引用

本科学/工程项目在 MIT 许可证下授权。

`/scan-sec` 安全审计模块（在 [scan-sec SKILL.md](../../templates/common/agents/skills/scan-sec/SKILL.md) 下管理）基于并参考了以下两个项目：
- [vbsec 仓库](https://github.com/tanviet12/vbsec)（核心执行架构）。
- [OWASP Top 10 项目](https://owasp.org/www-project-top-ten/)（安全标准与漏洞分类）。

### 第三方依赖库与工具

#### 核心 CLI 实用工具
- [jq](https://jqlang.github.io/jq/)（JSON 命令行解析器，配置更新所需）。
- [Git](https://git-scm.com/)（版本控制和工作区更新所需）。
- [Node.js](https://nodejs.org/)（代码图谱分析和 HTML 文档渲染器的运行环境）。

#### 前端 CDN 依赖库（用于 HTML 页面渲染）
- [marked](https://github.com/markedjs/marked)（Markdown 解析器）。
- [mermaid](https://github.com/mermaid-js/mermaid)（流程图与图表引擎）。
- [force-graph](https://github.com/vasturiano/force-graph)（用于代码图谱可视化的 2D 力导向图引擎）。
- [lucide](https://github.com/lucide-icons/lucide)（UI 图标库）。
- [Google Fonts](https://fonts.google.com/)（Inter, Outfit, Roboto, Fira Code 字体排版）。

---

用 ❤️ 构建，由 **Pageel** 出品。标准化 Agent PKM 的未来。

_版本: 1.9.2_
