# Catalog cho /setup-project

Bảng đề xuất chính (bước 4) chỉ lấy từ file này. Mỗi mục có **dấu hiệu**: chỉ đề xuất
khi tìm thấy dấu hiệu đó trong project, và nêu dấu hiệu đó trong bảng đề xuất. Gợi ý
tìm trên web (bước 4b) trình bày riêng và chỉ cài khi người dùng chọn đích danh.

## Plugin (marketplace `claude-plugins-official`, bật ở scope project)

| Plugin | Dấu hiệu | Cần có trên máy |
|---|---|---|
| `typescript-lsp` | `tsconfig.json`, `package.json` có `typescript` | `typescript-language-server` (`npm i -g typescript typescript-language-server`) |
| `pyright-lsp` | `pyproject.toml`, `requirements*.txt`, `*.py` | `pyright` (`npm i -g pyright` hoặc `pipx install pyright`) |
| `clangd-lsp` | `CMakeLists.txt`, `*.c`, `*.cpp`, `*.h`, `compile_commands.json` | `clangd` (macOS: `xcode-select --install` hoặc `brew install llvm` · Fedora: `sudo dnf install clang-tools-extra`) |
| `rust-analyzer-lsp` | `Cargo.toml` | `rust-analyzer` |
| `gopls-lsp` | `go.mod` | `gopls` |
| `frontend-design` | project có UI web (React/Vue/Svelte, `index.html`, Tailwind) | — |

`impeccable` (marketplace riêng `pbakaus/impeccable`): chỉ đề xuất khi project có UI
**và** người dùng muốn chăm chút thiết kế. Không bật cùng lúc với `frontend-design`
trừ khi người dùng yêu cầu.

Kiểm tra binary bằng `command -v`. Nếu thiếu: vẫn có thể bật plugin, nhưng phải báo
lệnh cài cho người dùng tự chạy. Không tự chạy `sudo`.

## MCP (scope project, ghi vào `./.mcp.json`)

| MCP | Dấu hiệu | Lệnh thêm | Cần có trên máy |
|---|---|---|---|
| `hf` (Hugging Face Hub) | `transformers`, `datasets`, `huggingface_hub`, `unsloth`, `peft`, `trl` trong dependency | `claude mcp add --scope project --transport http hf https://huggingface.co/mcp` | — |
| `colab` (Google Colab) | `*.ipynb` có code huấn luyện, hoặc người dùng nói đang dùng Colab | `claude mcp add --scope project colab -- uvx git+https://github.com/googlecolab/colab-mcp` | `uvx` (cài `uv`) |
| `playwright` | project có UI web (như `frontend-design`), hoặc `playwright` trong dependency | `claude mcp add --scope project playwright -- npx @playwright/mcp@latest` | `npx` (Node) |

- `hf` không cần token cho bộ tool cơ bản. Muốn dùng tool cần đăng nhập thì thay URL bằng
  `https://huggingface.co/mcp?login`. Không bao giờ ghi token cố định vào `.mcp.json`.
- `colab` điều khiển notebook đang mở trên trình duyệt, chạy code bằng tài khoản Google
  của người dùng. Nêu rõ điều này trong bảng đề xuất. `uvx git+…` lấy bản mới nhất mỗi
  lần chạy; người dùng muốn cố định thì thêm `@<commit>` vào cuối URL.
- `context7` thuộc scope user (do `setup.sh` của harness cài). Không thêm ở scope project.
- `.mcp.json` thường được commit cùng repo. Claude Code sẽ hỏi người dùng trước khi bật
  MCP project lần đầu; không đặt `enableAllProjectMcpServers`.

## Thành phần ECC (cài bằng `scripts/ecc-project.sh`)

Script tự bỏ qua thứ đã có ở scope user (`~/.claude/skills`, `~/.claude/agents`).

### ml — PyTorch, huấn luyện, fine-tune
Dấu hiệu: `torch`, `transformers`, `unsloth`, `peft`, `lightning` trong dependency hoặc import; `*.ipynb` huấn luyện.
- skills: `pytorch-patterns`, `mle-workflow`
- agents: `pytorch-build-resolver`, `mle-reviewer`

### rag — truy hồi, embedding, vector store
Dấu hiệu: `langchain`, `llama_index`, `chromadb`, `faiss`, `qdrant`, `pgvector`, thư mục embedding/index.
- agents: `rag-pipeline-reviewer`
- skills: `iterative-retrieval`

### llm-app — gọi API LLM, agent
Dấu hiệu: `anthropic`, `openai`, `@anthropic-ai/sdk`, `mcp`, `@modelcontextprotocol/sdk`.
- skills: `cost-aware-llm-pipeline`, `prompt-caching-strategy`, `agent-harness-construction`, `mcp-server-patterns`, `agent-security-hardening`

### fastapi
Dấu hiệu: `fastapi` trong dependency.
- skills: `fastapi-patterns`
- agents: `fastapi-reviewer`

### python-test
Dấu hiệu: `pytest` trong dependency hoặc thư mục `tests/` Python.
- skills: `python-testing`

### cpp
Dấu hiệu: như `clangd-lsp`.
- skills: `cpp-coding-standards`, `cpp-testing`
- agents: `cpp-build-resolver`, `cpp-reviewer`

### react
Dấu hiệu: `react` trong `package.json`.
- skills: `react-patterns`, `react-testing`, `frontend-patterns`, `accessibility`
- agents: `react-reviewer`

### database
Dấu hiệu: `prisma/`, `alembic/`, `migrations/`, `psycopg`, `pg`, `sqlalchemy`, file `*.sql`.
- skills: `postgres-patterns`, `database-migrations`
- agents: `database-reviewer`

### container
Dấu hiệu: `Dockerfile`, `docker-compose*.yml`, `compose*.yml`.
- skills: `docker-patterns`, `deployment-patterns`

## Không bao giờ đề xuất
- Plugin `ecc@ecc`, profile của trình cài ECC, rule `common`.
- MCP filesystem, fetch, memory, sequential-thinking (Claude Code đã có sẵn), GitHub MCP
  (dùng `gh`), Kaggle MCP bản cộng đồng (dùng CLI `kaggle`).
- `tdd-workflow`, `verification-loop`, `planner`, `tdd-guide`, `code-reviewer`, `orch-*`
  (trùng Superpowers).
- Bất cứ thứ gì ngoài catalog này trong bảng đề xuất chính. Thứ khác chỉ xuất hiện ở
  phần gợi ý tra cứu web (bước 4b), và chỉ cài khi người dùng chọn đích danh.
