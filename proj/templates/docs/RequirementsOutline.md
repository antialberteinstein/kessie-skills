# {{PROJECT_NAME}} — Requirements Outline

> Trạng thái: Nháp | Đã duyệt YYYY-MM-DD. Nguồn sự thật về hành vi sản phẩm; agent đề xuất, người dùng duyệt. Khi tài liệu khác (prompt, module breakdown, issue) mâu thuẫn, file này thắng. Cập nhật lần cuối: {{DATE}}.

## 1. Mục tiêu và phạm vi
- Người dùng: TODO. Vấn đề: TODO. Nền tảng: TODO. Loại dự án: TODO.
- Trong phạm vi v1: TODO (3–6 module).
- Ngoài phạm vi v1: TODO.

## 2. Điều hướng và giao diện (bỏ nếu không có UI; với CLI: danh sách lệnh và cờ; với API/thư viện: xem hợp đồng API)
- Cấu trúc điều hướng chính: TODO (ví dụ thanh dưới: A · B · (+) · C · Cài đặt).
- Nguyên tắc: mobile-first, không tràn ngang, sáng/tối, ngôn ngữ: TODO.

## 3. Module: TODO
### 3.1. Danh sách và tra cứu
### 3.2. Thêm/sửa/xóa
### 3.3. Dữ liệu hợp lệ (đơn vị tiền, ngày, giới hạn)
### 3.4. Thống kê / tổng hợp
<!-- Chi tiết luồng và tiêu chí nghiệm thu: docs/modules/<Module>.md -->

## 4. Tài khoản, cài đặt, thông báo
- Đăng nhập: TODO. Giữ phiên: TODO. Cài đặt: TODO. Nhắc nhở: TODO.

## 5. Dữ liệu và quyền
- Mỗi bản ghi thuộc một người dùng; backend từ chối truy cập chéo.
- Xóa mềm hay cứng: TODO. Dữ liệu mẫu cho tài khoản mới: TODO (có/không).

## 6. Chất lượng và nghiệm thu
- Unit/integration cho nghiệp vụ; E2E cho luồng chính; kiểm tra trên thiết bị/môi trường thật trước phát hành.
- Nghiệm thu từng module theo bảng AC trong docs/modules/.

## 7. Giới hạn hiện tại
- TODO (offline, realtime, đa tiền tệ…). Các mục ở đây là ứng viên cho roadmap.

## Lịch sử quyết định

| Ngày | Quyết định | Lý do | Ảnh hưởng (AC, dữ liệu cũ) |
|---|---|---|---|
| {{DATE}} | Khởi tạo đặc tả | — | — |
