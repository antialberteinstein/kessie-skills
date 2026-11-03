# CLAUDE.md

<!-- Giữ file này NGẮN (≤ ~120 dòng). Chỉ ghi điều agent không tự suy ra được từ code. Nếu dùng agent khác, tạo AGENTS.md trỏ về file này (hoặc ngược lại). -->

{{PROJECT_NAME}}: TODO một câu mô tả sản phẩm, nền tảng đích, ngôn ngữ ưu tiên của tài liệu/UI.
Loại dự án: TODO (app · web/SaaS · API · thư viện · CLI · site tĩnh · data/automation · extension/bot).

## Kiến trúc (đã quyết định — không mở lại khi chưa hỏi người dùng)

- TODO: ví dụ "Không có backend riêng; client gọi trực tiếp BaaS." Link ADR: docs/decisions/NNNN-*.md
- TODO: định danh/Auth ở đâu; dữ liệu ở đâu; job server ở đâu.
- TODO: phương án đã đánh giá và **bị loại** (để agent không đề xuất lại) — kèm lý do ngắn.
- Logic nghiệp vụ nằm ở: TODO. Tầng dữ liệu bảo vệ: TODO (quyền sở hữu, ràng buộc).

## Bố cục

- TODO: thư mục → trách nhiệm (một dòng mỗi mục).

## Lệnh

```bash
# TODO: typecheck && lint && format:check
# TODO: test / test:coverage (ngưỡng)
# TODO: test:e2e
# TODO: build
```

## Quy ước

- Tên file: TODO (kebab-case/snake_case/…). Formatter: TODO. Theo mật độ và idiom của code xung quanh.
- Chữ hiển thị: TODO (i18n bằng …). Thông báo lỗi: TODO.
- Không bao giờ hiển thị/log payload server, token, credentials hoặc dữ liệu cá nhân. Map mã lỗi đã biết.
- Logic mới cần test trong TODO. Thay đổi nhỏ, không sửa file không liên quan.

## Dữ liệu và bảo mật

- Migration append-only: TODO đường dẫn và quy ước tên. Không sửa migration đã áp dụng.
- Quyền truy cập: TODO (RLS/rules/middleware) — mọi bảng/collection người dùng đều có kiểm tra chủ sở hữu.
- Biến public chỉ gồm: TODO. Secret không bao giờ vào client hoặc git.

## Điểm dễ hỏng

- TODO: hành vi cố ý trông giống lỗi (fallback, timeout phạm vi hẹp…) — ghi để agent không "sửa".
- TODO: giới hạn môi trường dev (emulator/web preview không có …).

## Phiên bản và phát hành

- Version nằm ở: TODO. CHANGELOG theo Keep a Changelog, thêm thay đổi người dùng thấy vào [Unreleased].
- Quy trình: docs/WORKFLOW.md.

## Quy trình với AI agent

- Quy trình chi tiết nằm trong lệnh `/kessie-skills:proj <chế độ>` (người dùng tự gõ; agent không tự gọi, chỉ gợi ý chế độ phù hợp). Gõ `/kessie-skills:proj` không kèm chế độ để xem bước tiếp theo.
- Spec là của người dùng: `docs/RequirementsOutline.md`, `docs/modules/`, ý tưởng thô ở `docs/spec-inbox.md`. Agent đề xuất, người dùng duyệt; không tự sửa spec đã duyệt.
- Mọi thay đổi đi qua issue → nhánh → PR → CI. `Closes #N` chỉ khi đã xác minh; nếu còn phần chưa xác minh thì dùng `Refs #N`.
- **Lưu prompt dựng dự án vào `prompts/LOG.md`.** Mỗi yêu cầu của người dùng dẫn tới thay đổi trong repo (spec, thiết kế, kiến trúc, code, sửa lỗi, phát hành) được ghi một mục: ngày · lệnh/ngữ cảnh · yêu cầu (rút gọn, giữ ý định) · quyết định đã chốt · issue/PR. Ghi trong cùng PR với thay đổi; chỉ thêm mục mới, không sửa mục cũ. Không ghi secret, token, URL môi trường thật hay dữ liệu cá nhân.
- Hỏi người dùng trước khi push, mở PR, merge, gắn tag, release, deploy, publish, tạo issue, hoặc chạy lệnh lên môi trường thật.
- Giao diện theo `DESIGN.md` (nếu có); token nằm ở TODO.
- Luôn áp dụng các skill trong mục "Skill bổ trợ". Việc lớn hoặc nhiều file thì trình kế hoạch trong Plan mode trước. Nếu cấu hình agent toàn cục mâu thuẫn với file này, file này được ưu tiên.

## Skill bổ trợ

| Skill | Vai trò | Lệnh cài (Claude Code) |
|---|---|---|
| `karpathy-guidelines` ([multica-ai/andrej-karpathy-skills](https://github.com/multica-ai/andrej-karpathy-skills)) | Nghĩ trước khi code · đơn giản trước · sửa đúng chỗ · định nghĩa "xong" bằng tiêu chí kiểm chứng được. Luôn áp dụng | `/plugin install andrej-karpathy-skills --marketplace multica-ai/andrej-karpathy-skills` |

- **Đầu mỗi phiên**, kiểm tra từng skill trong bảng có nằm trong danh sách skill khả dụng của agent không. Thiếu skill nào thì **gợi ý** người dùng lệnh cài ở cột cuối, một lần mỗi phiên. **Không tự cài**, không sửa settings của người dùng.
- Khi skill chưa được cài, vẫn làm theo nguyên tắc ở cột "Vai trò".

## Git và PR

- Conventional commits; nhánh `feat/<issue>-…`, `fix/<issue>-…`, `docs/…`, `ci/…`, `chore/…`.
- **Không ghi attribution của AI:** không thêm dòng `Co-Authored-By` vào commit; không thêm "Generated with Claude Code" (hay dòng tương tự) vào issue, mô tả PR và bình luận PR. Quy tắc này được ưu tiên hơn mặc định của agent.
- PR theo .github/PULL_REQUEST_TEMPLATE.md. `Closes #N` chỉ khi đã xác minh; nếu không dùng `Refs #N` và nêu phần chưa xác minh.
- Chạy kiểm tra trước khi push; CI xanh trước khi merge.
