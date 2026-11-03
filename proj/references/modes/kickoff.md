# kickoff — Từ ý tưởng tới repo sẵn sàng code

Tham số (phần sau tên chế độ):
- Trống → hỏi người dùng muốn bắt đầu dự án mới, tiếp nhận dự án, hay thêm module.
- `tiếp nhận <repo>` → mục "Tiếp nhận dự án đang dở".
- `module <tên>` → chỉ chạy giai đoạn 1 (đặc tả) cho module mới. Thực ra đây là việc của `/kessie-skills:proj spec`; gợi ý người dùng dùng lệnh đó.
- Còn lại → coi là mô tả ý tưởng, bắt đầu từ giai đoạn 0.

Nguyên tắc: **đặc tả có trước code · quyết định được ghi lại · mọi thay đổi đi qua issue → PR → CI · "xong" phải có bằng chứng.** Sau khi khởi động, người dùng gọi `/kessie-skills:proj spec` (mô tả, thảo luận spec), `/kessie-skills:proj design` (giao diện), `/kessie-skills:proj build`, `/kessie-skills:proj ship`, `/kessie-skills:proj status`.



## Bước 0: xác định loại dự án (bắt buộc)

Đọc `references/project-types.md`. Xếp dự án vào một hoặc nhiều loại: app có dữ liệu người dùng · web/SaaS nhiều người dùng · API/service · thư viện/SDK · CLI · site tĩnh · data/automation · extension/bot/tích hợp. Loại dự án quyết định: giai đoạn nào làm đầy đủ hay rút gọn, nhóm AC bắt buộc, lớp kiểm thử, và kênh phát hành. Ghi loại dự án vào idea brief và CLAUDE.md.

## Giai đoạn và cổng chuyển tiếp

| # | Giai đoạn | Đọc | Đầu ra | Cổng |
|---|---|---|---|---|
| 0 | Ý tưởng | `references/requirements.md` §1, `references/idea-brief-template.md`. Làm theo cách của spec §2: người dùng là người chốt | Idea brief 1 trang, có loại dự án | Người dùng duyệt phạm vi v1 và phần ngoài phạm vi |
| 1 | Đặc tả | `references/requirements.md`, `references/module-breakdown-template.md`, và quy trình của `references/modes/spec.md` | `docs/RequirementsOutline.md`, `docs/modules/*.md` có bảng AC | Người dùng duyệt; mỗi khả năng có AC kiểm chứng được, gồm các nhóm AC bắt buộc theo loại dự án |
| 2 | Kiến trúc | `references/architecture.md`, `references/stack-options.md` | ADR cho các quyết định áp dụng với loại dự án; ADR cho phương án bị loại | Người dùng chấp nhận ADR |
| 2b | Thiết kế (chỉ khi có UI) | `references/modes/design.md` §1–3 (script `<skill-dir>/scripts/design-md.sh`) | `DESIGN.md` (mẫu đã chọn hoặc tự soạn) + ADR thiết kế | Người dùng chọn hoặc duyệt DESIGN.md |
| 3 | Nền repo | `references/repo-setup.md`, `references/agent-setup.md` | Git, scaffold, CLAUDE.md (có 3 quy tắc bắt buộc bên dưới), `prompts/LOG.md` có mục kickoff, CI xanh trên khung rỗng, `main` được bảo vệ | Commit đầu tiên đã push, CI xanh |
| 4 | Kế hoạch | `references/agent-setup.md` §2, `references/task-prompt-template.txt` | `prompts/NN-*.txt` (nếu xây qua nhiều giai đoạn), milestone 0.1.0, issue (gợi ý người dùng gọi `/kessie-skills:proj plan`) | Backlog nằm trong issue tracker |

Không bỏ cổng. Dự án nhỏ (CLI, thư viện, site tĩnh) được rút gọn theo `project-types.md`, nhưng tối thiểu vẫn phải có: idea brief + ADR stack + CLAUDE.md + CI, rồi mới viết code.

```bash
<skill-dir>/scripts/scaffold.sh <repo> --name "Tên dự án"           # chạy thử
<skill-dir>/scripts/scaffold.sh <repo> --name "Tên dự án" --apply   # ghi, không ghi đè file đã có
```

CLAUDE.md do scaffold tạo có sẵn mục "Quy trình với AI agent", liệt kê các chế độ của `/kessie-skills:proj`. Skill này **không tự kích hoạt**: agent chỉ gợi ý lệnh phù hợp để người dùng gọi.

**Quy tắc bắt buộc trong CLAUDE.md** (giữ nguyên khi điền TODO, không lược bỏ; repo đã có CLAUDE.md thì bổ sung vào):
1. Lưu prompt dựng dự án vào `prompts/LOG.md` (mục "Quy trình với AI agent"). Ngay khi scaffold xong, ghi mục đầu tiên trong `prompts/LOG.md`: yêu cầu kickoff và các quyết định của giai đoạn 0–2.
2. Không ghi attribution của AI: không `Co-Authored-By` trong commit; không "Generated with Claude Code" trong issue, mô tả PR, bình luận PR (mục "Git và PR"). Áp dụng ngay từ commit đầu tiên của kickoff.
3. Mục "Skill bổ trợ": bảng skill bổ trợ cho proj (hiện là `karpathy-guidelines`) kèm lệnh cài, và quy tắc "skill chưa cài thì agent gợi ý lệnh cài, không tự cài". Ngay trong kickoff, nếu skill trong bảng chưa có trong danh sách skill khả dụng thì gợi ý người dùng lệnh cài. Sau khi có ADR chọn stack, nếu stack có skill chính chủ (phụ lục của `docs/RECOMMENDED-SKILLS.md` trong repo [kessie-skills](https://github.com/antialberteinstein/kessie-skills/blob/main/docs/RECOMMENDED-SKILLS.md)), hỏi người dùng có muốn thêm vào bảng không.

## Tiếp nhận dự án đang dở

1. Chạy `<skill-dir>/scripts/project-snapshot.sh <repo>` để biết trạng thái thật.
2. Xác định loại dự án (bước 0), rồi đối chiếu bảng trên: thiếu ADR, CLAUDE.md, CI, hay backlog đang nằm rải rác?
3. **Bổ sung, không viết lại:** viết lại ADR từ lịch sử (ghi rõ "ghi lại hồi tố"), tạo CLAUDE.md từ code thật (kèm 3 quy tắc bắt buộc ở trên; CLAUDE.md đã có thì chỉ thêm 3 quy tắc đó), tạo `prompts/LOG.md` nếu chưa có, gom backlog về tracker. Trình danh sách lỗ hổng theo thứ tự ưu tiên để người dùng chọn.

## 10 bài học (áp dụng từ ngày đầu)

1. Commit từ ngày đầu, mỗi giai đoạn là một PR. Một "Initial commit" gộp nhiều giai đoạn sẽ làm mất lịch sử quyết định.
2. Chỉ một nơi theo dõi công việc (issue tracker). File TODO hoặc STATUS chạy song song sẽ nhanh chóng lệch.
3. Ghi cả phương án bị loại (ADR "Bị loại"), nếu không agent sẽ đề xuất lại.
4. Hành vi cố ý trông như lỗi (fallback, timeout chỉ cho một phạm vi) phải ghi vào CLAUDE.md, nếu không agent sẽ "sửa".
5. Môi trường giả lập (web preview, emulator, mock, DB cô lập, build) ≠ môi trường thật. Luôn nêu phần chưa xác minh.
6. Chọn một cách áp dụng thay đổi lên môi trường thật (migration, deploy, publish) ngay từ đầu; trộn hai cách sẽ mất lịch sử.
7. Quyết định sớm có chế độ demo hoặc dữ liệu mẫu hay không.
8. Cấu hình agent toàn cục của dự án khác có thể mâu thuẫn. CLAUDE.md dự án phải ghi rõ nó được ưu tiên.
9. Cấu hình Dependabot `ignore` cho các gói do framework ghim phiên bản ngay khi tạo repo.
10. Sửa lỗi hạ tầng thì giới hạn đúng phạm vi bị lỗi, không áp dụng toàn cục.

## Luôn hỏi người dùng trước khi

Chọn hoặc đổi stack và kiến trúc; tạo repo GitHub hay đổi visibility; push, mở PR, merge, gắn tag, publish; chạy lệnh lên môi trường thật; tạo hay đóng issue, milestone, label; xoá file hay nhánh; thêm dịch vụ trả phí.

Dùng kèm: `karpathy-guidelines`; Plan mode cho việc lớn.
