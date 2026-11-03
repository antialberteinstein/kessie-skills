# <Module> — Module breakdown

> Phân rã chi tiết để triển khai và nghiệm thu. Đặc tả cuối cùng vẫn là `docs/RequirementsOutline.md` §<mục>.

## 1. Khả năng cần đạt
- Người dùng có thể … (3–7 dòng, mỗi dòng kiểm chứng được)

## 2. Người dùng và màn hình
- Vị trí trong điều hướng; nút hoặc lối tắt mở tác vụ.
- Thành phần: danh sách, thẻ (số dòng), form hoặc trang nhập, bộ lọc, tìm kiếm.
- Trạng thái: trống, đang tải, lỗi, đang lưu; nhãn trợ năng.

## 3. Luồng và trạng thái
### 3.1. Thêm
1. …
### 3.2. Sửa, xoá, quay lại
- Bản nháp được giữ khi …; hủy xoá không mất dữ liệu; quay lại khi bàn phím mở chỉ ẩn bàn phím.

## 4. Quy tắc nghiệp vụ cố định
- Giá trị: <đơn vị, kiểu, giới hạn>. Ngày: <định dạng, có cho phép tương lai không>.
- Thứ tự: <khoá sắp xếp chính, phụ; thời điểm tạo do server gán và không đổi>.
- Quan hệ: <xoá mềm, khôi phục, tham chiếu bản ghi khác, chặn xoá khi đang được tham chiếu>.
- Tổng và thống kê: <tổng nào độc lập với bộ lọc>.

## 5. Hợp đồng dữ liệu
| Thực thể.trường | Kiểu | Ràng buộc | Ghi chú |
|---|---|---|---|
| `<entity>.owner_id` | id | bắt buộc; phân quyền chủ sở hữu ở tầng dữ liệu | |
| `<entity>.<ref>_id` | id | phải cùng chủ sở hữu | chặn tham chiếu chéo tài khoản |
| `<entity>.created_at` | timestamp | server gán, không đổi khi sửa | |

- Migration hoặc thay đổi rules cần có: <…> · Validation phía client: <schema nào>.

## 6. Nâng cấp và giới hạn
- Dữ liệu cũ thiếu trường mới: <cách đọc, cách hiển thị>.
- Giới hạn: <offline, realtime, …>.

## 7. Tiêu chí nghiệm thu
| Mã | Tình huống | Kết quả |
|---|---|---|
| AC-01 | Tài khoản mới | … |
| AC-02 | Nhập sai / biên | Không lưu, giữ dữ liệu để sửa |
| AC-03 | Thêm 3 bản ghi, reload, sửa bản đầu | Thứ tự đúng, sửa không đẩy bản cũ lên đầu |
| AC-04 | Tài khoản khác truy cập | Backend từ chối đọc và ghi |
| AC-05 | Lỗi mạng khi lưu | Không thành công giả, không ghi trùng, giữ bản nháp |
| AC-06 | Native: quay lại, lịch, bàn phím (cần thiết bị) | … |

## 8. Bàn giao
- Code, migration hoặc rules kèm test phân quyền, unit test, E2E, tài liệu triển khai nếu có.
- Ghi rõ đã kiểm tra gì và phần chưa xác minh trên môi trường thật.
