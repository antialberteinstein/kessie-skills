# Nền repo

Mục tiêu: **trước dòng code tính năng đầu tiên**, repo đã có tài liệu khung, file hướng dẫn agent, CI chạy được và quy trình PR. Nhờ vậy mọi thay đổi sau đều có lịch sử và cổng kiểm tra.

## 1. Khởi tạo (hỏi người dùng tên repo, visibility, license trước)

```bash
git init -b main                                   # nếu chưa có
bash <skill-dir>/scripts/scaffold.sh . --name "Tên dự án"           # chạy thử: xem file nào sẽ được tạo
bash <skill-dir>/scripts/scaffold.sh . --name "Tên dự án" --apply   # ghi; KHÔNG ghi đè file đã có
```

Scaffold tạo (từ `templates/`): `README.md`, `CHANGELOG.md`, `CLAUDE.md`, `.env.example`, `docs/RequirementsOutline.md`, `docs/decisions/README.md`, `docs/WORKFLOW.md`, `docs/SECURITY.md`, `prompts/README.md`, `prompts/LOG.md`, `.github/PULL_REQUEST_TEMPLATE.md`, `.github/ISSUE_TEMPLATE/{bug_report,feature_request,config}.yml`, `.github/workflows/ci.yml`, `.github/dependabot.yml`. Sau đó tìm `TODO` và điền theo idea brief và ADR.

Khởi tạo project theo framework đã chọn trong ADR, dùng công cụ chính thức của framework (ví dụ `create-expo-app`, `npm create vite`, `flutter create`, `cargo new`), rồi chạy scaffold. Scaffold không ghi đè README hay .gitignore mà framework đã tạo; khi đó gộp nội dung bằng tay.

## 2. Bắt buộc có ngay

- **`.gitignore`**: `.env`, `.env.*` (trừ `.env.example`), file credentials của dịch vụ (ví dụ `google-services.json`, `*.p8`, `*.keystore`), `coverage/`, thư mục build, báo cáo test. Kiểm tra `git status` trước commit đầu.
- **Script chuẩn hoá** (tên lệnh giống nhau giữa các dự án để agent và CI dùng chung): `typecheck`, `lint`, `format`, `format:check`, `test`, `test:coverage`, `test:e2e`, `build`. Stack không phải Node thì ghi lệnh tương đương vào CLAUDE.md.
- **Formatter và linter** chạy được trên khung rỗng. Quy ước tên file ghi vào CLAUDE.md.
- **CI** (`.github/workflows/ci.yml`): chạy khi push `main`, PR, chạy tay, và `workflow_call` (để workflow release gọi lại). Dùng giá trị giả cho biến public, không cần secret. `permissions: contents: read`, `persist-credentials: false`. Có `concurrency` để huỷ lần chạy cũ.
- **Test DB cô lập trong CI** ngay khi có migration (service container), kèm danh sách suite rõ ràng và cách chạy local trong README.
- **Dependabot**: GitHub Actions + package manager, mỗi tuần, giới hạn số PR. Thêm `ignore` cho các gói do framework ghim phiên bản; gom nhóm các gói phải đi cùng nhau.

## 3. GitHub (thao tác ra bên ngoài, xác nhận từng bước)

```bash
gh repo create <owner>/<name> --private --source . --push     # hoặc --public theo lựa chọn của người dùng
gh api -X PUT repos/<owner>/<name>/branches/main/protection --input protection.json   # yêu cầu PR + check "CI"
```

Bảo vệ `main`: bắt buộc PR, bắt buộc status check của job CI, không cho force-push. Repo cá nhân có thể bỏ yêu cầu reviewer. Bật "Automatically delete head branches".

## 4. Commit đầu tiên

- `chore: scaffold repository foundation` (một commit cho khung). Các bước tiếp theo đi qua PR, kể cả tài liệu.
- Kiểm tra trước khi push: không có secret (`git diff --cached | grep -iE 'secret|password|private_key|service_role|token'`), CI chạy xanh trên khung rỗng.

## 5. Kiểm tra repo đã đủ chuẩn (dùng khi tiếp nhận repo có sẵn)

- [ ] README chạy được từ đầu trên máy mới; có mục Kiểm tra ghi rõ mỗi lớp test chứng minh gì.
- [ ] CLAUDE.md ngắn, có "Kiến trúc đã quyết định" và "Điểm dễ hỏng".
- [ ] ADR cho stack, Auth và phân quyền.
- [ ] CHANGELOG có `[Unreleased]`; version nằm ở một nơi duy nhất (hoặc có script kiểm tra đồng bộ).
- [ ] PR template, issue form, CI, Dependabot, `main` được bảo vệ.
- [ ] `.env.example` chỉ có biến public; secret không có trong lịch sử git.
- [ ] Không có file TODO/ISSUES local song song với issue tracker.

Skill bên ngoài: `github-actions` (Callstack), plugin `cicd-automation` (wshobson), `ci-cd-and-automation` và `git-workflow-and-versioning` (addyosmani), `setup-pre-commit` (mattpocock).
