# build — Issue → code → PR

Tham số (phần sau tên chế độ):
- Số issue (`12`, `#12`) → `gh issue view <số> --comments`.
- Mô tả → đề xuất tạo issue trước, theo đúng quy trình `references/modes/lead.md` §2a (mẫu `references/issue-templates.md`), để giữ một backlog duy nhất. Người dùng duyệt nội dung rồi mới `gh issue create`. Việc rất nhỏ (sửa chữ, cấu hình) mà người dùng không muốn tạo issue thì làm luôn, PR không có `Closes`.
- Trống → hỏi việc cần làm.

Đọc loại dự án và lệnh kiểm tra trong CLAUDE.md của repo trước khi bắt đầu.

## Đọc khi cần

| Khi chạm vào | Đọc |
|---|---|
| Schema, migration, rules, API, function, cron, push, storage, deploy service | `references/backend.md` |
| Mẫu phân quyền (chủ sở hữu, nhiều người dùng/tenant, Firebase, backend riêng) và danh sách test | `references/authz-patterns.md` |
| Màn hình, component, điều hướng, form, i18n, theme, E2E | `references/frontend.md` |
| Thư viện, CLI hoặc dự án không có UI hay dữ liệu người dùng | §"Loại dự án khác" bên dưới |
| Viết PR body | `references/pr-body-template.md` |

## Quy trình

0. **Hiểu việc:** xác định AC (từ `docs/modules/*.md`, hoặc viết 2–5 tiêu chí rồi xác nhận với người dùng). Bug thì **tái hiện trước khi sửa** (test thất bại, E2E với mock, môi trường cô lập). Đụng ADR thì dừng lại, hỏi người dùng. Việc lớn hoặc đụng nhiều file thì vào **Plan mode** trình kế hoạch trước.
1. **Nhánh:** `git switch main && git pull && git switch -c fix/N-slug` (hoặc `feat/N-…`, `docs/…`, `ci/…`, `chore/…`).
2. **Làm:** chỉ sửa file liên quan. Logic mới thì viết test trước. Dữ liệu mới thì migration + test phân quyền trên môi trường cô lập. UI mới thì E2E. Dependency mới thì hỏi trước. Sửa lỗi hạ tầng thì giới hạn đúng phạm vi.
3. **Cổng kiểm tra** (lệnh trong CLAUDE.md): typecheck · lint · format check · test (coverage nếu đụng file lõi) · e2e (nếu đổi UI) · test DB (nếu đổi dữ liệu) · build. Ghi số test đã qua; bước nào bỏ qua thì nêu lý do.
4. **CHANGELOG:** thay đổi người dùng hoặc người dùng thư viện nhìn thấy được thì thêm vào `[Unreleased]`, kèm link PR và issue.
5. **Commit:** `fix(scope): …`, tiêu đề ≤ 72 ký tự. Sửa theo review là commit mới. Tuân theo quy định attribution của người dùng.
6. **PR (chỉ khi người dùng đồng ý):** `git push -u origin HEAD && gh pr create --base main --body-file …`.
   - `Closes #N`: đã xác minh trong môi trường mà lỗi xảy ra.
   - `Refs #N`: còn phần chưa xác minh; nêu cụ thể.
7. **Sau khi mở PR:** `gh pr checks --watch`. CI đỏ thì `gh run view --log-failed`. Không force-push khi đã có review. Merge do người dùng làm.

## Loại dự án khác

- **Thư viện/SDK:** mọi thay đổi API công khai phải có test và tài liệu (docstring, README, ví dụ). Thay đổi phá vỡ tương thích thì đánh dấu `feat!:`/`BREAKING CHANGE`, ghi vào CHANGELOG mục "Thay đổi", và cần người dùng đồng ý. Giữ ma trận phiên bản runtime được hỗ trợ trong CI.
- **CLI:** cờ và lệnh con ổn định; `--help` cập nhật; mã thoát (0 thành công, khác 0 lỗi); stdout dành cho dữ liệu, stderr cho thông báo; test dạng golden (so khớp output); không prompt khi không có TTY.
- **API/service:** cập nhật hợp đồng (OpenAPI/schema) cùng PR; test API cho 401, 403/404, 422; migration tương thích ngược với bản đang chạy (expand → migrate → contract).
- **Site tĩnh:** kiểm tra link hỏng, a11y, kích thước trang và ảnh; xem preview deploy trước khi merge.
- **Data/automation:** đầu vào và đầu ra có schema; chạy lại cho cùng kết quả (idempotent); không commit dữ liệu thật hay secret; có dry-run.

## Trước khi báo "xong"

- [ ] AC có bằng chứng, hoặc ghi rõ phần chưa xác minh.
- [ ] Cổng kiểm tra đạt; diff, log, ảnh không chứa secret hay dữ liệu cá nhân.
- [ ] Cập nhật CHANGELOG; cập nhật CLAUDE.md nếu có lệnh mới hoặc cạm bẫy mới; cập nhật README nếu có bước triển khai mới.

Dùng kèm: `karpathy-guidelines`; skill chính chủ của stack nếu đã cài.
