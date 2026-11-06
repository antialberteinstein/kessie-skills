---
name: setup-project
description: Phân tích project hiện tại rồi đề xuất và cài plugin, skill, agent và MCP ở scope project, kèm gợi ý thêm tìm trên web (tối giản trước, rồi mở rộng theo chức năng)
disable-model-invocation: true
---

# /setup-project

Thiết lập Claude Code cho project trong thư mục hiện tại: chọn plugin, skill, agent và
MCP phù hợp từ catalog, hỏi xác nhận, rồi cài vào `./.claude/` và `./.mcp.json`.

Ngoài catalog, skill còn tra cứu web để gợi ý thêm plugin, skill, MCP hợp với project
(bước 4b): một danh sách tối giản trước, rồi một danh sách mở rộng theo chức năng.

Yêu cầu thêm của người dùng (có thể trống): $ARGUMENTS
Ví dụ: `status`, `thêm ml`, `gỡ react`, `cập nhật`, `không gợi ý` (bỏ bước tra cứu web).

Đường dẫn của skill này:
- catalog: `${CLAUDE_SKILL_DIR}/catalog.md`
- script ECC: `${CLAUDE_SKILL_DIR}/scripts/ecc-project.sh`

## Phạm vi được phép
- Chỉ ghi trong `./.claude/` và `./.mcp.json` của project. Không sửa `~/.claude/`,
  `~/.claude.json`, `CLAUDE.md` gốc của project hay bất kỳ file nào khác.
- Không ghi token hay key cố định vào `.mcp.json`.
- Chỉ cài những gì có trong catalog, hoặc mục ngoài catalog mà người dùng đã chọn đích
  danh ở bước 4b. Thêm marketplace mới cho mục đã chọn được phép (`claude plugin
  marketplace add` đăng ký marketplace ở máy).
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
- `./.mcp.json` (khối `mcpServers`) và `claude mcp list` để biết MCP nào đã có

### 4. Đề xuất và chờ xác nhận
Trình bày **một bảng**, mỗi dòng một thay đổi:

| Thay đổi | Thành phần | Dấu hiệu tìm thấy |
|---|---|---|
| + plugin | `pyright-lsp` | `pyproject.toml` |
| + ECC | `pytorch-patterns`, `mle-reviewer` | `torch` trong `pyproject.toml` |
| + MCP | `hf` | `transformers` trong `pyproject.toml` |
| − ECC | `react-reviewer` | không còn `react` trong `package.json` |

Sau bảng, liệt kê:
- các thành phần **bỏ qua vì đã có ở scope user**,
- các **công cụ hệ thống còn thiếu** kèm lệnh cài,
- đúng các lệnh sẽ chạy.

Nếu catalog không có thay đổi nào, nói một câu như vậy rồi vẫn sang bước 4b.

### 4b. Gợi ý thêm ngoài catalog (tra cứu web)
Chạy ngay sau bảng của bước 4, trong cùng một lần trả lời. Áp dụng cả khi gọi kèm tham
số nhóm (vd. `thêm ml`): khi đó chỉ gợi ý trong phạm vi nhóm đó. Bỏ qua nếu tham số có
`không gợi ý`, hoặc yêu cầu chỉ là `status` hay `gỡ …`. Không có công cụ tìm kiếm web thì
nói một câu và bỏ qua.

1. **Xác định nhu cầu** từ khảo sát ở bước 2: ngôn ngữ, framework, dịch vụ bên ngoài
   (database, cloud, API), loại việc lặp lại (kiểm thử UI, theo dõi training, deploy,
   xử lý dữ liệu). Bỏ nhu cầu mà catalog, thứ đã cài, hoặc Superpowers đã phủ.
2. **Tìm kiếm web** cho từng nhu cầu, vd. `<framework> Claude Code plugin`,
   `<dịch vụ> official MCP server`, `<stack> Claude Code skill`. Ưu tiên theo thứ tự:
   marketplace `claude-plugins-official`; repo do chính nhà cung cấp dịch vụ phát hành;
   tài liệu chính thức; repo cộng đồng được bảo trì tốt.
3. **Xác minh bằng cách mở trang nguồn** (repo, README, tài liệu), không dựa vào đoạn
   trích của kết quả tìm kiếm. Chỉ giữ mục:
   - có commit trong khoảng 6 tháng gần đây và có giấy phép;
   - có cách cài rõ ràng, lấy nguyên văn từ README hoặc tài liệu đã mở;
   - không phải bản mirror hay fork không chính thức;
   - không trùng thứ đã cài, Superpowers, catalog, hay mục "Không bao giờ đề xuất".
   Dịch vụ có CLI tốt (vd. `gh`, `kaggle`) thì gợi ý CLI thay cho MCP.
4. **Trình bày hai phần**, ngay dưới bảng của bước 4:

   **Tối giản (khuyên dùng)**: tối đa 3 mục, đủ cho phần lớn nhu cầu của project.

   | Loại | Tên | Vì sao (dấu hiệu trong project) | Nguồn | Lệnh cài |
   |---|---|---|---|---|
   | MCP | `…` | `…` trong `pyproject.toml` | [repo](…) | `claude mcp add --scope project …` |

   **Mở rộng theo chức năng**: mỗi chức năng một nhóm, 1–2 lựa chọn, nói rõ hai lựa
   chọn khác nhau ở đâu để người dùng chọn.

   | Chức năng | Lựa chọn | Khác nhau ở đâu | Nguồn |
   |---|---|---|---|
   | Kiểm thử UI | `…` / `…` | `…` nhẹ hơn; `…` có ghi hình | [repo](…) / [repo](…) |

   Với mỗi mục, ghi rõ nếu nó chạy lệnh trên máy (MCP dạng stdio), cần token, hay gửi
   dữ liệu ra dịch vụ bên ngoài. Không bịa tên hay lệnh: không tìm thấy lệnh cài thì ghi
   "xem README". Không tìm được gì đáng gợi ý thì nói một câu như vậy.

Sau đó **dừng lại và chờ người dùng**: đồng ý với bảng catalog (có thể bỏ bớt dòng), và
chọn đích danh mục nào ngoài catalog muốn cài. Không chọn thì không cài mục ngoài catalog
nào. Chỉ làm những gì được đồng ý.

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

MCP, mỗi MCP một lệnh, đúng lệnh ghi trong catalog (lệnh này tạo hoặc cập nhật
`./.mcp.json`):
```bash
claude mcp add --scope project <tên> ...    # thêm
claude mcp remove --scope project <tên>     # gỡ
```
MCP đã có trong `./.mcp.json` thì bỏ qua, không thêm lại.

Mục ngoài catalog người dùng đã chọn ở bước 4b, dùng đúng lệnh đã ghi trong bảng:
- Plugin: `claude plugin marketplace add <owner>/<repo>` nếu marketplace chưa có, rồi
  `claude plugin install <plugin>@<marketplace> --scope project`.
- MCP: `claude mcp add --scope project …`. Token đưa vào bằng `${BIẾN}`, không ghi cố định.
- Skill lẻ: chép đúng thư mục skill từ repo nguồn (clone tạm, chép, xoá clone) vào
  `./.claude/skills/<tên>/`, kèm file `SOURCE` ghi URL repo, commit và giấy phép.

Cài xong, hỏi người dùng có muốn đưa các mục này vào catalog bằng
`/kessie-skills:add-preset` để lần sau được đề xuất tự động không.

Lệnh nào lỗi thì dừng, báo nguyên văn lỗi, không thử cách khác.

### 6. Kiểm tra và báo cáo
- In lại `enabledPlugins` của `./.claude/settings.json`, kết quả `status`, và danh sách
  `mcpServers` của `./.mcp.json`.
- Báo ngắn gọn đã thêm, gỡ những gì, tách riêng mục từ catalog và mục ngoài catalog.
- Nhắc người dùng chạy `/reload-plugins` hoặc khởi động lại để nạp. Nếu có MCP mới,
  nhắc rằng Claude Code sẽ hỏi duyệt MCP project ở lần khởi động tới.
- Nếu project có git và `.claude/` hoặc `.mcp.json` chưa nằm trong `.gitignore`, hỏi
  người dùng muốn commit cấu hình này hay bỏ qua. Không tự sửa `.gitignore`.
