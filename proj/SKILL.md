---
name: proj
description: "Quy trình dự án cho một người làm cùng AI agent, mọi loại dự án và stack — khởi động, spec (người dùng chốt), DESIGN.md, tạo issue, build issue → PR, kiểm chứng, phát hành, trạng thái và bảo trì. Dùng khi người dùng muốn bắt đầu hoặc tiếp nhận dự án, mô tả/thảo luận tính năng, chọn giao diện, tạo issue hay lên kế hoạch, làm một issue, kiểm chứng hay phát hành, hỏi trạng thái hoặc bước tiếp theo — kể cả khi không gõ lệnh, nhất là khi CLAUDE.md dự án trỏ tới proj. Tham số: từ đầu là chế độ (kickoff, spec, design, issue, plan, build, ship, status, report, triage, deps); trống thì gợi ý bước tiếp theo."
argument-hint: "[(trống) | kickoff | spec | design | issue | plan | build | ship | status | report | triage | deps] …"
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

## Tự gọi skill (người dùng không cần gõ lệnh)

Agent tự gọi skill này bằng Skill tool, tham số là `<chế độ> <tham số>`:

- Yêu cầu của người dùng khớp rõ một chế độ thì gọi luôn chế độ đó và nói một dòng "Dùng proj `<chế độ>` để …". Ví dụ: "có ý tưởng app X" → `kickoff X`; "thêm tính năng lọc" → `spec thêm tính năng lọc`; "làm issue #12" → `build #12`; "giờ làm gì tiếp" → trống. Không chắc chế độ nào thì hỏi lại.
- Trong file chế độ, chỗ ghi "người dùng gọi" hoặc "gợi ý người dùng gọi `/kessie-skills:proj <chế độ>`" nghĩa là: hỏi người dùng có muốn sang bước đó không; người dùng đồng ý thì agent tự gọi chế độ đó, không bắt gõ lại. **Không tự chuyển giai đoạn khi người dùng chưa đồng ý**: cổng duyệt giữ nguyên.
- Trong lúc làm, tự gọi các skill ở mục "Skill bổ trợ" của CLAUDE.md dự án khi tình huống khớp cột "Khi nào gọi", trước khi làm phần việc đó.
- Tự gọi skill không thay cho việc hỏi trước các thao tác ở §Nguyên tắc chung.

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

3. Trả lời ngắn: tình trạng hiện tại (3–5 dòng), **một** bước đề xuất kèm lý do, tối đa 2 phương án thay thế. Hỏi người dùng có làm bước đó không; đồng ý thì tự gọi chế độ tương ứng.

## Nguyên tắc chung (mọi chế độ)

- **Spec là của người dùng.** Agent đề xuất, người dùng chốt; không tự sửa spec đã duyệt.
- Mọi thay đổi đi qua issue → nhánh → PR → CI. `Closes #N` chỉ khi đã xác minh; nếu chưa thì `Refs #N` và nêu phần chưa xác minh.
- **Hỏi trước** khi push, mở PR, merge, gắn tag, release, deploy, publish, tạo/đóng issue, xoá file hay nhánh, chạy lệnh lên môi trường thật.
- Mỗi yêu cầu dẫn tới thay đổi trong repo được ghi một mục vào `prompts/LOG.md` (cùng PR). Không thêm `Co-Authored-By` vào commit, không thêm "Generated with Claude Code" vào issue, mô tả PR, bình luận PR.
- Chỉ tuyên bố những gì đã chạy và quan sát được. Môi trường giả lập không thay thế môi trường thật.
- Luôn áp dụng `karpathy-guidelines` và **tự gọi** (Skill tool) các skill trong mục "Skill bổ trợ" của CLAUDE.md dự án khi tình huống khớp, không chờ người dùng gõ lệnh. Skill nào chưa có trong danh sách skill khả dụng thì gợi ý người dùng lệnh cài (ví dụ `/plugin install andrej-karpathy-skills --marketplace multica-ai/andrej-karpathy-skills`), không tự cài. Việc lớn hoặc nhiều file thì dùng Plan mode trước. CLAUDE.md của dự án được ưu tiên hơn cấu hình agent toàn cục.
