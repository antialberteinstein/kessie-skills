# Quy trình xây dựng dự án với kessie-skills (`/kessie-skills:proj`)

Bạn **không cần gõ lệnh**: cứ nói việc muốn làm, agent tự gọi `/kessie-skills:proj <chế độ>` phù hợp (vẫn gõ tay được nếu muốn). Sang giai đoạn kế tiếp thì agent hỏi trước. Bạn quyết định spec, thiết kế, kiến trúc, và mọi thao tác ra bên ngoài (push, PR, merge, tag, release, tạo issue).

```
        ┌──────────── KHỞI ĐỘNG (một lần) ────────────┐
ý tưởng → proj kickoff → idea brief → spec + AC → ADR → (DESIGN.md) → scaffold + CI → backlog
        └──────────────────────────────────────────────┘
                                   │
        ┌──────────── VÒNG LẶP HẰNG NGÀY ─────────────┐
        │  proj spec ←── ý tưởng mới, thay đổi, inbox  │
        │    ↓ (bạn chốt)                               │
        │  proj plan | proj issue ──→ issue             │
        │    ↓                                          │
        │  proj build <#issue> ──→ PR ──→ CI ──→ merge  │
        └──────────────────────────────────────────────┘
                                   │ đủ tính năng cho một phiên bản
        ┌──────────── PHÁT HÀNH ──────────────────────┐
        │  proj ship verify → ship security → ship release X.Y.Z → artifact → kiểm tra trên môi trường thật │
        └──────────────────────────────────────────────┘
        Định kỳ: proj status · proj report · proj deps · proj triage · (trống) = bước tiếp theo
```

(`/kickoff` là viết tắt của `/kessie-skills:proj kickoff`; các lệnh khác tương tự.)

## 1. Khởi động (một lần cho mỗi dự án)

| Bước | Bạn gõ | Agent làm | Bạn quyết định |
|---|---|---|---|
| 1 | `/kessie-skills:proj kickoff Ứng dụng quản lý …` | Xác định loại dự án, phỏng vấn từng câu → idea brief 1 trang | Phạm vi v1, ngoài phạm vi |
| 2 | (tiếp trong kickoff) | Viết `RequirementsOutline` + `docs/modules/*.md` có bảng AC | Duyệt spec |
| 3 | (tiếp) | Đề xuất 2–3 phương án stack và kiến trúc kèm một khuyến nghị → ADR | Chọn stack, Auth, backend |
| 4 | (tiếp, nếu có UI) | Đề xuất 3 mẫu DESIGN.md, hoặc soạn mẫu riêng | Chọn hoặc duyệt thiết kế |
| 5 | (tiếp) | Khởi tạo project bằng công cụ chính thức của framework, chạy scaffold (17 file: README, CHANGELOG, CLAUDE.md, docs, CI, template PR/issue, `spec-inbox.md`, `prompts/LOG.md`), ghi mục đầu tiên vào `prompts/LOG.md`, CI xanh. CLAUDE.md luôn có 4 quy tắc: lưu prompt vào `prompts/LOG.md`; không ghi attribution của AI (`Co-Authored-By`, "Generated with Claude Code"); mục "Skill bổ trợ" (`proj`, `karpathy-guidelines`, chưa cài thì agent gợi ý lệnh cài); agent tự gọi skill theo cột "Khi nào gọi" | Tạo repo GitHub, push commit đầu, bảo vệ `main` |
| 6 | `/kessie-skills:proj plan` | Tách AC thành issue cỡ một PR, theo thứ tự phụ thuộc, nhóm vào milestone `0.1.0` | Duyệt rồi mới tạo issue |

Có thể dừng giữa chừng: lần sau gõ lại `/kessie-skills:proj kickoff tiếp nhận .` để agent đọc trạng thái và làm tiếp.

## 2. Vòng lặp hằng ngày

**Có ý tưởng hoặc muốn đổi hành vi** (việc của spec, không phải của code):
- Ghi vội vào `docs/spec-inbox.md`, lúc rảnh gõ `/kessie-skills:proj spec inbox`; hoặc
- `/kessie-skills:proj spec Mình muốn thêm …` để agent tách ý, hỏi tối đa 3 câu, trình diff; hoặc
- `/kessie-skills:proj spec thảo luận <chủ đề>` để bàn từng câu cho tới khi bạn nói "chốt".

Sau khi chốt: `/kessie-skills:proj plan` (nhiều issue) hoặc `/kessie-skills:proj issue <mô tả>` (một issue).

**Gặp lỗi hoặc việc lặt vặt:** `/kessie-skills:proj issue Lỗi …`. Agent tìm issue trùng, soạn theo mẫu Bug kèm điều kiện đóng, bạn duyệt rồi mới tạo.

**Làm việc:**

```
/kessie-skills:proj build 12
```

Agent đọc issue → tái hiện (nếu là bug) → tạo nhánh `fix/12-…` → viết test trước → code → chạy cổng kiểm tra → cập nhật CHANGELOG → commit → **hỏi bạn** trước khi push và mở PR (`Closes #12` nếu đã xác minh, `Refs #12` nếu còn phần cần thiết bị hoặc production) → theo dõi CI. Bạn review và merge.

Gõ `/kessie-skills:proj build <mô tả>` mà chưa có issue thì agent đề xuất tạo issue trước (cùng mẫu với `lead issue`). Việc rất nhỏ thì làm luôn được.

**Đổi giao diện:** `/kessie-skills:proj design apply` (token + style guide trước, mỗi nhóm màn hình một PR). Muốn đổi phong cách thì gõ `/kessie-skills:proj design` để chọn lại.

## 3. Phát hành (khi milestone đủ)

| Bạn gõ | Agent làm |
|---|---|
| `/kessie-skills:proj ship verify` | Ánh xạ mọi AC của milestone sang bằng chứng; chỉ ra phần chưa xác minh; soạn checklist môi trường thật theo loại dự án |
| `/kessie-skills:proj ship security` | Review secret, phân quyền, lỗi và log của các thay đổi trong milestone |
| `/kessie-skills:proj deps` | Triage Dependabot, audit dependency |
| `/kessie-skills:proj ship release 0.1.0` | Chạy script kiểm tra → PR phiên bản (version, CHANGELOG, badge) → sau khi bạn merge: tag → GitHub Release → artifact (bản cài, deploy, hoặc publish tuỳ loại dự án). **Mỗi bước hỏi bạn trước** |

Sau đó bạn kiểm tra trên chính artifact vừa phát hành (thiết bị thật, staging, gói vừa publish…) theo checklist; lỗi tìm thấy đi qua `lead issue`.

## 4. Định kỳ (mỗi tuần hoặc khi quay lại sau một thời gian)

- `/kessie-skills:proj status`: script chụp trạng thái (nhánh, file lạc, version, Unreleased, issue/PR/milestone, CI) kèm đề xuất việc tiếp theo.
- `/kessie-skills:proj report`: báo cáo tiến độ ngắn.
- `/kessie-skills:proj triage`: phân loại issue mới.
- `/kessie-skills:proj deps`: dependency.

## File nào chứa gì

| File | Vai trò | Ai sửa |
|---|---|---|
| `docs/spec-inbox.md` | Ý tưởng thô | Bạn |
| `docs/RequirementsOutline.md`, `docs/modules/*.md` | Spec đã chốt + AC + lịch sử quyết định | Agent đề xuất, bạn duyệt |
| `docs/decisions/*.md` | ADR (kỹ thuật, thiết kế) | Agent đề xuất, bạn chấp nhận |
| `DESIGN.md` | Giao diện trông thế nào | Qua `/design` |
| `CLAUDE.md` | Cách xây, lệnh, cạm bẫy, quy tắc cốt lõi của quy trình (ngắn) | Agent cập nhật cùng PR có thay đổi liên quan |
| `prompts/NN-*.txt` | Prompt giao việc theo giai đoạn (khi xây phần lớn qua nhiều phiên) | Agent |
| GitHub Issues + milestone | Backlog duy nhất | Agent soạn, bạn duyệt |
| `CHANGELOG.md` | Thay đổi người dùng thấy | Agent, trong mỗi PR |

## Khi dùng ECC cho một dự án khác

Skill `proj` có thể được agent tự gọi ở mọi dự án khi yêu cầu khớp mô tả của nó. Dự án dùng quy trình khác thì ghi vào CLAUDE.md của dự án đó: "Không dùng skill `kessie-skills:proj`", hoặc tắt plugin cho dự án đó (`/plugin`).
