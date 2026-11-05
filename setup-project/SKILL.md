---
name: setup-project
description: Phân tích project hiện tại rồi đề xuất và cài plugin, skill, agent ở scope project
disable-model-invocation: true
---

# /setup-project

Thiết lập Claude Code cho project trong thư mục hiện tại: chọn plugin, skill và agent
phù hợp từ catalog, hỏi xác nhận, rồi cài vào `./.claude/`.

Yêu cầu thêm của người dùng (có thể trống): $ARGUMENTS
Ví dụ: `status`, `thêm ml`, `gỡ react`, `cập nhật`.

Đường dẫn của skill này:
- catalog: `${CLAUDE_SKILL_DIR}/catalog.md`
- script ECC: `${CLAUDE_SKILL_DIR}/scripts/ecc-project.sh`

## Phạm vi được phép
- Chỉ ghi trong `./.claude/` của project. Không sửa `~/.claude/`, `CLAUDE.md` gốc của
  project hay bất kỳ file nào khác.
- Chỉ cài những gì có trong catalog.
- Không chạy `sudo`. Thiếu công cụ hệ thống thì báo lệnh cài để người dùng tự chạy.

## Quy trình

### 1. Đọc catalog
Đọc toàn bộ catalog trước khi làm gì khác.

### 2. Khảo sát project
Tìm các dấu hiệu mà catalog liệt kê, bằng cách đọc file chứ không đoán:
`package.json`, `tsconfig.json`, `pyproject.toml`, `requirements*.txt`, `setup.py`,
`CMakeLists.txt`, `Cargo.toml`, `go.mod`, `Dockerfile`, `compose*.yml`, thư mục
`tests/`, `migrations/`, `prisma/`. Với dependency, đọc đúng file khai báo; chỉ grep
import khi không có file khai báo. Bỏ qua `node_modules/`, `.venv/`, `build/`, `dist/`.

### 3. Đọc hiện trạng
- `./.claude/settings.json` (khối `enabledPlugins`)
- `bash <script ECC> status`
- `claude plugin list` để biết plugin nào đã cài
- `ls ~/.claude/skills ~/.claude/agents` để biết những gì đã có ở scope user

### 4. Đề xuất và chờ xác nhận
Trình bày **một bảng**, mỗi dòng một thay đổi:

| Thay đổi | Thành phần | Dấu hiệu tìm thấy |
|---|---|---|
| + plugin | `pyright-lsp` | `pyproject.toml` |
| + ECC | `pytorch-patterns`, `mle-reviewer` | `torch` trong `pyproject.toml` |
| − ECC | `react-reviewer` | không còn `react` trong `package.json` |

Sau bảng, liệt kê:
- các thành phần **bỏ qua vì đã có ở scope user**,
- các **công cụ hệ thống còn thiếu** kèm lệnh cài,
- đúng các lệnh sẽ chạy.

Nếu không có thay đổi nào, nói vậy và dừng. Nếu có, **dừng lại và chờ người dùng
đồng ý**. Người dùng có thể bỏ bớt dòng; chỉ làm những dòng được đồng ý.

### 5. Thực hiện
Plugin, mỗi plugin một lệnh:
```bash
claude plugin install <plugin>@claude-plugins-official --scope project
```
Với plugin chỉ cần bật lại (đã cài nhưng `enabledPlugins` đặt `false`), sửa
`./.claude/settings.json` bằng `jq`, giữ nguyên các key khác.

ECC, gộp trong một lệnh:
```bash
bash <script ECC> -n add --skills a,b --agents c,d   # chạy thử trước
bash <script ECC> add --skills a,b --agents c,d
bash <script ECC> remove --skills x --agents y       # khi gỡ
```
Với yêu cầu `cập nhật`: đọc `status`, rồi chạy `add` lại đúng danh sách đó.

Lệnh nào lỗi thì dừng, báo nguyên văn lỗi, không thử cách khác.

### 6. Kiểm tra và báo cáo
- In lại `enabledPlugins` của `./.claude/settings.json` và kết quả `status`.
- Báo ngắn gọn đã thêm, gỡ những gì.
- Nhắc người dùng chạy `/reload-plugins` hoặc khởi động lại để nạp.
- Nếu project có git và `.claude/` chưa nằm trong `.gitignore`, hỏi người dùng muốn
  commit cấu hình này hay bỏ qua. Không tự sửa `.gitignore`.
