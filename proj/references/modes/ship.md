# ship — Kiểm chứng, bảo mật, phát hành

Tham số (phần sau tên chế độ):
- `verify [#issue]` → kiểm chứng thay đổi hoặc milestone: `references/qa.md`, `references/qa-templates.md`.
- `security` → review bảo mật diff hoặc milestone: `references/security.md`.
- `release X.Y.Z` → cổng trước release rồi trình tự phát hành: `references/release.md`.
- Trống → hỏi người dùng muốn làm phần nào.


## Cổng trước khi phát hành

- [ ] CI trên nhánh chính xanh.
- [ ] Mọi AC của milestone có bằng chứng, hoặc được ghi là chưa xác minh.
- [ ] Review bảo mật cho các thay đổi trong milestone.
- [ ] Thay đổi lên môi trường thật (migration, rules, cấu hình) đã được người dùng áp dụng và kiểm tra chỉ đọc.
- [ ] Audit dependency không có cảnh báo mới chưa được ghi nhận (gợi ý người dùng gọi `/kessie-skills:proj deps`).
- [ ] Script kiểm tra đạt:
  ```bash
  <skill-dir>/scripts/check-release-ready.sh X.Y.Z <repo>   # chỉ đọc: version đồng bộ, CHANGELOG, README, tag, cây sạch, nhánh chính khớp remote
  ```

## Trình tự phát hành (chi tiết và theo loại dự án ở `references/release.md`)

PR `chore(release): X.Y.Z` → người dùng merge → `git tag -a vX.Y.Z` trên `main` → `gh release create vX.Y.Z --verify-tag [--prerelease]` (ghi chú lấy từ CHANGELOG) → kênh phát hành theo loại dự án (bản cài + checksum · deploy · publish lên registry) → kiểm chứng trên chính artifact hoặc bản deploy đó → báo cáo.

Không di chuyển hay dùng lại tag; phát hành sai thì ra bản patch mới.

Dùng kèm: `karpathy-guidelines`; skill phát hành theo stack nếu đã cài.
