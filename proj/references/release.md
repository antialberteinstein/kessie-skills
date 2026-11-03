# Phát hành phiên bản

**Gắn tag, push tag và tạo Release là thao tác ra bên ngoài: xác nhận với người dùng trước từng bước.**

## 0. Chọn số phiên bản
- Đọc `[Unreleased]`: có "Thêm" thì tăng minor; chỉ có "Sửa" hoặc "Bảo trì" thì tăng patch; có thay đổi phá vỡ tương thích sau 1.0 thì tăng major. `0.x` là beta (pre-release).
- `[Unreleased]` trống nhưng có commit kể từ tag gần nhất (`git log vPREV..origin/main --oneline`): bổ sung CHANGELOG trước.

## 1. PR phiên bản (`chore/release-X.Y.Z`)
- Cập nhật **mọi** file version của stack (ví dụ `package.json` qua `npm version X.Y.Z --no-git-tag-version`, `app.json`, `pyproject.toml`, `Cargo.toml`, `pubspec.yaml`). **Không sửa build number** nếu hệ thống build quản lý từ xa.
- CHANGELOG: `## [Unreleased]` đổi thành `## [X.Y.Z] - YYYY-MM-DD`, thêm `## [Unreleased]` trống ở trên, cập nhật link so sánh cuối file.
- Badge hoặc ghi chú phiên bản trong README và tài liệu phát hành (nếu có).
- Kiểm tra:
  ```bash
  bash <skill-dir>/scripts/check-release-ready.sh X.Y.Z /path/to/repo
  ```
  Script chỉ đọc. Nó kiểm tra file version đồng bộ, mục CHANGELOG và link, README, tag chưa tồn tại, cây làm việc sạch, nhánh chính khớp remote (khi đang ở nhánh chính).
- Commit `chore(release): X.Y.Z`. PR nêu rõ: migration cần áp dụng, có cần build lại bản cài không.

## 2. Tag (sau khi người dùng merge)
```bash
git switch main && git pull
bash <skill-dir>/scripts/check-release-ready.sh X.Y.Z .
git tag -a vX.Y.Z -m "<Tên dự án> X.Y.Z"
git push origin vX.Y.Z
```
Tag chỉ đặt trên commit thuộc nhánh chính và phải trùng version trong file. **Không di chuyển hay dùng lại tag**; phát hành sai thì ra bản patch mới.

## 3. GitHub Release
```bash
awk '/^## \[X\.Y\.Z\]/{f=1;next} /^## \[/{f=0} f' CHANGELOG.md > notes.md
gh release create vX.Y.Z --verify-tag --prerelease --title "X.Y.Z Beta" --notes-file notes.md   # bỏ --prerelease khi ≥ 1.0
```

## 4. Workflow build artifact (thiết lập một lần)
Trigger `release: published` cùng `workflow_dispatch`, gồm các job:
1. **verify:** tag khớp version trong file, và commit của tag thuộc nhánh chính (`git merge-base --is-ancestor`).
2. **checks:** `uses: ./.github/workflows/ci.yml` (gọi lại toàn bộ CI qua `workflow_call`).
3. **build:** chạy trong GitHub environment riêng (có thể yêu cầu người duyệt), dùng secret của dịch vụ build. Build artifact, tạo `.sha256`, rồi `gh release upload vX.Y.Z <file> <file>.sha256 --clobber`.

Ghi chú: `permissions: contents: write` chỉ cấp cho job build. Token của dịch vụ build không truyền vào job PR. Build tốn quota thì không chạy lại khi chưa hiểu nguyên nhân lỗi. Chạy lại cho Release đã có: `workflow_dispatch` với ref là tag.

## 5. Sau phát hành
- Nhắc người dùng áp dụng migration lên môi trường thật **trước khi** chia sẻ bản cài.
- Chạy checklist thiết bị trên artifact vừa build (`/kessie-skills:proj ship` › qa).
- Báo cáo: link Release, checksum, phần chưa xác minh.

## Hotfix
Nhánh `fix/N-…` từ `main` → PR → bản patch theo đúng quy trình trên. Không sửa trực tiếp trên tag.

Skill bên ngoài: `shipping-and-launch`, `git-workflow-and-versioning` (addyosmani); với mobile: `eas-app-stores`, `eas-workflows`, `eas-update` (Expo); plugin `deployment-strategies` (wshobson).

## Kênh phát hành theo loại dự án

| Loại | Sau khi có tag và Release |
|---|---|
| App (mobile/desktop) | Workflow build bản cài, đính kèm vào Release kèm `.sha256`; store thì qua công cụ submit của nền tảng (cần người dùng duyệt) |
| Web/SaaS, API | Deploy production từ tag (hoặc promote bản staging đã kiểm), smoke test, theo dõi lỗi 15–30 phút, sẵn sàng rollback |
| Thư viện/SDK | Publish từ CI bằng trusted publishing / provenance (`npm publish --provenance`, PyPI Trusted Publisher, `cargo publish`); không publish từ máy cá nhân; kiểm tra gói đã publish cài được trong một dự án trống |
| CLI | Build binary cho từng OS/arch, đính kèm Release kèm checksum; hoặc publish package; cập nhật công thức brew nếu có |
| Site tĩnh | Deploy production từ nhánh chính hoặc tag; kiểm tra link và trang chính sau deploy |
| Data/automation | Cập nhật job đã lên lịch tới phiên bản mới; chạy dry-run trước lần chạy thật đầu tiên |
| Extension/bot | Đóng gói và gửi store review, hoặc deploy bản tự host; ghi lại quyền mới xin thêm |
