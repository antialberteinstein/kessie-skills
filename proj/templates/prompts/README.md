# Prompt giao việc — {{PROJECT_NAME}}

Mỗi file `NN-slug.txt` là một giai đoạn xây dựng có thể giao cho coding agent: VAI TRÒ VÀ BỐI CẢNH · MỤC TIÊU · PHẠM VI · NGOÀI PHẠM VI · ĐẦU RA · TIÊU CHÍ HOÀN THÀNH. Chạy theo thứ tự; prompt sau bổ sung lên kết quả trước. `docs/RequirementsOutline.md` là đặc tả cuối cùng và thắng khi mâu thuẫn.

| File | Mục đích | Issue/PR |
|---|---|---|
| 01-foundation.txt | TODO: nền tảng (auth, dữ liệu, điều hướng, CI) | |

## Quy tắc biên tập
- Giữ ý định sản phẩm; bỏ hội thoại; gộp các lời phê duyệt vào prompt.
- Không tạo prompt chỉ để sửa lỗi — lỗi là issue.
- Không chứa URL dự án thật, mật khẩu, key, token, dữ liệu tài khoản.
- Mỗi prompt kết thúc bằng tiêu chí hoàn thành quan sát được và câu "không tuyên bố đã xác minh môi trường thật khi chưa có bằng chứng".
