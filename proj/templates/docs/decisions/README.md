# Quyết định kiến trúc (ADR)

Mỗi quyết định quan trọng là một file `NNNN-tieu-de-ngan.md` (đánh số tăng dần, không sửa nội dung sau khi "Chấp nhận" — muốn đổi thì viết ADR mới với trạng thái "Thay thế NNNN").

| # | Tiêu đề | Trạng thái | Ngày |
|---|---|---|---|
| 0001 | TODO: Chọn stack và mô hình backend | Đề xuất | {{DATE}} |

## Mẫu

```markdown
# NNNN. <Tiêu đề>

- Trạng thái: Đề xuất | Chấp nhận | Bị loại | Thay thế bởi NNNN
- Ngày: YYYY-MM-DD · Người quyết định: <người dùng>

## Bối cảnh
<Vấn đề, ràng buộc (ngân sách, một người làm, nền tảng đích, dữ liệu nhạy cảm…).>

## Các phương án
| Phương án | Ưu | Nhược | Chi phí/khóa nhà cung cấp |
|---|---|---|---|

## Quyết định
<Chọn gì. Một đoạn.>

## Hệ quả
- Được: …  · Mất: …  · Việc phải làm: …
- Điều kiện xem xét lại: <khi nào mở lại quyết định này>
```

Phương án **bị loại** cũng ghi lại (trạng thái "Bị loại") để agent không đề xuất lại.
