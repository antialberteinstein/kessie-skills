# lead — Trạng thái, kế hoạch, bảo trì

Các chế độ thuộc phần này:
- `status` → §1. `issue <mô tả>` → §2a. `plan [milestone]` → §2–3. `triage [#issue]` → §4. `report` → §5. `deps` → `references/dependencies.md`.

Nguyên tắc: **một backlog duy nhất (issue tracker) · mỗi issue vừa một PR · mỗi phiên bản là một milestone · agent đề xuất, người dùng duyệt mọi thao tác ghi lên tracker.**

## 1. Chụp trạng thái (luôn làm trước)

```bash
<skill-dir>/scripts/project-snapshot.sh <repo>
```

Script chỉ đọc. Nó tự nhận biết package.json, app.json, pyproject.toml, Cargo.toml, pubspec.yaml, và chạy được cả với repo chưa có commit hay remote.

| Tín hiệu | Đề xuất |
|---|---|
| Chưa có commit, hoặc một commit khổng lồ | Commit nền ngay; từ nay mỗi giai đoạn một PR |
| File TODO/ISSUES/STATUS còn mục chưa xong | Chuyển thành issue, link ngược lại, hỏi có xoá file cũ không |
| File trạng thái lâu không sửa so với release gần nhất | Đã cũ: cập nhật theo release hoặc bỏ |
| PR Dependabot mở quá 7 ngày | `references/dependencies.md` |
| `[Unreleased]` có nội dung, nhiều commit kể từ tag | Gợi ý `/kessie-skills:proj ship release X.Y.Z` |
| Nhánh đã merge, `main` local tụt sau remote | Đề xuất dọn và pull |
| File chưa theo dõi không thuộc kế hoạch nào | Hỏi: commit, gitignore hay xoá |

## 2a. Tạo một issue từ mô tả

1. Phân loại: Feature / Bug / Verify / Chore. Tìm issue trùng (`gh issue list --search "<từ khoá>" --state all`); nếu trùng thì đề xuất bình luận vào issue cũ thay vì tạo mới.
2. Feature mà spec chưa có hành vi này: dừng lại. Gợi ý người dùng chạy `/kessie-skills:proj spec <mô tả>` trước (spec là của người dùng), hoặc ghi rõ trong issue là "chưa có trong spec" nếu người dùng muốn làm luôn.
3. Soạn nội dung theo `references/issue-templates.md`: AC (trích từ `docs/modules/*.md` hoặc 2–5 tiêu chí đề xuất), phạm vi kỹ thuật, ngoài phạm vi, điều kiện đóng. Cỡ L thì đề xuất tách thành nhiều issue.
4. Trình bản nháp (tiêu đề, nội dung, label, milestone). **Chỉ tạo khi người dùng đồng ý:** `gh issue create --title … --body-file … [--label …] [--milestone …]`.
5. In số issue và gợi ý bước tiếp theo: `/kessie-skills:proj build <số>`.

## 2. Từ đặc tả đến issue

- Mỗi nhóm AC trong `docs/modules/*.md` thành một issue vừa một PR. Mẫu: `references/issue-templates.md` (Feature, Bug, Verify, Chore).
- Sắp theo phụ thuộc: `nền (CI, cấu hình, mô hình dữ liệu hoặc API công khai) → lõi + test → giao diện hoặc lệnh + E2E/golden → tích hợp và job nền → kiểm chứng môi trường thật → release`. Ưu tiên một luồng mỏng chạy đầu-cuối trước.

## 3. Milestone

- `0.x` là beta: thêm tính năng thì tăng minor, chỉ sửa lỗi thì tăng patch. `1.0.0` khi phạm vi v1 đã xong và đã kiểm chứng; với thư viện, đó là khi API công khai đã ổn định.
- Nguồn ứng viên theo thứ tự: bug đang mở → mục chưa xác minh → "Giới hạn hiện tại" trong đặc tả → yêu cầu mới → bảo trì.
- Trình bản kế hoạch (bảng issue · loại · cỡ · phụ thuộc · rủi ro · tiêu chí phát hành) cho người dùng duyệt **trước khi** tạo trên GitHub.

## 4. Triage

Đủ thông tin chưa → phân loại (bug/feature/chore/verify) → cỡ (L thì tách nhỏ) → có đụng ADR không (có thì hỏi người dùng) → lỗi chỉ tái hiện trên môi trường thật thì ghi điều kiện đóng.

## 5. Báo cáo tiến độ

```markdown
# Tiến độ <dự án> — YYYY-MM-DD
Phiên bản <tag> · Unreleased <n> · CI main <xanh/đỏ>
## Đã xong (PR → issue) · ## Đang làm / bị chặn · ## Rủi ro và chưa xác minh · ## Đề xuất tiếp theo (tối đa 3)
```

Chỉ báo cáo những gì đã kiểm tra.

## Không làm khi chưa có xác nhận

Tạo, đóng hay sửa issue/milestone/label; xoá nhánh; merge; đóng PR của bot; xoá file theo dõi cũ.
