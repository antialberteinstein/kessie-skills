# Từ ý tưởng tới đặc tả kiểm chứng được

## Cấu trúc tài liệu 3 tầng

| Tầng | File | Vai trò |
|---|---|---|
| 1 | `docs/RequirementsOutline.md` | Hành vi sản phẩm đã chốt. **Thắng khi có mâu thuẫn.** Khung có sẵn trong `templates/docs/` |
| 2 | `docs/modules/<Module>.md` | Phân rã từng module: màn hình, luồng, quy tắc, dữ liệu, AC. Mẫu: `references/module-breakdown-template.md` |
| 3 | `prompts/NN-*.txt` và issue | Giao việc theo giai đoạn (`/kessie-skills:proj kickoff` › agent-setup) và theo PR (`/kessie-skills:proj status`) |

## 1. Idea brief (giai đoạn 0)

Hỏi **từng câu một**, mỗi câu kèm một đề xuất mặc định để người dùng chỉ cần gật hoặc sửa:

1. Ai dùng, trong tình huống nào, đang giải quyết bằng cách gì?
2. Ba việc quan trọng nhất người dùng phải làm được ở v1?
3. Nền tảng: mobile, web hay cả hai? Có cần offline, đa thiết bị, đa người dùng chung dữ liệu không?
4. Dữ liệu nhạy cảm (tài chính, sức khoẻ, vị trí)? Kéo theo yêu cầu bảo mật nào?
5. Ngoài phạm vi v1 là gì? (Đây là câu quan trọng nhất để chặn phình phạm vi.)
6. Ngôn ngữ giao diện và tài liệu? Đơn vị tiền, múi giờ, định dạng ngày?

Đầu ra là mẫu `references/idea-brief-template.md`, tối đa 1 trang, người dùng duyệt xong mới viết đặc tả.

## 2. Requirements Outline

- Mỗi module là một mục, mô tả **hành vi quan sát được**, không mô tả cách cài đặt.
- Có mục "Điều hướng và giao diện" sớm (cấu trúc tab hoặc menu), vì quyết định này ảnh hưởng mọi module.
- Có mục "Dữ liệu và quyền": ai sở hữu bản ghi, xoá mềm hay xoá cứng, có dữ liệu mẫu cho tài khoản mới không.
- Mục "Giới hạn hiện tại" là danh sách ứng viên cho roadmap.

## 3. Module breakdown và tiêu chí nghiệm thu

- Theo `references/module-breakdown-template.md` (8 mục: khả năng, màn hình, luồng, quy tắc cố định, hợp đồng dữ liệu, nâng cấp và giới hạn, AC, bàn giao).
- **Quy tắc nghiệp vụ cố định** phải viết thành câu kiểm chứng được. Ví dụ: "tiền là số nguyên, dương, tối đa X", "ngày không được ở tương lai", "sắp xếp: ngày giảm dần, cùng ngày thì thời điểm tạo giảm dần; thời điểm tạo do server gán và không đổi khi sửa".
- Bảng AC: `| AC-NN | Tình huống | Kết quả |`. Đánh số tăng tiếp, không đánh lại. Mỗi AC dùng được làm test. Luôn có các nhóm sau **nếu áp dụng**, cộng thêm nhóm AC bắt buộc của loại dự án trong `references/project-types.md`:
  - trạng thái trống, nhập sai hoặc biên, hủy thao tác không mất dữ liệu;
  - reload hoặc mở lại app giữ dữ liệu và thứ tự;
  - **tài khoản khác bị backend từ chối** đọc và ghi;
  - hành vi native hoặc thiết bị (Back, bàn phím, quyền) nếu có UI nhập liệu, đánh dấu "cần thiết bị";
  - lỗi mạng hoặc lỗi server không gây "thành công giả" hay ghi trùng.

## 4. Khi yêu cầu thay đổi

1. Sửa RequirementsOutline trước, rồi module breakdown (thêm hoặc sửa AC, không xoá lịch sử nếu hành vi cũ còn có giá trị tham khảo).
2. Prompt cũ giữ nguyên làm lịch sử. Hành vi mới đi vào prompt hoặc issue mới.
3. Ghi trong PR tài liệu: AC nào thêm hoặc đổi, ảnh hưởng tới dữ liệu cũ.

## Kiểm tra chất lượng

- [ ] Không có câu mơ hồ kiểu "nhanh", "dễ dùng", "hợp lý" mà không có tiêu chí đo được.
- [ ] Mọi chữ hiển thị có quy định ngôn ngữ (đa ngôn ngữ nếu có).
- [ ] Nêu rõ thay đổi dữ liệu (bảng, trường mới) hoặc ghi "không đổi schema".
- [ ] Thuật ngữ thống nhất giữa các tài liệu (lập bảng thuật ngữ nếu có từ 10 từ chuyên môn trở lên).
- [ ] Người dùng đã duyệt. Đặc tả là quyết định của người dùng, agent không tự chốt.

Skill bên ngoài phù hợp: `spec-driven-development`, `idea-refine` (addyosmani); `to-spec`, `grill-me` (mattpocock); `feature-forge` (Jeffallan, EARS + AC).
