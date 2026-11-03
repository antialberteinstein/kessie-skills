# Quản lý dependency


**Dependabot** (`/kessie-skills:proj kickoff` › repo-setup đã tạo): mỗi tuần, giới hạn số PR, gom nhóm các gói đi cùng nhau, `ignore` major của các gói do framework ghim phiên bản.

Triage một PR cập nhật:

| Tình huống | Đề xuất (người dùng duyệt) |
|---|---|
| Patch hoặc minor của thư viện thuần, CI xanh | Merge |
| Gói native hoặc plugin của framework, nằm trong dải tương thích (kiểm bằng công cụ của framework, ví dụ `npx expo install --check`, `flutter pub outdated`) | Merge, ghi chú cần build lại |
| Gói do framework ghim, vượt dải tương thích | Đóng kèm bình luận "nâng cùng framework", thêm rule `ignore` |
| CI đỏ | Đọc log. Sửa nhỏ thì làm PR riêng; nếu không thì đóng và tạo issue |

**Nâng framework hoặc SDK** (issue `[Chore]` riêng): đọc release notes → dùng công cụ nâng cấp chính thức → rà các chỗ trong code import nội bộ thư viện (ghi trong mục "Điểm dễ hỏng" của CLAUDE.md) → chạy đủ cổng kiểm tra và build → audit lại → CHANGELOG "Bảo trì" và "Ghi chú nâng cấp" → kiểm chứng trên thiết bị bằng bản build mới.

**Audit:** chạy `npm audit --omit=dev`, `pip-audit`, `cargo audit`… mỗi lần release. Cảnh báo không có bản vá tương thích thì ghi vào `docs/SECURITY.md` (advisory, đường lây, lý do chấp nhận tạm thời). **Không dùng `audit fix --force`** khi nó đề xuất hạ cấp framework. Cảnh báo mới ở dependency runtime thì tạo issue.

