# Quyết định kiến trúc và ADR

Nguyên tắc: **agent đề xuất, người dùng quyết định, ADR ghi lại.** Quyết định đã "Chấp nhận" chỉ mở lại khi người dùng yêu cầu hoặc khi điều kiện xem xét lại trong ADR xảy ra.

## 1. Thu thập ràng buộc (từ idea brief)

Nền tảng đích · số người dùng và có chia sẻ dữ liệu không · offline/realtime · dữ liệu nhạy cảm · ngân sách (gói miễn phí?) · kỹ năng sẵn có của người dùng · thời gian · có cần job nền hoặc push không · phân phối (store, APK/TestFlight nội bộ, web).

## 2. Các quyết định cần có (mỗi quyết định một ADR)

| # | Quyết định | Câu hỏi then chốt |
|---|---|---|
| 1 | Nền tảng và framework client | Một codebase cho nhiều nền tảng? Có cần native API sâu không? |
| 2 | Backend: BaaS hay backend riêng | Có logic phải chạy ở server (bí mật, tổng hợp nhiều người dùng, thanh toán) không? Nếu không, BaaS + phân quyền ở tầng dữ liệu thường đủ |
| 3 | Định danh và Auth | Nhà cung cấp nào giữ danh tính? **Một nguồn danh tính duy nhất** (trộn hai hệ thống Auth sẽ cần claim tuỳ chỉnh, admin code và gói trả phí) |
| 4 | Mô hình phân quyền dữ liệu | RLS / security rules / middleware; cách chặn tham chiếu chéo tài khoản; ai được gọi hàm đặc quyền |
| 5 | Nơi đặt logic nghiệp vụ và validation | Client (schema dùng chung) với DB giữ toàn vẹn, hay server làm nguồn sự thật? |
| 6 | Job nền, push, lịch | Cron hoặc edge function; push provider; fallback khi thiếu cấu hình |
| 7 | Phân phối và phiên bản | Store hay nội bộ; ai quản lý build number; cập nhật OTA không? |
| 8 | Chiến lược kiểm thử | Unit / E2E (backend giả lập) / DB cô lập / thiết bị thật: công cụ cho từng lớp |

Mẫu ma trận và các bộ stack tham khảo: `references/stack-options.md`. Mẫu ADR: `templates/docs/decisions/README.md`.

## 3. Cách trình bày lựa chọn cho người dùng

- Tối đa 2–3 phương án thực sự khả thi. **Nêu một khuyến nghị** kèm lý do, không liệt kê dàn trải.
- Mỗi phương án có: ưu, nhược, chi phí và mức phụ thuộc nhà cung cấp, rủi ro với ràng buộc của dự án, và "điều gì khiến ta phải đổi sau này".
- Khi một phương án cần bước trả phí hoặc cần đặt secret quản trị ở nơi khác, nói rõ ngay.

## 4. Ghi ADR

- `docs/decisions/NNNN-slug.md`, trạng thái `Đề xuất` → `Chấp nhận` (sau khi người dùng đồng ý) hoặc `Bị loại`.
- **Phương án bị loại cũng ghi ADR** ngắn kèm lý do. Đây là cách duy nhất để agent về sau không đề xuất lại.
- Tóm tắt các quyết định "Chấp nhận" vào mục "Kiến trúc (đã quyết định)" của `CLAUDE.md` (`/kessie-skills:proj kickoff` › agent-setup), mỗi dòng có link ADR.
- Có thể lưu vào memory của agent: "quyết định X ngày Y, lý do Z, đừng đề xuất lại W".

## 5. Đánh giá lại một quyết định

Khi người dùng muốn đổi (ví dụ chuyển Auth sang nhà cung cấp khác):

1. Đọc ADR gốc và điều kiện xem xét lại.
2. Làm spike nhỏ hoặc đọc tài liệu chính thức: liệt kê **mọi** bước cần thiết (claim, quyền admin, gói trả phí, migration dữ liệu người dùng, ảnh hưởng tới phân quyền).
3. Trình bày chi phí chuyển đổi so với lợi ích. Người dùng quyết định.
4. Ghi kết quả: ADR mới "Thay thế NNNN" hoặc ADR "Bị loại". Code thử nghiệm của phương án bị loại phải được xoá (không để file test hay nhánh mồ côi).

## Chống mẫu

- Chọn stack theo xu hướng mà không đối chiếu ràng buộc.
- Đặt secret quản trị trong client vì tiện.
- Phân quyền chỉ ở client.
- Hai nguồn danh tính.
- Không có fallback khi dịch vụ tùy chọn (push) chưa cấu hình.
- Kiến trúc "phòng khi cần" (microservices, queue) cho app một người dùng.

Skill bên ngoài: `architecture-designer` (Jeffallan), `senior-architect` (alirezarezvani), `documentation-and-adrs` (addyosmani), plugin `c4-architecture` (wshobson).
