---
name: proj
description: "Quy trình dự án cho một người làm cùng AI agent, mọi loại dự án và stack — khởi động, spec (người dùng chốt), DESIGN.md, tạo issue, build issue → PR, kiểm chứng, phát hành, trạng thái và bảo trì. Gọi thủ công kèm chế độ; không kèm chế độ thì gợi ý bước tiếp theo."
argument-hint: "[(trống) | kickoff | spec | design | issue | plan | build | ship | status | report | triage | deps] …"
disable-model-invocation: true
allowed-tools: Bash(${CLAUDE_SKILL_DIR}/scripts/project-snapshot.sh *) Bash(${CLAUDE_SKILL_DIR}/scripts/check-release-ready.sh *) Bash(${CLAUDE_SKILL_DIR}/scripts/design-md.sh list*) Bash(${CLAUDE_SKILL_DIR}/scripts/design-md.sh show *) Bash(${CLAUDE_SKILL_DIR}/scripts/contrast.mjs *)
---

# proj — Quy trình dự án

Đầu vào: `$ARGUMENTS`. **Từ đầu tiên là chế độ, phần còn lại là tham số của chế độ.**

Thư mục skill: `${CLAUDE_SKILL_DIR}`. Trong các file `references/`, `<skill-dir>` nghĩa là thư mục này. Đường dẫn `references/…`, `scripts/…`, `templates/…` đều tính từ thư mục này.

Tên lệnh phụ thuộc cách cài: `/kessie-skills:proj` khi cài dạng plugin, `/proj` khi cài bằng `install.sh`. Các file `references/` viết `/kessie-skills:proj`; khi gợi ý lệnh cho người dùng, dùng đúng tên đang được gọi.

## Định tuyến

Chỉ đọc file của chế độ đang chạy và các file mà nó trỏ tới; không đọc trước các chế độ khác.

| Chế độ | Đọc | Tham số |
|---|---|---|
| *(trống)* hoặc `next` | §Bước tiếp theo bên dưới | — |
| `kickoff` | `references/modes/kickoff.md` | `<ý tưởng>` · `tiếp nhận <repo>` |
| `spec` | `references/modes/spec.md` | `<mô tả>` · `thảo luận <chủ đề>` · `inbox` · `xem [module]` |
| `design` | `references/modes/design.md` | `list [từ khoá]` · `<tên mẫu>` · `custom` · `apply` |
| `issue` | `references/modes/lead.md` §2a | `<mô tả>` |
| `plan` | `references/modes/lead.md` §2–3 | `[milestone]` |
| `build` | `references/modes/build.md` | `<#issue>` · `<mô tả>` |
| `ship` | `references/modes/ship.md` | `verify [#issue]` · `security` · `release X.Y.Z` |
| `status` | `references/modes/lead.md` §1 | — |
| `report` | `references/modes/lead.md` §5 | — |
| `triage` | `references/modes/lead.md` §4 | `[#issue]` |
| `deps` | `references/dependencies.md` | — |

Từ đầu tiên không khớp chế độ nào: coi toàn bộ đầu vào là mô tả, đoán chế độ phù hợp (thường là `spec`, `issue` hoặc `build`) và **hỏi lại người dùng** trước khi làm.

Trong file chế độ, lệnh dạng `/kessie-skills:proj <chế độ>` là lệnh người dùng tự gõ. Agent chỉ gợi ý, không tự chuyển sang chế độ khác khi người dùng chưa đồng ý.

## Bước tiếp theo (khi không có chế độ)

1. Chạy `${CLAUDE_SKILL_DIR}/scripts/project-snapshot.sh .` (chỉ đọc).
2. Đối chiếu theo thứ tự, dừng ở dòng đầu tiên khớp:

| Tình trạng | Đề xuất |
|---|---|
| Chưa có `docs/RequirementsOutline.md`, hoặc chưa có CLAUDE.md / CI | `/kessie-skills:proj kickoff …` (repo có sẵn code thì `kickoff tiếp nhận .`) |
| `docs/spec-inbox.md` còn mục "Chưa xử lý" | `/kessie-skills:proj spec inbox` |
| Module đã duyệt có AC chưa thành issue, hoặc chưa có milestone | `/kessie-skills:proj plan` |
| PR đang mở có CI đỏ hoặc review chưa trả lời | `/kessie-skills:proj build <#issue của PR>` |
| Còn issue mở trong milestone hiện tại | `/kessie-skills:proj build <#issue nhỏ nhất không bị chặn>` |
| Milestone đã đóng hết issue, `[Unreleased]` có nội dung | `/kessie-skills:proj ship verify`, sau đó `ship release X.Y.Z` |
| PR Dependabot mở quá 7 ngày | `/kessie-skills:proj deps` |
| Không còn gì | `/kessie-skills:proj spec` để lên tính năng tiếp theo |

3. Trả lời ngắn: tình trạng hiện tại (3–5 dòng), **một** lệnh đề xuất kèm lý do, tối đa 2 lệnh thay thế.

## Nguyên tắc chung (mọi chế độ)

- **Spec là của người dùng.** Agent đề xuất, người dùng chốt; không tự sửa spec đã duyệt.
- Mọi thay đổi đi qua issue → nhánh → PR → CI. `Closes #N` chỉ khi đã xác minh; nếu chưa thì `Refs #N` và nêu phần chưa xác minh.
- **Hỏi trước** khi push, mở PR, merge, gắn tag, release, deploy, publish, tạo/đóng issue, xoá file hay nhánh, chạy lệnh lên môi trường thật.
- Mỗi yêu cầu dẫn tới thay đổi trong repo được ghi một mục vào `prompts/LOG.md` (cùng PR). Không thêm `Co-Authored-By` vào commit, không thêm "Generated with Claude Code" vào issue, mô tả PR, bình luận PR.
- Chỉ tuyên bố những gì đã chạy và quan sát được. Môi trường giả lập không thay thế môi trường thật.
- Luôn áp dụng `karpathy-guidelines` và các skill trong mục "Skill bổ trợ" của CLAUDE.md dự án. Skill nào chưa có trong danh sách skill khả dụng thì gợi ý người dùng lệnh cài (ví dụ `/plugin install andrej-karpathy-skills --marketplace multica-ai/andrej-karpathy-skills`), không tự cài. Việc lớn hoặc nhiều file thì dùng Plan mode trước. CLAUDE.md của dự án được ưu tiên hơn cấu hình agent toàn cục.
