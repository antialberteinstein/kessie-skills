# CLAUDE.md, prompt giao việc, memory

## 1. CLAUDE.md / AGENTS.md

Khung có sẵn: `templates/CLAUDE.md`. Nguyên tắc:

- **Ngắn** (tối đa khoảng 120 dòng). Chỉ ghi điều agent **không tự suy ra được** từ code: quyết định, lý do, cạm bẫy, lệnh, quy ước có tranh cãi.
- Thứ tự mục: một câu mô tả dự án → **Kiến trúc (đã quyết định, không mở lại)** kèm link ADR và phương án bị loại → Bố cục → Lệnh → Quy ước → Dữ liệu và bảo mật → Điểm dễ hỏng → Phiên bản và phát hành → Git và PR.
- "Điểm dễ hỏng" là mục giá trị nhất: hành vi cố ý trông như lỗi (fallback, timeout chỉ áp dụng cho một phạm vi), giới hạn của môi trường dev (emulator hoặc web không có tính năng X), file import nội bộ thư viện cần kiểm tra lại khi nâng cấp.
- Viết mệnh lệnh cụ thể ("Migration chỉ được thêm, không sửa file đã áp dụng"), tránh lời khuyên chung chung ("viết code sạch").
- Dùng nhiều agent thì giữ **một** file nguồn, file còn lại chỉ trỏ tới (`AGENTS.md`: "Xem CLAUDE.md").
- Tạo ngay ở giai đoạn 3, trước khi có code. Cập nhật mỗi khi có ADR mới, lệnh mới hoặc cạm bẫy mới (cùng PR với thay đổi đó).

Kiểm tra CLAUDE.md:

- [ ] Một agent mới chỉ đọc file này có biết: chạy kiểm tra thế nào, không được làm gì, quyết định nào không được mở lại?
- [ ] Không chứa secret, URL project thật, email.
- [ ] Không trùng lặp README (chỉ link sang).
- [ ] Mọi lệnh trong file đều chạy được.
- [ ] Có 3 quy tắc bắt buộc: lưu prompt vào `prompts/LOG.md`; không ghi attribution của AI (`Co-Authored-By`, "Generated with Claude Code") trong commit, issue, mô tả và bình luận PR; mục "Skill bổ trợ" có bảng skill kèm lệnh cài và quy tắc "chưa cài thì gợi ý, không tự cài".

## 2. Bộ prompt giao việc theo giai đoạn

Dùng khi xây phần lớn (nền tảng, một module mới) qua nhiều phiên agent. Mẫu: `references/task-prompt-template.txt`.

- Mỗi file `prompts/NN-slug.txt` là một giai đoạn, có các mục: VAI TRÒ VÀ BỐI CẢNH · MỤC TIÊU · PHẠM VI · NGOÀI PHẠM VI · ĐẦU RA · TIÊU CHÍ HOÀN THÀNH.
- Prompt 01 là nền tảng (Auth, mô hình dữ liệu, điều hướng, CI). Các prompt sau mỗi cái bổ sung một module hoặc một nhóm quyết định UX.
- Prompt **dẫn tới đặc tả** (RequirementsOutline §, module breakdown AC-NN), không sao chép toàn bộ đặc tả.
- Tiêu chí hoàn thành phải quan sát được, và luôn có câu: "không tuyên bố đã triển khai hoặc xác minh trên môi trường thật khi chưa có bằng chứng".
- Rút gọn từ hội thoại: giữ ý định sản phẩm, bỏ phần trao đổi qua lại, gộp lời phê duyệt vào tác vụ. Lỗi không tạo prompt riêng, lỗi là issue.
- Mỗi prompt ứng với một hoặc vài issue và một PR riêng (**không** dồn nhiều prompt vào một commit).
- Cập nhật bảng trong `prompts/README.md`: file, mục đích, issue hoặc PR.

### Nhật ký prompt (`prompts/LOG.md`)

Khác với prompt giai đoạn (viết trước để giao việc), nhật ký ghi lại **mọi** yêu cầu thật của người dùng đã dựng nên dự án, kể cả sửa lỗi và thay đổi nhỏ.

- Ghi một mục cho mỗi yêu cầu dẫn tới thay đổi trong repo, ở bất kỳ chế độ nào hoặc khi người dùng yêu cầu trực tiếp không qua lệnh: ngày · lệnh/ngữ cảnh · yêu cầu (rút gọn, giữ ý định và ràng buộc) · quyết định đã chốt · issue/PR.
- Ghi trong cùng PR với thay đổi. Chỉ thêm, không sửa mục cũ; yêu cầu sau đổi ý thì ghi mục mới trỏ về mục cũ.
- Câu hỏi thuần tuý (không đổi repo) không cần ghi.
- Không ghi secret, token, URL môi trường thật, email, dữ liệu cá nhân.

## 3. Memory của agent

Lưu vào memory (nếu agent hỗ trợ) những sự thật bền vững không nằm trong repo:

- quyết định của người dùng kèm ngày và lý do ("chọn X, không dùng Y vì Z — đừng đề xuất lại");
- sở thích làm việc ("không tự push", "commit không thêm dòng Co-Authored-By");
- tài nguyên ngoài (dashboard, project ID — không ghi secret).

Không lưu những gì repo đã ghi (cấu trúc code, lịch sử commit). Nếu memory mâu thuẫn với code hiện tại, kiểm tra lại code trước khi dùng.

## 4. Rà soát xung đột cấu hình agent

- Liệt kê nguồn chỉ dẫn đang có hiệu lực: `~/.claude/CLAUDE.md`, `~/.claude/rules/*`, plugin hoặc hook toàn cục, skill đã cài, CLAUDE.md của dự án.
- Tìm mâu thuẫn (ngôn ngữ, module system, quy ước tên, test runner, quy định về commit).
- Ghi vào CLAUDE.md dự án: "Nếu cấu hình toàn cục mâu thuẫn, file này được ưu tiên", kèm các điểm khác biệt cụ thể. Đề xuất người dùng giới hạn phạm vi hoặc tắt các rule toàn cục không phù hợp.
- Tránh cài nhiều framework quy trình cùng lúc (xem `docs/RECOMMENDED-SKILLS.md` trong repo [kessie-skills](https://github.com/antialberteinstein/kessie-skills/blob/main/docs/RECOMMENDED-SKILLS.md)).

Skill bên ngoài: `agents-md` (getsentry), `writing-for-agents` (mattpocock), `context-engineering` (addyosmani), `skill-creator` (Anthropic) để tạo skill riêng cho dự án khi quy ước đã ổn định.
