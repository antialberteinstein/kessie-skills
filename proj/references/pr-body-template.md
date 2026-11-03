# Mẫu PR body

```markdown
## Thay đổi
<Vấn đề → hành vi sau thay đổi (2–5 câu), module chính.>

Closes #N   <!-- hoặc: Refs #N — chưa xác minh <phần nào> -->

## Kiểm chứng
- typecheck / lint / format: đạt
- unit: <x>/<x> (coverage lines <..>% · branches <..>%)
- e2e: <y> test (desktop + mobile) — hoặc "không áp dụng vì …"
- DB cô lập: <suite> đạt — nếu có migration/rules
- build: đạt — nếu đổi cấu hình/dependency
- Ảnh (đã che dữ liệu riêng tư): …

- [x] Typecheck, lint và format đạt.
- [x] Unit/integration và E2E liên quan đạt, hoặc giải thích vì sao không áp dụng.
- [x] Không đưa credentials hoặc dữ liệu cá nhân vào code, log và ảnh.
- [ ] Nếu có thay đổi dữ liệu: migration, phân quyền và cách triển khai đã được kiểm tra.

## Triển khai và giới hạn
- Migration/rules cần áp dụng lên môi trường thật: <không | tên file + cách áp dụng>
- Cần build lại bản cài: <không | vì …>
- Cấu hình/secret mới: <chỉ tên, không giá trị>
- Chưa xác minh: <…>
```

Chỉ tick mục đã làm thật. Bỏ dòng không áp dụng.
