# Bảo mật (baseline và review PR)

## Baseline (thiết lập ở giai đoạn 3, ghi vào `docs/SECURITY.md`)

| Mảng | Yêu cầu |
|---|---|
| Secret | Client chỉ có biến public (URL, publishable key, project ID). Service role, admin key, cron secret nằm ở server, vault hoặc CI secret. `.env*` và file credentials được gitignore. `.env.example` chỉ chứa placeholder |
| Token phiên | Native: keychain/keystore (secure storage). Web: tránh localStorage cho token dài hạn. Có auto-refresh, đăng xuất xoá sạch |
| Phân quyền | Ở tầng dữ liệu hoặc server, có test truy cập chéo (`/kessie-skills:proj build` › backend). Hàm đặc quyền tối thiểu |
| Đầu vào | Schema ở client và ràng buộc ở DB. Parser không dùng `eval`/`Function`. Không render HTML do người dùng nhập |
| Lỗi và log | Map mã lỗi đã biết (whitelist bằng regex), không hiển thị hay log payload server, token, email, số tiền. Chỉ có "mã hỗ trợ" an toàn |
| Lưu trữ file | Bucket private, đường dẫn theo user ID, signed URL ngắn hạn, giới hạn MIME và kích thước |
| Timeout và retry | Đặt theo phạm vi (ví dụ chỉ cho Auth), không áp dụng toàn cục làm hỏng upload hay ghi chậm hợp lệ |
| CI | `permissions: contents: read` mặc định, `persist-credentials: false`, secret chỉ ở job hoặc environment cần dùng, không chạy secret trên PR từ fork |

## Checklist review bảo mật cho PR

- [ ] Diff không chứa secret: `git diff origin/main... | grep -inE 'secret|password|private_key|service_role|api[_-]?key|token'` (xem từng kết quả, có thể là dương tính giả).
- [ ] Bảng, collection hay endpoint mới có phân quyền và test truy cập chéo.
- [ ] Không có biến public mới mang giá trị bí mật.
- [ ] Thông báo lỗi mới không lộ chi tiết nội bộ; log mới không có dữ liệu cá nhân.
- [ ] Quyền nền tảng mới (camera, vị trí…) có lý do và có mô tả quyền.
- [ ] Dependency mới: còn được bảo trì, license phù hợp, không có cảnh báo nghiêm trọng.

## Ghi chú bảo mật trung thực

`docs/SECURITY.md` ghi những gì **đã** làm, những gì **chưa** kiểm toán (rate limit, SMTP, cấu hình production), và kết quả audit kèm ngày. Không tuyên bố "đã kiểm toán bảo mật" khi chỉ chạy công cụ tự động.

Skill bên ngoài: `security-review`, `gha-security-review`, `find-bugs` (getsentry); bộ audit của trailofbits; `security-and-hardening` (addyosmani); `secure-code-guardian` (Jeffallan); plugin `security-guidance`, `security-scanning` (wshobson); `expo-upgrade`/`upgrading-react-native` khi nâng mobile framework.
