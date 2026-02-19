# PARA Workspace

> **Chuẩn Workspace có Quản trị dành cho AI Agent**

<div align="center">

<img src="../.github/assets/banner.png" width="100%" alt="PARA Workspace Banner">

<br/>

[![PARA Version](https://img.shields.io/badge/PARA-v1.4.0-00CFE8.svg?style=for-the-badge&logo=gitbook&logoColor=white)](https://github.com/pageel/para-workspace)
[![Agent Ready](https://img.shields.io/badge/Agent-Ready-2ECC71.svg?style=for-the-badge&logo=googlecloud&logoColor=white)](#-tích-hợp-agent)
[![License: MIT](https://img.shields.io/badge/License-MIT-F1C40F.svg?style=for-the-badge&logo=opensourceinitiative&logoColor=white)](https://opensource.org/licenses/MIT)

[🇺🇸 English](../README.md) • [🇻🇳 Tiếng Việt](./README.vi.md)

</div>

---

## 🌌 Tổng quan

**PARA Workspace** là một chuẩn mở có quản trị, định nghĩa cách con người và AI agent tổ chức tri thức và cộng tác trong dự án. Hệ thống được phân phối dưới dạng **repo** chứa kernel (hiến pháp), công cụ CLI, và templates — từ đó tạo ra các **workspace** nơi bạn thực sự làm việc. Kernel thực thi 10 invariants và 8 heuristics để mọi workspace đều nhất quán, kiểm soát được, và thân thiện với agent.

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
├── kernel/            # 🧠 Quy tắc — invariants, heuristics, schemas
│   ├── KERNEL.md      # Hiến pháp
│   ├── invariants.md  # 10 luật cứng (thay đổi = MAJOR bump)
│   ├── heuristics.md  # 8 quy ước mềm
│   ├── schema/        # Hợp đồng định dạng file
│   └── examples/      # Vector kiểm thử tuân thủ
├── cli/               # 🔧 Công cụ
│   ├── para           # Điểm vào
│   └── commands/      # init, scaffold, status, migrate, archive, install...
├── workflows/         # 📑 Workflow tham chiếu (không trạng thái)
├── templates/         # 📦 Khuôn mẫu
│   ├── common/        # Template cho project, task, agent
│   └── profiles/      # Preset: dev, general, marketer, ceo
├── docs/              # 📖 Tài liệu
├── CONTRIBUTING.md
├── VERSIONING.md
├── CHANGELOG.md
└── VERSION
```

### Cấu trúc Workspace (Tạo bởi `para init`)

```
workspace/
├── Projects/          # ⚡ Công việc đang hoạt động, có deadline
├── Areas/             # 🛡️ Kiến thức ổn định & SOPs
├── Resources/         # 📚 Tài liệu tham khảo, công cụ, kernel snapshot
│   └── ai-agents/
│       ├── kernel/    # Bản sao chỉ-đọc từ repo
│       └── workflows/ # Catalog workflow
├── Archive/           # ❄️ Lưu trữ lạnh
├── _inbox/            # 📥 Khu vực tiếp nhận (Inbox)
├── .agent/            # 🤖 Runtime agent
│   ├── rules/
│   └── workflows/
├── .para-workspace.yml
└── README.md
```

---

## 📥 Cài đặt

### Bắt đầu nhanh

Mở thư mục workspace (trong Antigravity hoặc IDE) và làm theo các bước:

```bash
# 1. Clone repo vào Resources (nguồn tham khảo, không phải project người dùng)
mkdir -p Resources/references
git clone https://github.com/pageel/para-workspace.git Resources/references/para-workspace

# 2. Cấp quyền thực thi (Chỉ dành cho Linux/macOS)
chmod +x Resources/references/para-workspace/cli/para
chmod +x Resources/references/para-workspace/cli/commands/*.sh

# 3. Khởi tạo workspace với profile
./Resources/references/para-workspace/cli/para init --profile=dev --lang=en

# 4. Kiểm tra mọi thứ hoạt động
./para status
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
```

Lệnh này sẽ `git pull` repo và chạy lại `install.sh` để đồng bộ kernel, workflows, và governance. Các file hiện có được sao lưu thành `.bak` trước khi ghi đè.

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
  - Cài **kernel snapshot** vào `Resources/ai-agents/kernel/`
  - Cài **workflows** vào `.agent/workflows/` và catalog
  - Cài **quy tắc quản trị agent** vào `.agent/rules/`
  - Tạo **`./para`** wrapper tại workspace root
  - Sao lưu file xung đột thành `.bak`
- ✅ Tạo **`.para-workspace.yml`** với tracking phiên bản kernel

---

## 🧠 Kernel (Nhân hệ thống)

Kernel là **hiến pháp** của PARA Workspace — các quy tắc mà mọi workspace phải tuân theo.

### Invariants (Luật cứng — thay đổi = MAJOR bump)

| #   | Quy tắc                                           |
| --- | ------------------------------------------------- |
| I1  | Cấu trúc thư mục PARA là bắt buộc                 |
| I2  | Mô hình task hybrid 3-file (backlog = canonical)  |
| I3  | Đặt tên project theo kebab-case                   |
| I4  | Không có task hoạt động = project không hoạt động |
| I5  | Areas không chứa runtime tasks                    |
| I6  | Archive là lưu trữ lạnh bất biến                  |
| I7  | Seeds là ý tưởng thô, không phải tasks            |
| I8  | Không có file lẻ ở root workspace                 |
| I9  | Resources là tham chiếu chỉ-đọc                   |
| I10 | Tách biệt Repo ↔ Workspace                        |

### Heuristics (Quy ước mềm — thay đổi = MINOR/PATCH)

| #   | Hướng dẫn                                 |
| --- | ----------------------------------------- |
| H1  | Quy ước đặt tên (kebab-case, PascalCase)  |
| H2  | Thứ tự ưu tiên nạp context                |
| H3  | Quản lý phiên bản ngữ nghĩa (SemVer)      |
| H4  | Cấu trúc thư mục project chuẩn            |
| H5  | Vòng đời Beads (tạo → messy → tốt nghiệp) |
| H6  | Ranh giới VCS & Git                       |
| H7  | Tham chiếu xuyên project qua Resources    |
| H8  | Tương thích kernel cho workflow           |

---

## 🛠️ Tham chiếu CLI

```bash
# Lệnh chính
para init [--profile=X] [--lang=X] [--path=X]  # Tạo workspace
para scaffold {project|area|resource} <name>     # Tạo mục
para status [--json]                             # Sức khoẻ workspace
para archive <type>/<name> [--force]             # Lưu trữ lạnh
para migrate [--from=X] [--to=Y] [--dry-run]    # Nâng cấp phiên bản
para install [--force]                           # Đồng bộ từ repo

# Lệnh phát triển
para plan <proj> <desc>       # Kế hoạch triển khai
para verify <proj> [desc]     # Xác minh task
para review                   # Kiểm tra workspace sâu

# Lệnh hệ thống
para config [key] [value]     # Cài đặt workspace
para work <command>           # Quản lý workflows
para rule <command>           # Quản lý rules
```

---

## 📑 Catalog Workflow

| Lệnh               | Mô tả                                      |
| :----------------- | :----------------------------------------- |
| **`/backlog`**     | Quản lý tasks qua backlog.md canonical     |
| **`/backup`**      | Sao lưu workflows, rules, và config        |
| **`/config`**      | Quản lý cấu hình workspace                 |
| **`/end`**         | Đóng phiên làm việc với phân loại PARA     |
| **`/install`**     | Cài đặt thông minh (xử lý cập nhật/merge)  |
| **`/merge`**       | Merge ngữ nghĩa cho xung đột workflow      |
| **`/new-project`** | Khởi tạo project mới với scaffolding       |
| **`/open`**        | Bắt đầu phiên với nạp context              |
| **`/para`**        | Bộ điều khiển chính cho quản lý workspace  |
| **`/push`**        | Commit và push nhanh lên GitHub            |
| **`/release`**     | Kiểm tra chất lượng trước release          |
| **`/retro`**       | Retrospective project trước khi archive    |
| **`/verify`**      | Xác minh hoàn thành task bằng walkthroughs |

---

## 🧩 Quản lý Task

PARA Workspace sử dụng **Mô hình Hybrid 3 File**:

```
artifacts/tasks/
├── backlog.md          # 📌 CANONICAL — tất cả tasks ở đây
├── sprint-current.md   # 🎯 DERIVED — chỉ tasks đang hoạt động
└── done.md             # ✅ DERIVED — lưu trữ tasks hoàn thành
```

Agent tương tác chủ yếu với `backlog.md` qua workflow `/backlog`. `sprint-current.md` và `done.md` là các view phái sinh giúp backlog gọn gàng.

---

## 🔄 Di chuyển từ v1.3.x

```bash
# Xem trước thay đổi
para migrate --from=1.3.6 --to=1.4.0 --dry-run

# Áp dụng di chuyển
para migrate --from=1.3.6 --to=1.4.0
```

Xem [Hướng dẫn Di chuyển](./migration.md) để biết chi tiết.

---

## 🗺️ Lộ trình

- [x] v1.3.6 — Hàng đợi Đồng bộ Xuyên Project
- [x] v1.4.0 — Trích xuất Kernel & Tái cấu trúc Repo
- [ ] v1.5.0 — Landing Page PARA (`paraworkspace.dev`)
- [ ] v1.5.x — Multi-agent Routing
- [ ] v2.0.0 — Safety Guardrails & Terminal Allowlist

---

## 🤝 Đóng góp

Xem [CONTRIBUTING.md](../CONTRIBUTING.md) để biết hướng dẫn. Điểm chính:

- Thay đổi invariant kernel yêu cầu **RFC + MAJOR bump**
- Thay đổi heuristic yêu cầu **PR + MINOR/PATCH bump**
- Mọi thay đổi phải vượt qua test vectors trong `kernel/examples/`

---

Xây dựng với ❤️ bởi **Pageel**. Chuẩn hoá tương lai của PKM Agent.

_Phiên bản: 1.4.0_
