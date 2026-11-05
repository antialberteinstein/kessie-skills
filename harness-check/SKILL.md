---
name: harness-check
description: Kiểm tra cấu hình Claude Code (user và project hiện tại), báo lỗi, chồng chéo và đề xuất cách sửa
disable-model-invocation: true
---

# /harness-check

Kiểm tra cấu hình harness rồi báo cáo. Mặc định **chỉ đọc**: không sửa gì nếu người
dùng chưa đồng ý từng mục.

Yêu cầu thêm (có thể trống): $ARGUMENTS. Ví dụ: `offline`, `sửa luôn`.

## 1. Chạy script
```bash
bash "${CLAUDE_SKILL_DIR}/scripts/harness-check.sh"            # có gọi mạng
bash "${CLAUDE_SKILL_DIR}/scripts/harness-check.sh" --offline  # nếu người dùng yêu cầu offline
```
Chạy từ thư mục hiện tại để script kiểm tra cả project. Kết quả của script là sự thật
duy nhất; không tự suy thêm lỗi mà script không báo.

## 2. Báo cáo
- Gom theo mức: **FAIL** trước, rồi **WARN**. Bỏ các dòng OK, chỉ nói tổng số.
- Mỗi mục: lỗi là gì, vì sao đáng lo (một câu), cách sửa cụ thể (lệnh hoặc đoạn JSON).
- Với lỗi `secret`: tuyệt đối không đọc hay in giá trị. Chỉ nêu tên biến và khuyên
  chuyển sang biến môi trường của shell hoặc trình quản lý mật khẩu.
- Nếu không có FAIL hay WARN: nói một câu là cấu hình ổn, kèm số liệu context.

## 3. Sửa (chỉ khi người dùng đồng ý)
Hỏi người dùng muốn sửa những mục nào. Với mỗi mục được đồng ý:
- Sửa JSON bằng `jq`, giữ nguyên key khác; sao lưu file trước: `cp f f.bak-$(date +%s)`.
- Không xoá file. Thứ cần bỏ thì chuyển vào `~/claude-leftovers/` và báo đã chuyển gì.
- Gỡ plugin bằng `claude plugin uninstall`, không xoá cache bằng tay.
- Không sửa `CLAUDE.md` ngoài đúng dòng liên quan tới lỗi.

Sửa xong, chạy lại script và báo kết quả mới.
