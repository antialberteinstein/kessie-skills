# Dữ liệu, phân quyền, job nền

Cách triển khai theo từng nền tảng nằm trong `references/authz-patterns.md` (Postgres/Supabase RLS, Firebase Rules, backend riêng).

## Nguyên tắc bất biến

1. **Phân quyền ở tầng dữ liệu hoặc server, không bao giờ chỉ ở client.** Mọi bảng hoặc collection chứa dữ liệu người dùng có kiểm tra chủ sở hữu.
2. **Chặn tham chiếu chéo tài khoản:** bản ghi A trỏ tới bản ghi B thì B phải cùng chủ sở hữu (FK ghép `(owner_id, ref_id)`, rule kiểm tra `get(ref).owner == uid`, hoặc truy vấn có điều kiện owner).
3. **Migration chỉ thêm, không sửa:** file mới cho mỗi thay đổi, đánh số tăng dần. Không sửa file đã áp dụng ở bất kỳ môi trường nào.
4. **Ràng buộc quan trọng đặt cả ở DB** (check, unique, trigger), không chỉ ở validation phía client.
5. **Thời điểm tạo do server gán và không đổi khi sửa hoặc upsert.** Dùng làm khoá sắp xếp phụ ổn định. Dữ liệu cũ thiếu trường này phải đọc được.
6. **Hàm đặc quyền tối thiểu:** function, RPC hay admin SDK chỉ cấp cho đúng vai trò cần. Cố định `search_path` hoặc dùng tên đầy đủ. Kiểm tra danh tính bên trong hàm.
7. **Secret chỉ ở server** (service role, admin key, cron secret). Client chỉ có biến public.
8. **Hợp đồng lỗi:** trả mã lỗi ổn định. Client chỉ hiển thị thông báo đã map theo mã. Không trả stack trace hay payload nội bộ. Không log dữ liệu cá nhân, tài chính hay token.
9. **Không tạo dữ liệu mẫu trong tài khoản thật** nếu đặc tả không yêu cầu.

## Quy trình một thay đổi dữ liệu

1. Đọc hợp đồng dữ liệu trong module breakdown. Thiếu thì bổ sung cùng `/kessie-skills:proj kickoff` › requirements.
2. Viết migration hoặc rules mới theo mẫu của nền tảng.
3. **Viết test phân quyền trước khi áp dụng** (danh sách ở `references/authz-patterns.md` §Test):
   chủ sở hữu đọc và ghi được · tài khoản khác không đọc, sửa, xoá được · không tham chiếu chéo được · ẩn danh bị từ chối · ràng buộc chặn dữ liệu sai · timestamp không đổi khi sửa hoặc upsert · migration chạy lại an toàn nếu được thiết kế idempotent.
4. Chạy trên **DB hoặc emulator cô lập** (container Postgres, Firebase emulator), **không bao giờ** trên môi trường thật.
5. Nối suite test vào CI (danh sách suite phải rõ ràng) và README (lệnh chạy local).
6. Cập nhật schema phía client (zod, pydantic…) và tầng I/O. Trường mới cho phép null để đọc được dữ liệu cũ.
7. PR ghi rõ: migration nào cần áp dụng lên môi trường thật, theo cách nào. CHANGELOG có "Ghi chú nâng cấp".

## Áp dụng lên môi trường thật

- **Agent không tự chạy lệnh ghi lên production.** Agent chuẩn bị file và lệnh, người dùng xác nhận rồi mới chạy.
- Chọn **một** cách áp dụng ngay từ đầu (CLI có bảng lịch sử migration, hoặc thủ công qua console). Nếu buộc phải chạy tay, ghi lại và lên kế hoạch baseline trước khi quay về CLI.
- Trước khi áp dụng: chạy script chỉ đọc để xem hiện trạng. Sau khi áp dụng: xác minh bằng truy vấn dưới vai trò người dùng (trong transaction rồi rollback) và thử app thật. Ghi kết quả kèm ngày.
- Cần bản gói migration cho môi trường mới tinh: một script có guard, từ chối chạy nếu DB đã có bảng.

## Job nền, cron, push

- Endpoint của cron yêu cầu secret (header), chỉ nhận đúng method, không trả chi tiết lỗi.
- Chống gửi trùng bằng lease hoặc khoá idempotency. Có giới hạn retry. Vô hiệu hoá token thiết bị đã hỏng.
- **Fallback có chủ đích** khi dịch vụ tùy chọn chưa cấu hình (ví dụ không có push token thì dùng thông báo local). Ghi vào CLAUDE.md mục "Điểm dễ hỏng".
- Không cam kết "đúng phút" hay "đúng một lần" nếu hạ tầng không bảo đảm. Ghi rõ giới hạn trong README.

## Hiệu năng cơ bản

Index cho cột lọc và sắp xếp theo owner (`(owner_id, date)`). Chỉ select cột cần dùng. Phân trang khi danh sách có thể lớn. Policy RLS gọi hàm danh tính một lần mỗi câu lệnh (ví dụ `(select auth.uid())`).

Skill bên ngoài: `supabase`, `supabase-postgres-best-practices` (Supabase); `postgres-pro`, `api-designer`, `database-optimizer` (Jeffallan); plugin `database-design`, `backend-development`, `backend-api-security` (wshobson); `api-and-interface-design` (addyosmani).

## Service có deploy riêng (API, worker)

- Môi trường tách biệt: local → staging → production; cấu hình qua biến môi trường, có `.env.example`.
- Health check (`/healthz`) và readiness; log có cấu trúc, không chứa dữ liệu cá nhân; metrics tối thiểu (tỷ lệ lỗi, độ trễ).
- Migration tương thích ngược với bản đang chạy: expand (thêm cột hoặc bảng) → deploy code → migrate dữ liệu → contract (bỏ cái cũ) ở bản sau.
- Hợp đồng API (OpenAPI/schema) được cập nhật cùng PR; thay đổi phá vỡ tương thích thì tạo version mới hoặc có thời gian deprecation.
- Rollback được: giữ image hoặc bản build trước; migration không xoá dữ liệu trong cùng lần deploy.
