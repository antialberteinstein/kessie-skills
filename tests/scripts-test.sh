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

echo "---"; echo "$pass passed, $failn failed"
[ "$failn" -eq 0 ]
