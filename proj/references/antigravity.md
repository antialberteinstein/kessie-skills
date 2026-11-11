# Chạy proj trên Antigravity (agy, IDE, app)

Các file khác của skill viết theo Claude Code. Trên Antigravity, đọc chúng theo bảng này:

| Trong file ghi | Trên Antigravity |
|---|---|
| `${CLAUDE_SKILL_DIR}`, `<skill-dir>` | Thư mục chứa `SKILL.md` của proj: `~/.gemini/config/plugins/kessie-skills/proj` khi cài bằng `agy plugin install`. agy không thay biến `${CLAUDE_SKILL_DIR}`, và khi người dùng gõ `/proj` thì agy chèn nội dung SKILL.md mà không kèm đường dẫn |
| `$ARGUMENTS` | Phần người dùng gõ sau `/proj`, hoặc yêu cầu của họ nếu skill được tự kích hoạt |
| `/kessie-skills:proj <chế độ>` | `/proj <chế độ>` |
| Skill tool, "tự gọi skill" | Kích hoạt skill theo tên trong danh sách skill khả dụng |
| Plan mode | Chế độ `plan`: Shift+Tab trong agy, hoặc `agy --mode plan` |
| Subagent | `invoke_subagent` |
| Theo dõi việc, todo | Một task artifact (checklist markdown) |
| `CLAUDE.md` của dự án | Vẫn là file nguồn, nhưng agy **không đọc** CLAUDE.md: xem mục dưới |
| `~/.claude/CLAUDE.md`, `~/.claude/rules/*` | `~/.gemini/GEMINI.md`, `~/.gemini/config/` (plugin, skill, `hooks.json`, `mcp_config.json`) |
| `.claude/` của dự án | `.agents/` của dự án |
| `/plugin install <tên> --marketplace <owner>/<repo>` | `agy plugin install https://github.com/<owner>/<repo>` |

## Chạy script của skill

Script của proj (`scripts/project-snapshot.sh`…) nằm trong `~/.gemini`, mà terminal sandbox của
agy không đọc được (`Operation not permitted`). Chạy chúng ngoài sandbox; agy sẽ hỏi quyền.
Đọc file của skill (references, templates) bằng tool đọc file, không bằng lệnh shell.

## CLAUDE.md của dự án

agy đọc `GEMINI.md` và `AGENTS.md`, không đọc `CLAUDE.md`. Giữ CLAUDE.md là file nguồn duy nhất (dự án vẫn dùng được với Claude Code) và để agy thấy nó:

- Khi kickoff tạo CLAUDE.md, hoặc khi kiểm tra dự án đã có CLAUDE.md: tạo `GEMINI.md` ở gốc repo với đúng một dòng `@[CLAUDE.md](CLAUDE.md)`. agy chèn nguyên nội dung CLAUDE.md vào rules của dự án.
- Repo đã có `GEMINI.md` thì thêm dòng đó vào cuối, không ghi đè. Đưa GEMINI.md vào cùng PR với CLAUDE.md.
- Mọi chỗ khác ghi "CLAUDE.md dự án" vẫn là CLAUDE.md này.

## Skill không có trên Antigravity

`setup-project`, `add-preset` và `harness-check` chỉ dành cho Claude Code (chúng sửa `~/.claude` và `./.claude/`), nên kessie-skills không nạp chúng vào Antigravity. Chỗ nào gợi ý các skill này thì bỏ qua, hoặc nói với người dùng là chỉ có trên Claude Code.
