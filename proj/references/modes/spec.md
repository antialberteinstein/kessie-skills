# spec — Spec là của người dùng

Tham số (phần sau tên chế độ):
- Văn bản mô tả → §1 "Mô tả tự do".
- `thảo luận <chủ đề>` → §2. `inbox` → §3. `xem [module]` → §4.
- Trống → chưa có `docs/RequirementsOutline.md` thì bắt đầu bằng idea brief (`references/requirements.md` §1); có rồi thì hỏi người dùng muốn mô tả, thảo luận hay xử lý inbox.

**Vai trò của agent:** hỏi, đề xuất, viết lại cho rõ, chỉ ra mâu thuẫn, lỗ hổng và hệ quả. **Không tự chốt.** Mọi thay đổi vào file spec được trình dưới dạng đề xuất (diff hoặc đoạn trước/sau); chỉ ghi vào file sau khi người dùng đồng ý, và mỗi quyết định được ghi vào "Lịch sử quyết định".

## Spec nằm ở đâu

| Nơi | Ai viết | Nội dung |
|---|---|---|
| `docs/spec-inbox.md` | Người dùng, bất cứ lúc nào, không cần cấu trúc | Ý tưởng, thay đổi muốn có, điều chưa ưng |
| `/kessie-skills:proj spec <mô tả>` | Người dùng, trong chat | Như inbox, nhưng xử lý ngay |
| `docs/RequirementsOutline.md` | Agent đề xuất, người dùng duyệt | Hành vi đã chốt (nguồn sự thật), cuối file có "Lịch sử quyết định" |
| `docs/modules/<Module>.md` | Agent đề xuất, người dùng duyệt | Luồng, quy tắc, dữ liệu, bảng AC; đầu file ghi `Trạng thái: Nháp \| Đã duyệt YYYY-MM-DD` |
| `DESIGN.md` | Qua `/kessie-skills:proj design` | Giao diện trông thế nào |
| `docs/decisions/` | Qua kickoff › architecture | Quyết định kỹ thuật (ADR) |

Khung của các file: `references/requirements.md`, `references/idea-brief-template.md`, `references/module-breakdown-template.md`. Nếu chưa có file thì tạo từ template của skill kickoff (`<skill-dir>/templates/docs/`).

## 1. Mô tả tự do

1. Đọc spec hiện có (nếu có) để tránh trùng hoặc mâu thuẫn.
2. Tách mô tả của người dùng thành: **hành vi mới · thay đổi hành vi · quy tắc nghiệp vụ · dữ liệu · ngoài phạm vi · câu hỏi mở**.
3. Ánh xạ từng ý vào mục của RequirementsOutline hoặc module tương ứng. Ý mới đủ lớn thì đề xuất module mới.
4. Trình đề xuất: bản tóm tắt dễ đọc trước, sau đó là diff, kèm AC dự kiến (`| AC-NN | Tình huống | Kết quả |`).
5. Hỏi tối đa 3 câu quan trọng nhất trước (câu nào ảnh hưởng tới dữ liệu hay kiến trúc thì hỏi trước); các câu khác ghi vào "Câu hỏi mở".
6. Người dùng duyệt thì ghi vào file và thêm dòng "Lịch sử quyết định".

## 2. Thảo luận

- Hỏi **từng câu một**. Mỗi câu kèm 2–3 phương án, **một đề xuất** và hệ quả của từng phương án (dữ liệu, UX, chi phí, độ phức tạp).
- Sau mỗi 3–5 câu, tóm tắt những gì đã thống nhất.
- Khi người dùng nói "chốt" (hoặc tương đương): trình bản ghi cuối cùng rồi ghi vào spec như §1 bước 6.
- Nếu chủ đề đụng kiến trúc (Auth, backend, phân quyền), ghi chú "cần ADR" và gợi ý người dùng chạy `/kessie-skills:proj kickoff` hoặc cập nhật ADR.

## 3. Inbox

Đọc mục "Chưa xử lý" trong `docs/spec-inbox.md`. Phân loại từng dòng:

| Loại | Đề xuất |
|---|---|
| Thay đổi spec | Như §1 |
| Lỗi | Soạn issue `[Bug]` (người dùng duyệt) |
| Ý tưởng để sau | Thêm vào "Giới hạn hiện tại / Roadmap" của RequirementsOutline |
| Cần bàn thêm | Mở §2 với chủ đề đó |

Sau khi người dùng duyệt: chuyển dòng sang "Đã xử lý" kèm ngày và link (mục spec, issue). Không xoá chữ của người dùng.

## 4. Xem

Tóm tắt spec hiện tại (hoặc của một module): khả năng, số AC, trạng thái duyệt, câu hỏi mở. Nếu có code, chỉ ra chỗ code và spec lệch nhau (đọc code, không sửa).

## Sau khi spec thay đổi

- AC mới hoặc đổi → gợi ý `/kessie-skills:proj plan` để tách thành issue.
- Đụng giao diện → gợi ý `/kessie-skills:proj design` nếu cần thành phần mới trong DESIGN.md.
- Spec đã duyệt mà bị đổi: ghi rõ ảnh hưởng tới dữ liệu cũ và AC cũ trong "Lịch sử quyết định".
