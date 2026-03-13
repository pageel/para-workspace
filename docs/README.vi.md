# PARA Workspace

> **Chuẩn Workspace có Quản trị dành cho AI Agent**

<div align="center">

<img src="../.github/assets/banner.png" width="100%" alt="PARA Workspace Banner">

<br/>

[![PARA Version](https://img.shields.io/badge/PARA-v1.5.3-00CFE8.svg?style=for-the-badge&logo=gitbook&logoColor=white)](../CHANGELOG.md)
[![Agent Ready](https://img.shields.io/badge/Agent-Ready-2ECC71.svg?style=for-the-badge&logo=googlecloud&logoColor=white)](#-tích-hợp-agent)
[![License: MIT](https://img.shields.io/badge/License-MIT-F1C40F.svg?style=for-the-badge&logo=opensourceinitiative&logoColor=white)](https://opensource.org/licenses/MIT)

[🇺🇸 English](../README.md) • [🇻🇳 Tiếng Việt](./README.vi.md)

</div>

---

## 🌌 Tổng quan

**PARA Workspace** là một chuẩn mở có quản trị, định nghĩa cách con người và AI agent tổ chức tri thức và cộng tác trong dự án. Hệ thống được phân phối dưới dạng **repo** chứa kernel (hiến pháp), công cụ CLI, và templates — từ đó tạo ra các **workspace** nơi bạn thực sự làm việc. Kernel thực thi 10 invariants và 9 heuristics để mọi workspace đều nhất quán, kiểm soát được, và thân thiện với agent.

### Ba Nguyên tắc Nền tảng

1. **Repo ≠ Workspace** — Repo chỉ chứa nội dung quản trị (kernel, CLI, templates). Không bao giờ chứa dữ liệu người dùng.
2. **Workspace = Runtime** — Được tạo bởi `para init`, mỗi workspace là một instance độc lập nơi bạn và agent làm việc.
3. **Kernel = Hiến pháp** — Các quy tắc bất biến mà mọi workspace phải tuân theo. Thay đổi yêu cầu RFC + nâng version.

```
Repo      (Hiến pháp + Trình biên dịch)
  ↓ para init
Workspace (Hệ điều hành Runtime)
  ↓ agent attach
Agent     (Môi trường Thực thi)
```

---

## 📂 Kiến trúc

### Cấu trúc Repo (Repository này)

```
para-workspace/
├── .github/             # 🤖 CI/CD — validate-pr.yml, CODEOWNERS
├── rfcs/                # 📝 Quy trình RFC — TEMPLATE.md, status in header
├── kernel/              # 🧠 Hiến pháp
│   ├── KERNEL.md
│   ├── invariants.md    # 10 luật cứng (MAJOR bump)
│   ├── heuristics.md    # 9 quy ước mềm
│   ├── schema/          # workspace, project, backlog, catalog schemas
│   └── examples/        # Vector kiểm thử tuân thủ
├── cli/                 # 🔧 Trình biên dịch
│   ├── para             # Điểm vào (Tương thích Bash 3.2+)
│   ├── lib/             # logger.sh, validator.sh, rollback.sh, fs.sh
│   └── commands/        # init, scaffold, status, migrate, archive, install, update
├── templates/           # 📦 Khuôn mẫu & Thư viện Quản trị
│   ├── common/agent/    # Workflows/, rules/, skills/ tập trung + catalog.yml
│   │   └── projects/    # .project.yml template
│   └── profiles/        # Preset: dev, general, marketer, ceo
├── tests/               # 🧪 kernel/ + cli/ integration tests
├── docs/                # 📖 Tài liệu
│   ├── architecture/    # Kiến trúc: overview, kernel
│   ├── guides/          # Hướng dẫn: development, planning
│   ├── reference/       # Tra cứu: CLI, workflows, project-rules
│   ├── changelog/       # Lịch sử phiên bản
│   └── workflows/       # Chi tiết từng workflow (17 files)
├── CONTRIBUTING.md
├── VERSIONING.md
├── CHANGELOG.md
└── VERSION
```

### Cấu trúc Workspace (Tạo bởi `para init`)

### Cấu trúc Môi trường làm việc cá nhân (Được khởi tạo bởi `para init`)

Đây là hệ thống được sinh ra dành riêng cho cá nhân bạn.

```
<môi-trường-làm-việc>/
├── Projects/                          # Các nhiệm vụ có mục tiêu (vd: website-launch)
├── Areas/                             # Các trách nhiệm thường xuyên (vd: sức khoẻ, tài chính)
│   ├── Workspace/                     # Session log tổng, audit reports, SYNC queue
│   └── Learning/                      # Mảng chia sẻ kiến thức (từ wf /learn)
├── Resources/                         # Tài liệu tham khảo và công cụ
│   ├── ai-agents/                     # Kernel snapshot + governed library snapshots
│   └── references/                    # Repo PARA chính thức (chỉ-đọc)
├── Archive/                           # Lưu trữ lạnh cho các dự án đã hoàn tất
├── _inbox/                            # Vùng đệm tạm thời để hứng dữ liệu ngoài tải về nhanh
├── .agent/                            # Thư viện hệ thống Governed Library (Tự động đồng bộ lên)
│   ├── rules/                         # Các quy tắc kỹ năng (.md) cho Agent
│   ├── skills/                        # Các kỹ năng phức hợp (.md, /scripts)
│   └── workflows/                     # Các luồng làm việc (.md) cho Agent
├── .para/                             # Trạng thái hệ thống ngầm (BẤT KHẢ XÂM PHẠM)
│   ├── archive/                       # Smart Archive — di dời file kiến trúc cũ
│   ├── migrations/                    # Lịch sử và kiểm soát luồng di chuyển phiên bản
│   ├── backups/                       # Bản sao lưu (workflows, projects, workspace sessions)
│   └── audit.log                      # Lịch sử hành động của PARA CLI
├── para                               # Bootstrapper CLI
└── .para-workspace.yml                # Metadata gốc quy định root config của hệ thống
```

---

## 📥 Cài đặt

### Yêu cầu

- **Một nền tảng AI Agent** (xem bảng tương thích bên dưới)
- **Git** (bắt buộc — để clone và cập nhật)
- **Bash** 3.2+ (Linux/macOS native, Windows qua Git Bash hoặc WSL)

### Tương thích Nền tảng

| Nền tảng           | Điểm tích hợp                  | Trạng thái         | Ghi chú                                         |
| :----------------- | :----------------------------- | :----------------- | :---------------------------------------------- |
| Google Antigravity | `.agent/` (skills, workflows)  | ✅ Verified        | Thiết kế và test chuyên cho nền tảng này        |
| Claude Code        | CLAUDE.md + `.agent/`          | ⚪ Chưa kiểm chứng | Có thể đọc `.agent/rules/` — cần xác nhận       |
| Cursor             | `.cursor/rules/`               | ⚪ Chưa test       | Lý thuyết: copy rules sang `.cursor/rules/`     |
| VS Code + Copilot  | `.github/copilot-instructions` | ⚪ Chưa test       | Lý thuyết: chỉ instructions, không auto-trigger |

### Bước 1: Clone & Cài đặt

**Bash (Linux / macOS / Windows Git Bash / WSL):**

```bash
# Clone repo vào đúng vị trí
mkdir -p Resources/references
git clone https://github.com/pageel/para-workspace.git Resources/references/para-workspace

# Cấp quyền thực thi
chmod +x Resources/references/para-workspace/cli/para
chmod +x Resources/references/para-workspace/cli/commands/*.sh

# Khởi tạo workspace với profile
./Resources/references/para-workspace/cli/para init --profile=dev --lang=vi
```

**PowerShell (tuỳ chọn thay thế cho Windows):**

```powershell
mkdir -Force Resources\references
git clone https://github.com/pageel/para-workspace.git Resources\references\para-workspace
# Sau đó mở Git Bash hoặc WSL tại workspace root:
./Resources/references/para-workspace/cli/para init --profile=dev --lang=vi
```

### Bước 2: Xác nhận

```bash
./para status
# ✅ Nếu thấy health report → cài thành công
```

> **Chuyện gì vừa xảy ra?**
>
> 1. Repo nằm tại `Resources/references/para-workspace/` — nguồn tham khảo quản trị, không phải project người dùng.
> 2. `chmod +x` đảm bảo các CLI scripts có quyền thực thi (bắt buộc trên Linux/macOS).
> 3. `para init` tạo cấu trúc thư mục PARA (bao gồm cả `_inbox/`), tự động chạy `install.sh`
>    để đồng bộ kernel, workflows, governance rules, và tạo wrapper `./para`.
> 4. Từ giờ bạn dùng `./para` từ workspace root cho mọi lệnh.

### Cập nhật

```bash
# Pull phiên bản mới nhất từ GitHub và đồng bộ lại workspace
./para update

# Xem trước thay đổi mà không áp dụng
./para update --dry-run
```

Lệnh này sẽ `git pull` repo, chạy migration phân tầng theo phiên bản (chỉ những bước cần thiết), và đồng bộ lại tất cả governed libraries. File tuỳ chỉnh được sao lưu thành `.bak` trước khi ghi đè (Smart Sync). Nếu install thất bại giữa chừng, tất cả thay đổi sẽ tự động rollback.

**Quy trình update:**

1. `git pull` tải code mới (tự restart nếu scripts thay đổi)
2. `migrate.sh` chạy migration phân tầng theo version (chỉ chạy gì cần)
3. `install.sh` đồng bộ kernel, workflows, rules, skills (với atomic rollback)
4. Ghi audit log vào `.para/audit.log`

### Xử lý sự cố

| Vấn đề                            | Giải pháp                                                                                                  |
| :-------------------------------- | :--------------------------------------------------------------------------------------------------------- |
| **macOS: permission denied**      | Chạy `chmod +x` cho CLI scripts (Bước 3 bên trên)                                                          |
| **Windows: file lock khi update** | Xem [Khôi phục Windows](#khôi-phục-windows) bên dưới                                                       |
| **Workspace quá cũ (v1.3.x)**     | Dùng [Cơ chế 2: Làm mới Thủ công](#cơ-chế-2-dọn-dẹp-làm-mới-thủ-công-dành-cho-workspace-bị-chỉnh-sửa-mạnh) |

#### Khôi phục Windows

Nếu `para update` bị lỗi trên Windows do NTFS file locking:

```cmd
cd Resources\references\para-workspace
git checkout -- .
git pull origin main
cd ..\..\..
.\para install
```

### Profiles có sẵn

| Profile                                                | Mô tả                         | Phù hợp cho         |
| ------------------------------------------------------ | ----------------------------- | ------------------- |
| [`general`](../templates/profiles/general/README.md)   | Cấu trúc PARA tối thiểu       | PKM cá nhân         |
| [`dev`](../templates/profiles/dev/README.md)           | Areas kỹ thuật + AI tooling   | Lập trình viên      |
| [`marketer`](../templates/profiles/marketer/README.md) | Areas chiến dịch & khách hàng | Nhân viên marketing |
| [`ceo`](../templates/profiles/ceo/README.md)           | Chiến lược & quản lý tổ chức  | CEO & lãnh đạo      |

### `para init` làm gì?

- ✅ Tạo `Projects/`, `Areas/`, `Resources/`, `Archive/`, và `_inbox/`
- ✅ Cấp **quyền thực thi** cho tất cả CLI scripts
- ✅ Tự động chạy **`install.sh`**, bao gồm:
  - Đồng bộ **governed workflows** từ `catalog.yml` vào `.agent/workflows/`
  - Đồng bộ **governed rules** từ `catalog.yml` vào `.agent/rules/`
  - Đồng bộ **skills** vào `.agent/skills/` (tuỳ profile)
  - Tạo **`./para`** wrapper tại workspace root
  - Sao lưu file xung đột thành `.bak`
- ✅ Tạo **`.para-workspace.yml`** với tracking phiên bản kernel
- ✅ Khởi tạo **`.para/`** (audit.log, migrations/, backups/) để kiểm soát đầy đủ

---

## 🧠 Kernel (Nhân hệ thống)

Kernel là **hiến pháp** của PARA Workspace — các quy tắc mà mọi workspace phải tuân theo.

### Invariants (Luật cứng — thay đổi = MAJOR bump)

| #   | Quy tắc                                                               |
| --- | --------------------------------------------------------------------- |
| I1  | Cấu trúc thư mục PARA là bắt buộc                                     |
| I2  | Mô hình task hybrid 3-file (backlog = canonical, hot lane, /end sync) |
| I3  | Đặt tên project theo kebab-case                                       |
| I4  | Không có task hoạt động = project không hoạt động                     |
| I5  | Areas không chứa runtime tasks                                        |
| I6  | Archive là lưu trữ lạnh bất biến                                      |
| I7  | Seeds là ý tưởng thô, không phải tasks                                |
| I8  | Không có file lẻ ở root workspace                                     |
| I9  | Resources là tham chiếu chỉ-đọc                                       |
| I10 | Tách biệt Repo ↔ Workspace                                            |
| I11 | Ngôn ngữ viết workflow tuân thủ Language Compliance                   |

### Heuristics (Quy ước mềm — thay đổi = MINOR/PATCH)

| #   | Hướng dẫn                                                |
| --- | -------------------------------------------------------- |
| H1  | Quy ước đặt tên (kebab-case, PascalCase)                 |
| H2  | Thứ tự ưu tiên nạp context                               |
| H3  | Quản lý phiên bản ngữ nghĩa (SemVer)                     |
| H4  | Cấu trúc thư mục project chuẩn                           |
| H5  | Vòng đời Beads (tạo → messy → tốt nghiệp)                |
| H6  | Ranh giới VCS & Git                                      |
| H7  | Tham chiếu xuyên project qua Resources                   |
| H8  | Tương thích kernel cho workflow                          |
| H9  | Thư viện quản trị yêu cầu `catalog.yml` với `kernel_min` |

### Hợp đồng Kernel ↔ Workspace

| File                         | Schema                  | Thực thi bởi                   |
| ---------------------------- | ----------------------- | ------------------------------ |
| `.para-workspace.yml`        | `workspace.schema.json` | `para init`, `para status`     |
| `Projects/*/.project.yml`    | `project.schema.json`   | `para scaffold`, `para review` |
| `artifacts/tasks/backlog.md` | `backlog.schema.json`   | `para verify`                  |
| `*/catalog.yml`              | `catalog.schema.json`   | `para install`, `para update`  |

---

## 🛠️ Tham chiếu CLI

```bash
# Lệnh Cốt lõi
para init [--profile] [--lang]  # Khởi tạo workspace
para status [--json]          # Sức khỏe hệ thống
para update [--dry-run]        # Cập nhật Hệ thống chuẩn hoá mới và di chuyển tự động (migrate)
para scaffold <loại> <tên>   # Tạo dự án/lĩnh vực/tài nguyên chuẩn với lõi tạo tác
para install [--force] [--dry-run]  # Đồng bộ thư viện hạt nhân và hệ thống quản trị từ repo
para archive <loại>/<tên>    # Chuyển các hạng mục hoàn tất vào thư mục Lưu trữ
para migrate [--from=X] [--to=Y]  # Tự động nâng cấp cấu trúc workspace theo phiên bản định kiến

# Cấu hình
para config [key] [value]     # Quản lý thiết lập trong tệp .para-workspace.yml

# Chức năng của Agent
@[/para-workflow] list        # Kiểm tra và rà soát tính hợp quy của Workflows
@[/para-rule] list            # Kiểm tra và rà soát tính hợp quy của Rules
```

**Hỗ trợ nền tảng:** Linux, macOS (Bash 3.2+), Windows (Git Bash / WSL).

---

## 📑 Catalog Workflow

| Lệnh                                                 | Mô tả                                                     |
| :--------------------------------------------------- | :-------------------------------------------------------- |
| **[`/backlog`](./workflows/backlog.md)**             | Quản lý tasks qua backlog.md canonical + plan integration |
| **`/backup`**                                        | Sao lưu workflows, rules, config, và dữ liệu project      |
| **[`/brainstorm`](./workflows/brainstorm.md)**       | Brainstorm ý tưởng với cấu trúc và 5 hướng kế tiếp        |
| **`/config`**                                        | Quản lý cấu hình workspace                                |
| **[`/end`](./workflows/end.md)**                     | Đóng phiên + dọn dẹp active_plan tự động                  |
| **`/inbox`**                                         | Phân loại file từ `_inbox/` vào PARA                      |
| **[`/install`](./workflows/install.md)**             | Cài đặt thông minh (xử lý cập nhật/merge)                 |
| **`/learn`**                                         | Ghi nhận bài học vào Areas/Learning                       |
| **[`/merge`](./workflows/merge.md)**                 | Merge ngữ nghĩa cho xung đột workflow                     |
| **`/new-project`**                                   | Khởi tạo project mới với scaffolding                      |
| **[`/open`](./workflows/open.md)**                   | Bắt đầu phiên với nạp context + plan phase                |
| **[`/para`](./workflows/para.md)**                   | Bộ điều khiển chính cho quản lý workspace                 |
| **[`/docs`](./workflows/docs.md)**                   | Tạo, kiểm tra, và xuất bản tài liệu kỹ thuật              |
| **[`/para-audit`](./workflows/para-audit.md)**       | Khảo sát hệ thống, phát hiện độ lệch chuẩn so với Kernel  |
| **[`/para-rule`](./workflows/para-rule.md)**         | Quản lý, cài đặt, chuẩn hoá agent rules                   |
| **[`/para-workflow`](./workflows/para-workflow.md)** | Quản lý, cài đặt, chuẩn hoá agent workflows               |
| **[`/plan`](./workflows/plan.md)**                   | Tạo, xem, và cập nhật kế hoạch triển khai                 |
| **[`/push`](./workflows/push.md)**                   | Commit và push nhanh lên GitHub                           |
| **[`/release`](./workflows/release.md)**             | Kiểm tra chất lượng trước release                         |
| **[`/retro`](./workflows/retro.md)**                 | Retrospective project trước khi archive                   |
| **[`/update`](./workflows/update.md)**               | Cập nhật workspace an toàn với agent hỗ trợ               |
| **[`/verify`](./workflows/verify.md)**               | Xác minh hoàn thành task bằng walkthroughs                |

---

## 🧩 Quản lý Tác vụ (Mô hình Hybrid 3-File)

PARA Workspace giải quyết bài toán "Lãng phí Token & Mất trí nhớ" của AI Agent thông qua kiến trúc **Hybrid 3-File Model** (v1.5.3: Hot Lane).

Thay vì bắt Agent phải đọc một file backlog khổng lồ, công việc được phân bổ qua ba tệp tin chuyên biệt:

```
artifacts/tasks/
├── backlog.md          # 📌 OPERATIONAL AUTHORITY — Nguồn sự thật duy nhất cho task chiến lược.
├── sprint-current.md   # 🔥 HOT LANE — Buffer ghi trực tiếp cho Agent (quick tasks phát sinh).
└── done.md             # ✅ ARCHIVE — Lưu trữ append-only với origin tags (#backlog / #session).
```

### Cơ chế hoạt động

1. **Backlog Summary** — `/open` chỉ đọc bảng Summary (~10 dòng) + top items qua `grep`. Không bao giờ đọc toàn bộ file.
2. **Hot Lane** — Agent ghi quick tasks (`- [ ] Fix CSS`) vào `sprint-current.md` và tick `[x]` khi xong. Task chiến lược từ backlog được đọc trực tiếp, không copy.
3. **`/end` là Sync Point duy nhất** — Khi đóng phiên, `/end` chạy Hot Lane Sync:
   - Quick `[x]` → `done.md` (tag `#session`)
   - Quick `[ ]` → hỏi user: giữ hay promote vào backlog?
   - **Smart Suggest** → đọc session log, tìm task IDs được nhắc đến, gợi ý đánh dấu Done (tag `#backlog`)
4. **Zero Ceremony khi code** — Không cần `/backlog update` giữa phiên. Cứ code thôi.

---

## 🔄 Nâng cấp Phiên bản (Upgrading)

> 📖 **Lưu ý:** Để xem chi tiết các tính năng mới, lỗi được sửa và thông tin cập nhật từng phiên bản, vui lòng tham khảo [CHANGELOG](../CHANGELOG.md).

PARA Workspace cung cấp hai cơ chế chính thức để nâng cấp lên phiên bản mới hơn:

### Cơ chế 1: Cập nhật Tự động (Khuyên dùng)

Dành cho đa số cấu trúc workspace đang khỏe mạnh, cơ chế cập nhật tích hợp sẽ xử lý mọi thứ an toàn.

```bash
./para update
```

Lệnh này sẽ tự động tải lõi hệ thống mới về, chạy migration phân tầng (chỉ chạy những bước phù hợp phiên bản), đồng bộ thư viện, và di dời file hệ thống lỗi thời vào `.para/archive/` mà không xoá dữ liệu riêng của bạn (Smart Archive). Các rules tuỳ chỉnh được bảo vệ bằng `.bak` backup.

### Cơ chế 2: Dọn dẹp Làm mới Thủ công (Dành cho workspace bị chỉnh sửa mạnh)

Nếu workspace của bạn quá cũ (v1.3.x) hoặc đã bị bạn chỉnh sửa cấu trúc lõi nghiêm trọng, hãy làm mới hoàn toàn:

1. Chạy `para init --profile=dev --lang=vi` ở một không gian thư mục hoàn toàn mới.
2. Sao chép lại các thư mục `Projects/` bên dự án cũ rớt vào thư mục `_inbox/` ở workspace mới.
3. Chạy workflow `/inbox` hoặc dùng AI agent để tự động phân luồng dọn dẹp các project về đúng khoang chứa chuẩn mới của PARA.

---

## 🗺️ Lộ trình

- [x] Cross-Project Sync Queue _(phát hành v1.3.6)_
- [x] Trích xuất Kernel & Tái cấu trúc Repo _(phát hành v1.4.0)_
- [x] Thư viện Quản trị, Quy trình RFC, An toàn Workspace Runtime _(phát hành v1.4.1)_
- [x] Landing Page `paraworkspace.dev` _(phát hành v1.4.1)_
- [x] Workflow Plan-Aware & Tối ưu Token _(phát hành v1.4.2)_
- [x] Tự động dọn dẹp Plan qua `/end [done]` _(phát hành v1.4.3)_
- [x] Safety Guardrails & Terminal Allowlist _(phát hành v1.4.5)_
- [x] Smart Archive & Version Migration _(phát hành v1.4.6)_
- [x] Tương thích macOS & Pipeline Migration an toàn _(phát hành v1.4.7)_
- [x] Atomic Rollback, Dry-run Pipeline & README Rewrite _(phát hành v1.4.8)_
- [x] Centralized Backup & Workspace Cleanup _(phát hành v1.4.9)_
- [x] Documentation Manager Workflow _(phát hành v1.4.10)_
- [x] Project Rules Loading & Safe Update Workflow _(phát hành v1.5.0)_
- [x] Hybrid 3-File Integrity, Working Checkmarks & Docs Overhaul _(phát hành v1.5.2)_
- [x] Hot Lane Refactor, /end Sync Point & Token Optimization _(phát hành v1.5.3)_

---

## 🤝 Đóng góp

Xem [CONTRIBUTING.md](../CONTRIBUTING.md) để biết hướng dẫn. Điểm chính:

- Thay đổi invariant kernel yêu cầu **RFC + MAJOR bump** → Xem [rfcs/TEMPLATE.md](../rfcs/TEMPLATE.md)
- Thay đổi heuristic yêu cầu **PR + MINOR/PATCH bump**
- Mọi thay đổi phải vượt qua test vectors trong `kernel/examples/`

---

Xây dựng với ❤️ bởi **Pageel**. Chuẩn hoá tương lai của PKM Agent.

_Phiên bản: 1.5.3_
