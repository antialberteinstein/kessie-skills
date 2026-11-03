# Kiểm chứng và bằng chứng

Nguyên tắc: **chỉ tuyên bố những gì đã chạy và quan sát được. Mỗi lớp test chứng minh một phạm vi khác nhau. Không dùng lớp này để thay cho lớp khác.**

## Các lớp kiểm thử

| Lớp | Công cụ ví dụ | Chứng minh | KHÔNG chứng minh |
|---|---|---|---|
| Tĩnh | typecheck, lint, format, test AST tuỳ chỉnh | Kiểu, quy ước, bất biến mã nguồn | Hành vi |
| Unit/integration | Vitest/Jest/pytest/flutter test + coverage | Logic domain, repository với port giả, map lỗi | UI thật, mạng, nền tảng |
| E2E (backend giả lập) | Playwright/Cypress/Detox/Maestro | Luồng, CRUD, reload, thứ tự, layout trên viewport | Auth/DB thật; tính năng native nếu chạy trên web |
| DB/emulator cô lập | Postgres container, Firebase emulator | Migration, phân quyền, ràng buộc, trigger | Môi trường thật đã được áp dụng |
| Build | bundle/APK/IPA/web build | Biên dịch và đóng gói được | Chạy đúng trên máy, ký bản cài, credentials |
| Thiết bị / môi trường thật | Checklist thủ công hoặc device farm | Hành vi thật: bàn phím, Back, quyền, push, phiên | — |
| Production chỉ đọc | Script kiểm tra schema/cấu hình | Môi trường thật đúng cấu hình | — |

Coverage chỉ tính trên các file đo được. **Không** suy rộng thành "coverage toàn app".

## Kế hoạch kiểm thử (khi bắt đầu module)

Với mỗi AC-NN: chọn lớp thấp nhất có thể chứng minh nó, ghi tên test dự kiến, đánh dấu AC nào bắt buộc kiểm trên thiết bị hoặc môi trường thật. Mẫu ở `references/qa-templates.md` §1.

## Quy trình kiểm chứng một thay đổi

1. Ánh xạ AC liên quan sang bằng chứng.
2. Chạy các lớp phù hợp. Lớp nào bỏ qua thì nêu lý do.
3. **Xem kết quả thật:** số test đã qua và đã skip, ảnh chụp màn hình, log. Không tin exit code khi test có thể bị skip.
4. Test chập chờn: chạy lại một lần để xác nhận. Nếu vẫn chập chờn thì ghi nhận và tạo issue. **Không** xoá hay skip test để CI xanh.
5. Báo cáo theo mẫu `references/qa-templates.md` §2 (trong PR, issue, hoặc file trạng thái gắn với release).

## Thiết bị / môi trường thật

- Dùng đúng bản phát hành (artifact của release, không phải dev server). Tắt dev server để chắc chắn app chạy độc lập.
- Checklist theo mẫu `references/qa-templates.md` §3, sinh từ các AC có đánh dấu "cần thiết bị". Ghi thiết bị, OS, phiên bản, ngày, mạng. Ảnh phải che dữ liệu cá nhân.
- Chỉ khi checklist đạt mới dùng `Closes #N` cho lỗi native hoặc production.

## Bug report tái hiện được

Hiện tượng và mong đợi · bước tái hiện tối thiểu · môi trường và phiên bản · tần suất và mạng · mã hỗ trợ hoặc log đã che · giả thuyết (ghi rõ là giả thuyết). Viết test tái hiện trước khi sửa nếu có thể.

## Trước khi phát hành

- [ ] CI trên nhánh chính xanh.
- [ ] Mọi AC của milestone có bằng chứng hoặc được ghi là chưa xác minh.
- [ ] Đã chạy checklist trên bản release candidate.
- [ ] Migration hoặc rules mới đã áp dụng lên môi trường thật và được kiểm tra chỉ đọc.
- [ ] Audit dependency không có cảnh báo mới chưa được ghi nhận (`/kessie-skills:proj ship` › security).

Skill bên ngoài: `superpowers:verification-before-completion`, `webapp-testing` (Anthropic), `playwright-expert`/`test-master` (Jeffallan), `senior-qa` (alirezarezvani), plugin `unit-testing`, `performance-testing-review` (wshobson).

## "Môi trường thật" theo loại dự án

App: thiết bị thật với bản cài phát hành · Web/SaaS: staging, sau đó production smoke test · API: smoke test sau deploy với token thật có quyền tối thiểu · Thư viện: cài gói đã publish vào một dự án trống · CLI: chạy binary phát hành trên từng OS hỗ trợ · Site tĩnh: preview hoặc production URL · Data: chạy trên bản sao dữ liệu thật · Extension/bot: trình duyệt hoặc workspace thật. Checklist trong `references/qa-templates.md` §3 viết cho app; điều chỉnh theo bảng này.
