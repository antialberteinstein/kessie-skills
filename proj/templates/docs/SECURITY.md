# Security notes — {{PROJECT_NAME}}

## Biện pháp đã triển khai
- Xác thực: TODO (nhà cung cấp, nơi lưu token trên client — keychain/secure storage, không localStorage cho token dài hạn).
- Phân quyền: TODO (RLS/rules/middleware). Mọi dữ liệu người dùng bị giới hạn theo chủ sở hữu; tham chiếu chéo tài khoản bị chặn ở tầng dữ liệu.
- Kiểm tra đầu vào: TODO (schema ở client + ràng buộc ở DB).
- Lỗi: chỉ hiển thị thông báo đã map theo mã; không hiển thị/log payload server, token, credentials.
- Secret: chỉ biến public trong client; secret nằm ở server/vault/CI secrets.
- Log: không log dữ liệu cá nhân hoặc tài chính.

## Dependency audit
- Lệnh: TODO (npm audit --omit=dev / pip-audit / cargo audit …). Ngày chạy gần nhất: TODO, kết quả: TODO.
- Cảnh báo đã biết và lý do chấp nhận tạm thời: TODO. Không dùng "fix --force" làm hạ cấp framework.

## Giới hạn vận hành
- TODO: những gì CHƯA được kiểm toán/xác minh (ví dụ rate limit, SMTP, cấu hình production).
