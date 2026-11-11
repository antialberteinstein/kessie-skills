#!/usr/bin/env bash
# Test offline cho harness-check.sh và ecc-project.sh. Chạy: bash tests/scripts-test.sh
# Dùng CLAUDE_CONFIG_DIR giả nên không đọc hay sửa ~/.claude thật.
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HC="$ROOT/harness-check/scripts/harness-check.sh"
ECC="$ROOT/setup-project/scripts/ecc-project.sh"
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
pass=0; failn=0

check() { # mô tả, lệnh kiểm tra...
  local name="$1"; shift
  if "$@"; then echo "ok   $name"; pass=$((pass+1)); else echo "FAIL $name"; failn=$((failn+1)); fi
}
has()    { grep -qF -- "$2" <<<"$1"; }
hasnt()  { ! grep -qF -- "$2" <<<"$1"; }

# ── harness-check: cấu hình hợp lệ, có plugin LSP, skill trùng user/project, secret ──
U="$TMP/user"; P="$TMP/proj"
mkdir -p "$U/skills/foo" "$U/agents" "$P/.claude/skills/foo"
echo 'description: x' > "$U/skills/foo/SKILL.md"
cat > "$U/settings.json" <<'JSON'
{ "enabledPlugins": { "pyright-lsp@claude-plugins-official": true, "nonexistent-lsp@x": true },
  "env": { "MY_API_KEY": "s3cr3t-value" },
  "attribution": { "commit": "" } }
JSON
out=$(cd "$P" && CLAUDE_CONFIG_DIR="$U" bash "$HC" --offline 2>&1); rc=$?
check "harness-check chạy hết, exit 0"                [ "$rc" -eq 0 ]
check "không lỗi bash (declare -A / mảng rỗng)"       hasnt "$out" "unbound variable"
check "không lỗi find -printf"                         hasnt "$out" "printf: unknown"
check "có dòng tổng kết"                               has "$out" "Tổng:"
check "kiểm tra binary của pyright-lsp"                has "$out" "pyright-lsp@claude-plugins-official"
check "báo skill trùng user/project"                   has "$out" "'foo' có ở cả user và project"
check "báo secret trong env"                           has "$out" "'MY_API_KEY'"
check "không in giá trị secret"                        hasnt "$out" "s3cr3t-value"

# ── harness-check: settings.json hỏng → VALID rỗng, không được chết vì set -u ──
U2="$TMP/user2"; mkdir -p "$U2"; echo '{ hỏng' > "$U2/settings.json"
out=$(cd "$TMP" && CLAUDE_CONFIG_DIR="$U2" bash "$HC" --offline 2>&1); rc=$?
check "settings hỏng: exit 0"                          [ "$rc" -eq 0 ]
check "settings hỏng: báo FAIL json"                   has "$out" "không phải JSON hợp lệ"
check "settings hỏng: không unbound variable"          hasnt "$out" "unbound variable"

# ── harness-check: MCP (user trong .claude.json, project trong .mcp.json) ──
U3="$TMP/user3"; P3="$TMP/proj3"; mkdir -p "$U3" "$P3/.claude"
echo '{ "enableAllProjectMcpServers": true }' > "$U3/settings.json"
echo '{ "mcpServers": { "context7": { "type": "stdio", "command": "sh", "args": [] } } }' > "$U3/.claude.json"
cat > "$P3/.mcp.json" <<'JSON'
{ "mcpServers": {
    "context7": { "command": "sh" },
    "colab":    { "command": "lenh-khong-ton-tai-zzz", "args": [] },
    "hf":       { "type": "http", "url": "https://huggingface.co/mcp", "headers": { "Authorization": "Bearer hf_s3cr3t" } },
    "safe":     { "type": "http", "url": "https://x", "headers": { "Authorization": "Bearer ${HF_TOKEN}" } } } }
JSON
out=$(cd "$P3" && CLAUDE_CONFIG_DIR="$U3" bash "$HC" --offline 2>&1); rc=$?
check "mcp: exit 0"                                    [ "$rc" -eq 0 ]
check "mcp: liệt kê MCP user và project"               has "$out" "user: context7 | project:"
check "mcp: báo MCP trùng user/project"                has "$out" "'context7' khai báo ở cả user và project"
check "mcp: báo thiếu lệnh của MCP stdio"              has "$out" "MCP cần 'lenh-khong-ton-tai-zzz'"
check "mcp: báo enableAllProjectMcpServers"            has "$out" "enableAllProjectMcpServers"
check "mcp: báo token cố định trong .mcp.json"         has "$out" "MCP 'hf' có header 'Authorization'"
check "mcp: không in giá trị token"                    hasnt "$out" "hf_s3cr3t"
check "mcp: \${BIẾN} không bị coi là token cố định"     hasnt "$out" "MCP 'safe'"
echo '{ hỏng' > "$P3/.mcp.json"
out=$(cd "$P3" && CLAUDE_CONFIG_DIR="$U3" bash "$HC" --offline 2>&1)
check "mcp: .mcp.json hỏng thì báo FAIL"               has "$out" ".mcp.json không phải JSON hợp lệ"
check "mcp: .mcp.json hỏng không unbound variable"     hasnt "$out" "unbound variable"

# ── ecc-project.sh: các nhánh không cần mạng ──
E="$TMP/eccproj"; mkdir -p "$E"
out=$(cd "$E" && CLAUDE_CONFIG_DIR="$U" bash "$ECC" status 2>&1)
check "ecc status khi chưa cài"                        has "$out" "chưa cài thành phần ECC nào"
out=$(cd "$E" && CLAUDE_CONFIG_DIR="$U" bash "$ECC" -n remove --skills 'Bad;name' 2>&1); rc=$?
check "ecc remove từ chối tên không hợp lệ"            [ "$rc" -ne 0 ]
out=$(cd "$E" && CLAUDE_CONFIG_DIR="$U" bash "$ECC" -n remove --skills python-testing --agents db-reviewer 2>&1); rc=$?
check "ecc remove chạy thử: exit 0"                    [ "$rc" -eq 0 ]
check "ecc remove chạy thử: liệt kê thành phần"        has "$out" "- skill python-testing"
check "ecc remove chạy thử: không tạo .claude"         [ ! -e "$E/.claude" ]
out=$(cd "$E" && CLAUDE_CONFIG_DIR="$U" bash "$ECC" add 2>&1); rc=$?
check "ecc add không tham số thì dừng"                 [ "$rc" -ne 0 ]

# ── Skill: frontmatter hợp lệ, README đã đồng bộ ──
for f in "$ROOT"/*/SKILL.md; do
  d="$(basename "$(dirname "$f")")"
  fm="$(awk 'NR==1&&/^---$/{f=1;next} f&&/^---$/{exit} f' "$f")"
  check "$d: name khớp tên thư mục"                    grep -qx "name: $d" <<<"$fm"
  check "$d: có description"                           grep -q "^description:" <<<"$fm"
done
check "README đã đồng bộ với các skill"                python3 "$ROOT/scripts/update-readme.py" --check
for d in disk-cleanup run-python; do
  check "README ghi $d là skill cá nhân"               grep -q "^| \`/$d\` | Skill cá nhân" "$ROOT/README.md"
done

check "run-python dùng ~/.zshrc, không phải ~/.zshr" bash -c "! grep -rqE '~/\\.zshr([^c]|\$)' \"$ROOT/run-python\""

# ── Antigravity (agy): plugin chỉ tự đọc skills/, skills.json trỏ nó vào thư mục gốc (quét một cấp) ──
check "skills.json là JSON hợp lệ, trỏ vào thư mục gốc" \
  jq -e '.entries[0].path == "."' "$ROOT/skills.json"
# Skill chỉ dành cho Claude Code (sửa ~/.claude, ./.claude) không nạp vào Antigravity
for d in harness-check setup-project add-preset; do
  check "Antigravity bỏ qua $d (chỉ cho Claude Code)"  jq -e --arg d "$d" '.entries[0].exclude | index($d)' "$ROOT/skills.json"
done
check "exclude chỉ chứa skill có thật" \
  bash -c "for d in \$(jq -r '.entries[0].exclude[]' \"$ROOT/skills.json\"); do [ -f \"$ROOT/\$d/SKILL.md\" ] || exit 1; done"
check "proj trỏ tới bảng đổi sang Antigravity"        grep -qF 'references/antigravity.md' "$ROOT/proj/SKILL.md"
check "có references/antigravity.md"                  [ -f "$ROOT/proj/references/antigravity.md" ]
check "proj ghi đường dẫn tuyệt đối cho agy (slash không kèm đường dẫn)" \
  grep -qF '~/.gemini/config/plugins/kessie-skills/proj/references/antigravity.md' "$ROOT/proj/SKILL.md"
check "antigravity.md dặn chạy script ngoài sandbox"   grep -qi 'sandbox' "$ROOT/proj/references/antigravity.md"
check "mọi skill nằm đúng một cấp dưới thư mục gốc" \
  bash -c "! find \"$ROOT\" -mindepth 3 -name SKILL.md -not -path '*/.git/*' | grep -q ."

echo "---"; echo "$pass passed, $failn failed"
[ "$failn" -eq 0 ]
